---
title: "Virtual Machine workloads"
description: "Ensuring Kiali can visualize a VM WorkloadEntry."
---

## Introduction

Kiali graph visualizes both Virtual Machine workloads (WorkloadEntry) and pod-based workloads, running inside a Kubernetes cluster. You must ensure that the Istio Proxy is running, and correctly configured, on the Virtual Machine. Also, Prometheus must be able to scrape the metrics endpoint of the Istio Proxy running on the VM. Kiali will then be able to read the traffic telemetry for the Virtual Machine workloads, and incorporate the VM workloads into the graph.

{{% alert color="warning" %}}
Kiali does not currently distinguish between pod-based and VM-based workloads nor does Kiali support viewing additional details for the VM-based workloads beyond what is displayed on the graph. One way to distinguish between the two is to give the VM-based workloads a different version label than the pod-based workloads.
{{% /alert %}}

## Configuring Prometheus to scrape VM-based Istio Proxy

Once the Istio Proxy is running on a Virtual Machine, configuring Prometheus to scrape the VM's Istio Proxy metrics endpoint is the only configuration Kiali needs to display traffic for the VM-based workload.
[Configuring Prometheus](https://prometheus.io/docs/prometheus/latest/configuration/configuration/) will vary between environments. Here is a very simple example of a Prometheus configuration that includes a job to scrape VM based workloads:

```yaml
- job_name: bookinfo-vms
  honor_timestamps: true
  scrape_interval: 15s
  scrape_timeout: 10s
  metrics_path: /stats/prometheus
  scheme: http
  follow_redirects: true
  static_configs:
  - targets:
    - details-v1:15020
    - productpage-v1:15020
    - ratings-v1:15020
    - reviews-v1:15020
    - reviews-v2:15020
    - reviews-v3:15020
```
