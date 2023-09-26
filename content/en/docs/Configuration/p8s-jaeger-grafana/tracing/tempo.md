---
title: "Grafana Tempo"
description: >
  This page describes how to configure Grafana Tempo for Kiali.
weight: 2
---

## Grafana Tempo Configuration

There are two possibilities to integrate Kiali with Grafana Tempo:

- Using the Tempo API: This option returns the traces from the Tempo API in OpenTelemetry format. 
- Using the Jaeger frontend with the Grafana Tempo backend.

### Use Tempo API 

This is a configuration example to setup Kiali tracing with Grafana Tempo: 

```yaml
spec:
  external_services:
    tracing:
      # Enabled by default. Kiali will anyway fallback to disabled if
      # Tempo is unreachable.
      enabled: true
      # Jaeger service name is "tracing" and is in the "telemetry" namespace.
      # Make sure the URL you provide corresponds to the non-GRPC enabled endpoint
      # if you set "use_grpc" to false.
      in_cluster_url: "http://tracing.telemetry:3200"
      provider: "tempo"
      use_grpc: true
      # Public facing URL of Grafana with the Tempo Datasource 
      # Note this is not fully integrated 
      url: "http://my-tempo-host/explore?left=%7B%22datasource%22:%22Tempo%22,%22queries%22:%5B%7B%22refId%22:%22A%22,%22queryType%22:%22traceId%22,%22query%22:%22%22%7D%5D,%22range%22:%7B%22from%22:%22now-1h%22,%22to%22:%22now%22%7D%7D&orgId=1"
```

### Use Jaeger frontend with Grafana Tempo tracing backend

It is possible to use the Grafana Tempo tracing backend exposing the Jaeger API.
[tempo-query](https://github.com/grafana/tempo/tree/main/cmd/tempo-query) is a
Jaeger storage plugin. It accepts the full Jaeger query API and translates these
requests into Tempo queries.

Since Tempo is not yet part of the built-in addons that are part of Istio, you
need to manage your Tempo instance.

#### Tanka

The [official Grafana Tempo documentation](https://grafana.com/docs/tempo/latest/setup/tanka/)
explains how to deploy a Tempo instance using [Tanka](https://tanka.dev/). You
will need to tweak the settings from the default Tanka configuration to:

- Expose the Zipkin collector
- Expose the GRPC Jaeger Query port

When the Tempo instance is deployed with the needed configurations, you have to
set
[`meshConfig.defaultConfig.tracing.zipkin.address`](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#ProxyConfig-tracing)
from Istio to the Tempo Distributor service and the Zipkin port. Tanka will deploy
the service in `distributor.tempo.svc.cluster.local:9411`.

The `in_cluster_url` Kiali option needs to be set to'
`http://query-frontend.tempo.svc.cluster.local:16685`.

#### Tempo Operator

The [Tempo Operator for Kubernetes](https://github.com/grafana/tempo-operator)
provides a native Kubernetes solution to deploy Tempo easily in your system.

After installing the Tempo Operator in your cluster, you can create a new
Tempo instance with the following CR:

```yaml
kubectl create namespace tempo
kubectl apply -n tempo -f - <<EOF
apiVersion: tempo.grafana.com/v1alpha1
kind: TempoStack
metadata:
  name: smm
spec:
  storageSize: 1Gi
  storage:
    secret:
      type: s3
      name: object-storage
  resources:
    total:
      limits:
        memory: 2Gi
        cpu: 2000m
  template:
    queryFrontend:
      jaegerQuery:
        enabled: true
        ingress:
          type: ingress
EOF
```

Note the name of the bucket where the traces will be stored in our example is
called `object-storage`. Check the
[Tempo Operator](https://grafana.com/docs/tempo/next/setup/operator/object-storage)
documentation to know more about what storages are supported and how to create
the secret properly to provide it to your Tempo instance.

Now, you are ready to configure the
[`meshConfig.defaultConfig.tracing.zipkin.address`](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#ProxyConfig-tracing)
field in your Istio installation. It needs to be set to the `9411` port of the
Tempo Distributor service. For the previous example, this value will be
`tempo-smm-distributor.tempo.svc.cluster.local:9411`.

Now, you need to configure the `in_cluster_url` setting from Kiali to access
the Jaeger API. You can point to the `16685` port to use GRPC or `16686` if not.
For the given example, the value would be
`http://tempo-ssm-query-frontend.tempo.svc.cluster.local:16685`.

There is a [related tutorial]({{< ref "/docs/tutorials/tempo/02-kiali-tempo-integration" >}}) with detailed instructions to setup Kiali and Grafana Tempo with the Operator.