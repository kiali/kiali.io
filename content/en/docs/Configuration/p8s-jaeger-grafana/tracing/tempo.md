---
title: "Grafana Tempo"
description: >
  This page describes how to configure Grafana Tempo for Kiali.
weight: 2
---

## Grafana Tempo Configuration

There are two possibilities to integrate Kiali with Grafana Tempo:

- Using the Grafana Tempo API: This option returns the traces from the Tempo API in OpenTelemetry format. 
- Using the Jaeger frontend with the Grafana Tempo backend.

### Using the Grafana Tempo API 

This is a configuration example to setup Kiali tracing with Grafana Tempo: 

```yaml
spec:
  external_services:
    tracing:
      # Enabled by default. Kiali will anyway fallback to disabled if
      # Tempo is unreachable.
      enabled: true
      # Tempo service name is "query-frontend" and is in the "tempo" namespace.
      # Make sure the URL you provide corresponds to the non-GRPC enabled endpoint
      # It does not support grpc yet, so make sure "use_grpc" is set to false.
      in_cluster_url: "http://query-frontend.tempo:3200"
      provider: "tempo"
      use_grpc: false
      # Public facing URL of Grafana 
      url: "http://my-tempo-host:3200"
```

The default UI for Grafana Tempo is Grafana, so we should also set the Grafana url in the configuration: 

```yaml
spec:
  external_services:
    grafana:
      in_cluster_url: http://grafana.istio-system:3000
      url: http://my-grafana-host
```

We also need to set up a default [Tempo datasource](https://grafana.com/docs/grafana/latest/datasources/tempo/) in Grafana. 

![Kiali grafana_tempo](/images/documentation/configuration/grafana_tempo_ds.png)

The _Traces_ tab will show your traces in a bubble chart:

![Kiali grafana_tempo](/images/documentation/configuration/grafana_tempo.png)

Increasing performance is achievable by enabling gRPC access, specifically for query searches. However, accessing the HTTP API will still be necessary to gather information about individual traces. This is an example to configure the gRPC access: 

```yaml
spec:
  external_services:
    tracing:
      enabled: true
      # grpc port defaults to 9095
      grpc_port: 9095 
      in_cluster_url: "http://query-frontend.tempo:3200"
      provider: "tempo"
      use_grpc: true
      url: "http://my-tempo-host:3200"
```

### Using the Jaeger frontend with Grafana Tempo tracing backend

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