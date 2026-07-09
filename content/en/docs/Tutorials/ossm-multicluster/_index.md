---
title: "MultiCluster on OpenShift"
description: "End-to-end guides for setting up Istio multi-cluster meshes on OpenShift with ACM and Kiali."
weight: 7
type: tutorial
---

These tutorials walk through setting up Istio multi-cluster meshes on OpenShift using Red Hat Advanced Cluster Management (ACM) and Kiali.

## Guides

| Guide | Description |
|-------|-------------|
| [MultiCluster on OpenShift]({{< relref "./ossm-acm-hub-spoke" >}}) | Install ACM, import a spoke cluster, deploy OSSM 3 with ambient and sidecar demo apps, and configure Kiali to query metrics from ACM's central Thanos. |
| [Multi-Primary Mesh]({{< relref "./ossm-acm-multi-primary" >}}) | Extend the hub/spoke setup into a true multi-primary Istio mesh with cross-cluster endpoint discovery and East-West gateways. |
| [Dashboards and Tracing]({{< relref "./ossm-dashboards-tracing" >}}) | Add Perses metrics dashboards (backed by hub Thanos) and Tempo distributed tracing (aggregated from both spokes via OTEL) to the multi-primary mesh. |
