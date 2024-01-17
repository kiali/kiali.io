---
title: "Debugging Kiali"
description: "How to debug Kiali using traces."
---

Kiali provides the ability to emit debugging traces to the [distributed tracing](/docs/configuration/p8s-jaeger-grafana/tracing) platform, Jaeger or Grafana Tempo. 

{{% alert color="warning" %}}
From Kiali 1.79, the feature of Kiali emitting tracing data into Jaeger format **has been removed**.
{{% /alert %}}

The traces can be sent in HTTP, HTTPS or gRPC protocol. It is also possible to use TLS. When _tls_enabled_ is set to true, one of the options _skip_verify_ or _ca_name_ should be specified. 

The traces are sent in OTel format, indicated in the _collector_type_ setting. 

```yaml
server:
  observability:
    tracing:
      collector_type: "otel"
      collector_url: "jaeger-collector.istio-system:4317"
      enabled: false
      otel:
        protocol: "grpc"
        tls_enabled: true
        skip_verify: false
        ca_name: "/tls.crt"
```

Usually, the tracing platforms expose different ports to collect traces in distinct formats and protocols:
* The Jaeger collector accepts OpenTelemetry Protocol over HTTP (4318) and gRPC (4317).
* The Grafana Tempo distributor accepts OpenTelemetry Protocol over HTTP (4318) and gRPC (4317). It can be configured to accept TLS. 

The traces emitted by Kiali can be searched in the _Kiali_ workload:

![Kiali traces](/images/documentation/configuration/kiali_own_traces.png)


