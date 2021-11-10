---
title: "Distributed Tracing / Jaeger"
description: "Configuring Kiali's Jaeger integration."
---


## Prometheus configuration

Kiali *requires* Prometheus to generate the
[topology graph]({{< relref "../Features/topology" >}}),
[show metrics]({{< relref "../Features/details#metrics" >}}),
[calculate health]({{< relref "../Features/health" >}}) and
for several other features. If Prometheus is missing or Kiali
can't reach it, Kiali won't work properly.

By default, Kiali assumes that Prometheus is available at the URL of the form
`http://prometheus.<istio_namespace_name>:9090`, which is the usual case if you
are using the Prometheus Istio add-on. If your Prometheus instance has a
different service name or is installed to a different namespace, you must
manually provide the endpoint where it is available, like in the following
example:

```yaml
spec:
  external_services:
    prometheus:
      # Prometheus service name is "metrics" and is in the "telemetry" namespace
      url: "http://metrics.telemetry:9090/"
```

{{% alert title="Note" color="info" %}}
Notice that you don't need to expose Prometheus outside the cluster. It is
enough to provide the Kubernetes internal service URL.
{{% /alert %}}

Kiali maintains an internal cache of some Prometheus queries to improve
performance (mainly, the queries to calculate Health indicators). It
would be very rare to see data delays, but should you notice any delays you may
tune caching parameters to values that work better for your environment. These
are the default values:

```yaml
spec:
  external_services:
    prometheus:
      cache_enabled: true
      # Per-query expiration in seconds
      cache_duration: 10
      # Global cache expiration in seconds. Think of it as
      # the "reset" or "garbage collection" interval.
      cache_expiration: 300
```

### Compatibility with Prometheus-like servers

Although Kiali assumes and is tested against Prometheus, there are <abbr
title="Time series databases">TSDBs</abbr> that can be used as Prometheus
replacement despite not implementing the full Prometheus API. 

Community users have faced two issues when using Prometheus-like TSDBs:
* Kiali may report that the TSDB is unreachable, and/or
* Kiali may show empty metrics if the TSBD does no implement the `/api/v1/status/config`.

To fix these issues, you may need to provide a custom health check endpoint for
the TSDB and/or manually provide the configurations that Kiali reads from the
`/api/v1/status/config` API endpoint:

```yaml
spec:
  external_services:
    prometheus:
      # Fix the "Unreachable" metrics server warning.
      health_check_url: "http://custom-tsdb-health-check-url"
      # Fix for the empty metrics dashboards
      thanos_proxy:
        enabled: true
        retention_period: "7d"
        scrape_interval: "30s"
```

## Jaeger configuration

Jaeger is a _highly recommended_ service because [Kiali uses distributed
tracing data for several features]({{< relref "../Features/tracing" >}}),
providing an enhanced experience.

By default, Kiali will try to reach Jaeger at the GRPC-enabled URL of the form
`http://tracing.<istio_namespace_name>:16685/jaeger`, which is the usual case
if you are using the Jaeger Istio add-on. If this endpoint is unreachable,
Kiali will disable features that use distributed tracing data.

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
      # Make sure the URL you provide corresponds to the GRPC enabled endpoint
      # if you set "use_grpc" to true.
      in_cluster_url: 'http://tracing.telemetry/jaeger'
      use_grpc: false
      # Public facing URL of Jaeger
      url: 'http://my-jaeger-host/jaeger'
```

Minimally, you must provide `spec.external_services.tracing.in_cluster_url` to
enable Kiali features that use distributed tracing data. However, Kiali can
provide contextual links that users can use to jump to the Jaeger console to
inspect tracing data more in deep. For these links to be available you need to
set the `spec.external_services.tracing.url` which may mean that you should
expose Jaeger outside the cluster.

## Grafana configuration

[TODO]
