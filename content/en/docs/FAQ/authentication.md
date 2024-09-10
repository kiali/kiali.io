---
title: "Authentication"
description: "Questions about authentication strategy or configuration."
---


### How to obtain a token when logging in via token auth strategy

When configuring Kiali to use the `token` auth strategy, it requires users to log into Kiali as a specific user via the user's service account token. Thus, in order to log into Kiali you must provide a valid Kubernetes token.

Note that the following examples assume you installed Kiali in the `istio-system` namespace.

**For Kubernetes prior to v1.24**

You can extract a service account's token from the secret that was created for you when you created the service account.

For example, if you want to log into Kiali using Kiali's own service account, you can get the token like this:

```
kubectl get secret -n istio-system $(kubectl get sa kiali-service-account -n istio-system -o "jsonpath={.secrets[0].name}") -o jsonpath={.data.token} | base64 -d
```

**For Kubernetes v1.24+**

You can request a short lived token for a service account by issuing the following command:

```
kubectl -n istio-system create token kiali-service-account
```

**Using the token**

Once you obtain the token, you can go to the Kiali login page and copy-and-paste that token into the token field. At this point, you have logged into Kiali with the same permissions as that of the Kiali server itself (note: this gives the user the permission to see everything).

Create different service accounts with different permissions for your users to use. Each user should only have access to their own service accounts and tokens.


### How to configure the originating port when Kiali is served behind a proxy (OpenID support)

When using OpenID strategy for authentication and deploying Kiali behind a reverse proxy or a load balancer, Kiali needs to know the originating port of client requests. You may need to setup your proxy to inject a `X-Forwarded-Port` HTTP header when forwarding the request to Kiali.

For example, when using an Istio Gateway and VirtualService to expose Kiali, you could use the [headers property](https://istio.io/latest/docs/reference/config/networking/virtual-service/#Headers) of the route:

```yaml
spec:
  gateways:
  - istio-ingressgateway.istio-system.svc.cluster.local
  hosts:
  - kiali.abccorp.net
  http:
  - headers:
      request:
        set:
          X-Forwarded-Port: "443"
    route:
    - destination:
        host: kiali
        port:
          number: 20001
```

### How to configure a secret as password for external services

The external services as [Prometheus]({{< relref "../Configuration/p8s-jaeger-grafana/prometheus" >}}), [Grafana]({{< relref "../Configuration/p8s-jaeger-grafana/grafana" >}}), [Jaeger]({{< relref "../Configuration/p8s-jaeger-grafana/tracing/jaeger" >}}) or [Tempo]({{< relref "../Configuration/p8s-jaeger-grafana/tracing/tempo" >}}), can use a secret in order to specify the password for authentication. 

1. Create a secret with the prometheus password in it. The key must be value.txt:
```
kubectl -n istio-system create secret generic my-prom-secret --from-literal=value.txt=my-own-password
```

2. Create a values file that:

* Defines a custom secret and mounts it to the place that Kiali Server expects to see it
* Tell Kiali to use that secret for the prometheus password:

```
 deployment:
   custom_secrets:
   - name: "my-prom-secret"
     mount: "/kiali-override-secrets/prometheus-password"
```

The custom folders should be one of the following: 

- grafana-password
- grafana-token
- prometheus-password
- prometheus-token
- tracing-password
- tracing-token
- login-token-signing-key

```
 external_services:
   prometheus:
     auth:
       password: "secret:my-prom-secret:value.txt"
```

3. Install with the server helm chart using that values file:

```
helm install \
    --namespace istio-system \
    --set deployment.custom_secrets[0].name="my-prom-secret" \
    --set deployment.custom_secrets[0].mount="/kiali-override-secrets/prometheus-password" \
    --set external_services.prometheus.auth.password="secret:my-prom-secret:value.txt" \
    --set auth.strategy="anonymous" \
    --set deployment.logger.log_level="debug" \
    kiali-server \
    kiali/kiali-server
```

If this works, there should be a debug log message in the kiali server:
```
2024-09-10T09:56:24Z DBG Credentials loaded from secret file [/kiali-override-secrets/prometheus-password/value.txt]
```