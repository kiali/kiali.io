---
title: "Jaeger"
description: >
  This page describes how to configure Jaeger for Kiali.
weight: 1
---

## Jaeger configuration

Jaeger is a _highly recommended_ service because [Kiali uses distributed
tracing data for several features]({{< relref "../../../Features/tracing" >}}),
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
      internal_url: "http://tracing.telemetry:16685/jaeger"
      use_grpc: true
      # Public facing URL of Jaeger
      external_url: "http://my-jaeger-host/jaeger"
```

Minimally, you must provide `spec.external_services.tracing.internal_url` to
enable Kiali features that use distributed tracing data. However, Kiali can
provide contextual links that users can use to jump to the Jaeger console to
inspect tracing data more in depth. For these links to be available you need to
set the `spec.external_services.tracing.external_url` to the URL where you
expose Jaeger outside the cluster.

{{% alert color="success" %}}
Default values for connecting to Jaeger are based on the [Istio's provided
sample add-on manifests](https://github.com/istio/istio/tree/master/samples/addons).
If your Jaeger setup differs significantly from the sample add-ons, make sure
that Istio is also properly configured to push traces to the right URL.
{{% /alert %}}

### Jaeger authentication configuration

The Kiali CR provides authentication configuration that will be used also for querying the version check to provide information in the Mesh graph.

```yaml
spec:
  external_services:
    tracing:
      enabled: true
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

To authenticate using OAuth2 `client_credentials` flow, set `type: "oauth2"` and provide the `oauth2` block:

```yaml
spec:
  external_services:
    tracing:
      use_grpc: false           # must be false; oauth2 token injection is not implemented for gRPC transport
      auth:
        type: "oauth2"
        oauth2:
          client_id: "my-client-id"
          client_secret: "secret:my-oauth2-secret:client_secret"
          token_url: "https://idp.example.com/token"
          scopes: []            # optional: list of OAuth2 scopes to request
          audience: ""          # optional: some providers require this
          auth_style: "header"  # "header" (default) or "params"
```

{{% alert color="warning" %}}
OAuth2 authentication requires `use_grpc: false`. OAuth2 token injection is not implemented for gRPC transport.
{{% /alert %}}

{{% alert color="warning" %}}
`insecure_skip_verify` applies only to the Jaeger connection, not to the OAuth2 token endpoint. The token endpoint always validates TLS certificates. To trust a private CA for the token endpoint, add the CA to the `kiali-cabundle` ConfigMap as described in the [TLS Configuration]({{< relref "../tls-configuration" >}}) page.
{{% /alert %}}

The `client_secret` field supports the `secret:<secretName>:<secretKey>` pattern for automatic secret mounting and rotation without pod restart. See the [FAQ entry]({{< relref "../../../FAQ/installation#how-can-i-use-a-secret-to-pass-external-service-credentials-to-the-kiali-server" >}}) for details.

### TLS Certificate Configuration

If your Jaeger server uses HTTPS with a certificate issued by a private CA, see the [TLS Configuration]({{< relref "../tls-configuration" >}}) page to learn how to configure Kiali to trust your CA.
