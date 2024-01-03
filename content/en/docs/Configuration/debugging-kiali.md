---
title: "Debugging Kiali"
description: "How to debug Kiali using traces."
---

Kiali provides the ability to emit debugging traces to the [distributed tracing](/docs/configuration/p8s-jaeger-grafana/tracing) platform, Jaeger or Grafana Tempo.

The traces can be sent in HTTP, HTTPS or gRPC protocol. It is also possible to use TLS. When _tls_config.enabled_ is set to true, one of the options _skip_verify_ or _ca_name_ should be specified. The traces are emitted in OpenTelemetry format.

The traces can be sent in OTel or in Jaeger format. This is changed in the _collector_type_ setting. 

```yaml
server:
  observability:
    tracing:
      collector_url: "localhost:4317"
      enabled: false
      protocol: "grpc"
      tls_config:
        enabled: true
        skip_verify: false
        ca_name: "/tls.crt"
```

The traces emitted by Kiali can be searched in the _Kiali_ workload:

![Kiali traces](/images/documentation/configuration/kiali_own_traces.png)


