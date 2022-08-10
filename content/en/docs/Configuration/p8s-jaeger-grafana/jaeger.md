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

