---
title: "Grafana"
description: >
  This page describes how to configure Grafana for Kiali.
---

## Grafana configuration

Istio provides [preconfigured Grafana
dashboards](https://istio.io/latest/docs/ops/integrations/grafana/) for the
most relevant metrics of the mesh. Although Kiali offers similar views in its
metrics dashboards, it is not in Kiali's goals to provide the advanced querying
options, nor the highly customizable settings, that are available in Grafana.
Thus, it is recommended that you use Grafana if you need those advanced
options.

Kiali can provide a direct link from its metric dashboards to the equivalent or
most similar Grafana dashboard, which is convenient if you need the powerful
Grafana options. For these links to appear in Kiali you need to manually
configure the Grafana URL and the dashboards that come preconfigured with Istio, like in the following example:

{{% alert color="warning" %}}
Kiali will query Grafana and try to fetch the configured dashboards.  For this reason Kiali must be able to reach Grafana, authenticate, and find the Istio dashboards. The Istio dashboards must be installed in Grafana for the links to appear in Kiali.
{{% /alert %}}

```yaml
spec:
  external_services:
    grafana:
      enabled: true
      # Grafana service name is "grafana" and is in the "telemetry" namespace.
      in_cluster_url: 'http://grafana.telemetry:3000/'
      # Public facing URL of Grafana
      url: 'http://my-ingress-host/grafana'
      dashboards:
      - name: "Istio Service Dashboard"
        variables:
          namespace: "var-namespace"
          service: "var-service"
      - name: "Istio Workload Dashboard"
        variables:
          namespace: "var-namespace"
          workload: "var-workload"
      - name: "Istio Mesh Dashboard"
      - name: "Istio Control Plane Dashboard"
      - name: "Istio Performance Dashboard"
      - name: "Istio Wasm Extension Dashboard"
```

{{% alert color="warning" %}}
The described configuration is done in the Kiali CR when Kiali is installed using the Kiali Operator. If Kiali is installed with the Helm chart then the correct way to configure this is via regular --set flags.
{{% /alert %}}

