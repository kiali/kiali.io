---
title: "Prometheus"
description: >
  This page describes how to configure Prometheus for Kiali.
weight: 10
aliases:
  - /docs/configuration/p8s-jaeger-grafana/
  - /docs/configuration/p8s-jaeger-grafana/prometheus/
  - /docs/configuration/metrics/
  - /docs/configuration/metrics/prometheus/
  - /docs/configuration/external-services/prometheus/
---


## Prometheus configuration

Kiali uses Prometheus to generate the
[topology graph]({{< relref "../../../Features/topology" >}}),
[show metrics]({{< relref "../../../Features/details#metrics" >}}),
[calculate health]({{< relref "../../../Features/health" >}}) and
for several other features. Prometheus is enabled by default and is required
for full Kiali functionality.

### Disabling Prometheus

If you want to run Kiali without a Prometheus instance, you can disable it:

```yaml
spec:
  external_services:
    prometheus:
      enabled: false
```

When Prometheus is disabled, Kiali will still start and serve non-metrics features
such as workload/service/app listing, Istio configuration, and mesh topology.
However, the graph, metrics tabs, traffic tabs, and request-rate health will be
unavailable. Health badges for workloads and apps will degrade to show only
Kubernetes-level status (replica counts).

The UI will display a subtle informational message reminding you that metrics
features are unavailable due to your configuration choice.

### When Prometheus is Unreachable

When Prometheus is enabled (the default) but Kiali cannot reach it at startup,
Kiali will still start successfully with metrics features temporarily unavailable.

The UI will display a warning notification explaining why metrics are
unavailable. The Prometheus component will still appear in the masthead status
and the mesh topology page, reported as unhealthy, so you have clear visibility
into the misconfiguration.

To restore full metrics functionality after a startup failure, fix the Prometheus
connectivity issue (correct the URL, ensure the Prometheus server is running, etc.) and
restart Kiali.

### Configuring the Prometheus URL

By default, Kiali assumes that Prometheus is available at the URL of the form
`http://prometheus.<istio_namespace_name>:9090`, which is the usual case if you
are using [the Prometheus Istio
add-on](https://istio.io/latest/docs/ops/integrations/prometheus/#option-1-quick-start).
If your Prometheus instance has a different service name or is installed in a
different namespace, you must manually provide the endpoint where it is
available, like in the following example:

```yaml
spec:
  external_services:
    prometheus:
      # Prometheus service name is "metrics" and is in the "telemetry" namespace
      url: "http://metrics.telemetry:9090/"
```

{{% alert color="success" %}}
Notice that you don't need to expose Prometheus outside the cluster. It is
enough to provide the Kubernetes internal service URL.
{{% /alert %}}

Kiali maintains an internal cache of some Prometheus queries to improve
performance (mainly, the queries to calculate Health indicators). It
would be very rare to see data delays, but should you notice any delays you may
tune caching parameters to values that work better for your environment.

See the [Kiali CR reference page](/docs/configuration/kialis\.kiali\.io/#example-cr) for the current default values.

### Compatibility with Prometheus-like servers

Although Kiali assumes a Prometheus server and is tested against it, there are
<abbr title="Time series databases">TSDBs</abbr> that can be used as a Prometheus
replacement despite not implementing the full Prometheus API. 

Community users have faced two issues when using Prometheus-like TSDBs:
* Kiali may report that the TSDB is unreachable, and/or
* Kiali may show empty metrics if the TSBD does not implement the `/api/v1/status/config`.

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


### Prometheus tuning

For production optimization — recording rules, federation, metric thinning, scrape intervals, and retention — see [Tuning]({{< relref "./tuning" >}}).

### Prometheus authentication configuration

The Kiali CR provides authentication configuration that will be used also for querying the version check to provide information in the Mesh graph.

```yaml
spec:
  external_services:
    prometheus:
      auth:
        insecure_skip_verify: false
        password: "pwd"
        token: ""
        type: "basic"
        use_kiali_token: false
        username: "user"
      health_check_url: ""
```

To configure a secret to be used as a password, see this [FAQ entry]({{< relref "../../../FAQ/installation#how-can-i-use-a-secret-to-pass-external-service-credentials-to-the-kiali-server" >}}).

To authenticate using OAuth2 `client_credentials` flow (for example, Azure Monitor Managed Prometheus or any OAuth2-protected endpoint), set `type: "oauth2"` and provide the `oauth2` block:

```yaml
spec:
  external_services:
    prometheus:
      auth:
        type: "oauth2"
        oauth2:
          client_id: "my-client-id"
          client_secret: "secret:my-oauth2-secret:client_secret"
          token_url: "https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token"
          scopes:
          - "https://prometheus.monitor.azure.com/.default"
          audience: ""          # optional: some providers require this
          auth_style: "header"  # "header" (default) or "params"
```

The `client_secret` field supports the `secret:<secretName>:<secretKey>` pattern for automatic secret mounting and rotation without pod restart. See the [FAQ entry]({{< relref "../../../FAQ/installation#how-can-i-use-a-secret-to-pass-external-service-credentials-to-the-kiali-server" >}}) for details.

{{% alert color="warning" %}}
`insecure_skip_verify` applies only to the Prometheus connection, not to the OAuth2 token endpoint. The token endpoint always validates TLS certificates. To trust a private CA for the token endpoint, add the CA to the `kiali-cabundle` ConfigMap as described in the [TLS Configuration]({{< relref "../tls-configuration" >}}) page.
{{% /alert %}}

### TLS Certificate Configuration

If your Prometheus server uses HTTPS with a certificate issued by a private CA, see the [TLS Configuration]({{< relref "../tls-configuration" >}}) page to learn how to configure Kiali to trust your CA.
