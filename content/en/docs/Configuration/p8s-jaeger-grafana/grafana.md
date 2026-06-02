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
Grafana options.

The Grafana links will appear in the Kiali metrics pages. For example:

![Kiali Grafana Links](/images/documentation/configuration/grafana-link.png)

For these links to appear in Kiali you need to manually configure the Grafana URL
and the dashboards that come preconfigured with Istio, like in the following example:

{{% alert color="warning" %}}
Kiali will query Grafana and try to fetch the configured dashboards.  For this reason Kiali must be able to reach Grafana, authenticate, and find the Istio dashboards. The Istio dashboards must be installed in Grafana for the links to appear in Kiali.
{{% /alert %}}

```yaml
spec:
  external_services:
    grafana:
      enabled: true
      # Grafana service name is "grafana" and is in the "telemetry" namespace.
      internal_url: 'http://grafana.telemetry:3000/'
      # Public facing URL of Grafana
      external_url: 'http://my-ingress-host/grafana'
      # Grafana datasource UID when there are multiple
      datasource_uid: ""
      dashboards:
      - name: "Istio Service Dashboard"
        variables:
          datasource: "var-datasource"
          namespace: "var-namespace"
          service: "var-service"
      - name: "Istio Workload Dashboard"
        variables:
          datasource: "var-datasource"          
          namespace: "var-namespace"
          workload: "var-workload"
          datasource: "var-datasource"
      - name: "Istio Mesh Dashboard"
      - name: "Istio Control Plane Dashboard"
      - name: "Istio Performance Dashboard"
      - name: "Istio Wasm Extension Dashboard"
```

{{% alert color="warning" %}}
The described configuration is done in the Kiali CR when Kiali is installed using the Kiali Operator. If Kiali is installed with the Helm chart then the correct way to configure this is via regular --set flags.
{{% /alert %}}

### Grafana authentication configuration

The Kiali CR provides authentication configuration that will be used to connect to your Grafana instance and for detecting your Grafana version in the Mesh graph.

```yaml
spec:
  external_services:
    grafana:
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

To configure a secret to be used as a password, see this [FAQ entry]({{< relref "../../FAQ/installation#how-can-i-use-a-secret-to-pass-external-service-credentials-to-the-kiali-server" >}}).

To authenticate using OAuth2 `client_credentials` flow, set `type: "oauth2"` and provide the `oauth2` block:

```yaml
spec:
  external_services:
    grafana:
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

The `client_secret` field supports the `secret:<secretName>:<secretKey>` pattern for automatic secret mounting and rotation without pod restart. See the [FAQ entry]({{< relref "../../FAQ/installation#how-can-i-use-a-secret-to-pass-external-service-credentials-to-the-kiali-server" >}}) for details.

{{% alert color="warning" %}}
`insecure_skip_verify` applies only to the Grafana connection, not to the OAuth2 token endpoint. The token endpoint always validates TLS certificates. To trust a private CA for the token endpoint, add the CA to the `kiali-cabundle` ConfigMap as described in the [TLS Configuration]({{< relref "./tls-configuration" >}}) page.
{{% /alert %}}

### TLS Certificate Configuration

If your Grafana server uses HTTPS with a certificate issued by a private CA, see the [TLS Configuration]({{< relref "./tls-configuration" >}}) page to learn how to configure Kiali to trust your CA.
