---
title: "Authentication"
description: "Questions about authentication strategy or configuration."
---


### How to obtain a token when logging in via token auth strategy

When configuring Kiali to use the `token` auth strategy, it requires users to log into Kiali as a specific user via the user's service account token. Thus, in order to log into Kiali you must provide a valid Kubernetes token.

You can extract a service account's token from the secret that was created for you when you created the service account.

For example, if you want to log into Kiali using Kiali's own service account, you can get the token like this:

```
kubectl get secret -n istio-system $(kubectl get sa kiali-service-account -n istio-system -o "jsonpath={.secrets[0].name}") -o jsonpath={.data.token} | base64 -d
```

Note that this example assumes you installed Kiali in the `istio-system` namespace.

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

