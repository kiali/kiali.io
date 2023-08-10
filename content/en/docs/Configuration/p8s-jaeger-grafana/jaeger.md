---
title: "Jaeger"
description: >
  This page describes how to configure Jaeger for Kiali.
---


## Jaeger configuration

Jaeger is a _highly recommended_ service because [Kiali uses distributed
tracing data for several features]({{< relref "../../Features/tracing" >}}),
providing an enhanced experience.

By default, Kiali will try to reach Jaeger at the GRPC-enabled URL of the form
`http://tracing.<istio_namespace_name>:16685/jaeger`, which is the usual case
if you are using [the Jaeger Istio
add-on](https://istio.io/latest/docs/ops/integrations/jaeger/#option-1-quick-start).
If this endpoint is unreachable, Kiali will disable features that use
distributed tracing data.

If your Jaeger instance has a different service name or is installed to a
different namespace, you must manually provide the endpoint where it is
available, like in the following example:

```yaml
spec:
  external_services:
    tracing:
      # Enabled by default. Kiali will anyway fallback to disabled if
      # Jaeger is unreachable.
      enabled: true
      # Jaeger service name is "tracing" and is in the "telemetry" namespace.
      # Make sure the URL you provide corresponds to the non-GRPC enabled endpoint
      # if you set "use_grpc" to false.
      in_cluster_url: 'http://tracing.telemetry:16685/jaeger'
      use_grpc: true
      # Public facing URL of Jaeger
      url: 'http://my-jaeger-host/jaeger'
```

Minimally, you must provide `spec.external_services.tracing.in_cluster_url` to
enable Kiali features that use distributed tracing data. However, Kiali can
provide contextual links that users can use to jump to the Jaeger console to
inspect tracing data more in depth. For these links to be available you need to
set the `spec.external_services.tracing.url` which may mean that you should
expose Jaeger outside the cluster.

{{% alert color="success" %}}
Default values for connecting to Jaeger are based on the [Istio's provided
sample add-on manifests](https://github.com/istio/istio/tree/master/samples/addons).
If your Jaeger setup differs significantly from the sample add-ons, make sure
that Istio is also properly configured to push traces to the right URL.
{{% /alert %}}

## Use Jaeger frontend with Grafana Tempo tracing backend

It is possible to use the Grafana Tempo tracing backend exposing the Jaeger API.
[tempo-query](https://github.com/grafana/tempo/tree/main/cmd/tempo-query) is a
Jaeger storage plugin. It accepts the full Jaeger query API and translates these
requests into Tempo queries.

Since Tempo is not yet part of the built-in addons that are part of Istio, you
need to manage your Tempo instance.

## Tanka

The [official Grafana Tempo documentation](https://grafana.com/docs/tempo/latest/setup/tanka/)
explains how to deploy a Tempo instance using [Tanka](https://tanka.dev/). You
will need to tweak the settings from the default Tanka configuration to:
* Expose the Zipkin collector
* Expose the GRPC Jaeger Query port

When the Tempo instance is deployed with the needed configurations, you have to
set
[`meshConfig.defaultConfig.tracing.zipkin.address`](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#ProxyConfig-tracing)
from Istio to the Tempo Distributor service and the Zipkin port. Tanka will deploy
the service in `distributor.tempo.svc.cluster.local:9411`.

The `in_cluster_url` Kiali option needs to be set to'
`http://query-frontend.tempo.svc.cluster.local:16685`.

### Tempo Operator

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

There is a [related tutorial](https://kiali.io/docs/tutorials/tempo/02-kiali-tempo-integration/) with detailed instructions to setup Kiali and Grafana Tempo with the Operator. 
