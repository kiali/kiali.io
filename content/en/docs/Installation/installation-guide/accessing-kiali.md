---
title: "Accessing and exposing Kiali"
date: 2021-09-12T00:00:00+00:00
draft: false
weight: 50
---

## Introduction

After Kiali is succesfully installed you will need to make Kiali accessible to users.  This page describes some popular methods of exposing Kiali for use.

If exposing Kiali in a custom way,  you may need to [set some configurations](#route-configs)
to make Kiali aware of how users will access Kiali.

{{% alert color="warning" %}}
The examples on this page assume that you followed the [Installation guide]({{< ref "/docs/installation/installation-guide" >}}) to install Kiali, and that you
installed Kiali in the `istio-system` namespace.
{{% /alert %}}


## Accessing Kiali using port forwarding

{{% alert color="success" %}}
This method should work in any kind of Kubernetes cluster.
{{% /alert %}}

You can use port-forwarding to access Kiali by running any of these commands:

```
# If you have oc command line tool
oc port-forward svc/kiali 20001:20001 -n istio-system
# If you have kubectl command line tool
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

These commands will block. Access Kiali by visiting `\https://localhost:20001/` in
your preferred web browser.

{{% alert color="danger" %}}
Please note that this method exposes Kiali *only* to the local machine, no external users.  You must
have the necessary privileges to perform port forwarding.
{{% /alert %}}

## Accessing Kiali through an Ingress {#ingress-access}

By default, the installation exposes Kiali creating an
[Ingress resource](https://github.com/kiali/kiali-operator/blob/master/roles/default/kiali-deploy/templates/kubernetes/ingress.yaml).
Find out your Ingress IP or domain name and use it to access Kiali by
visiting this URL in your web browser:
`https://_your_ingress_ip_or_domain_/kiali`.

To find your Ingress IP or domain name, as per
[the Kubernetes documentation](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#create-an-ingress-resource),
try the following command (doesn't work if using Minikube):

```
kubectl get ingress kiali -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

If it doesn't work, unfortunately, it depends on how and where you had setup
your cluster. There are several Ingress controllers available and some cloud
providers have their own controller or preferred exposure method. Please, check
the documentation of your cloud provider. You may need to customize the
pre-installed Ingress rule, or to expose Kiali using a different method.

### Customizing the Ingress resource

By default, a catch-all Ingress resource is created to route traffic to Kiali.
Most likely, you will need a more specific Ingress resource that routes traffic
to Kiali only on a specific domain or path. To do this, you can [specify route settings](#route-configs).

Alternatively, and for more advanced Ingress configurations, you can provide your own
Ingress declaration in the Kiali CR. For example:

```yaml
spec:
  deployment:
    override_ingress_yaml:
      metadata:
        annotations:
          nginx.ingress.kubernetes.io/secure-backends: "true"
          nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
      spec:
        rules:
        - http:
            paths:
            - path: /kiali
              backend:
                serviceName: kiali
                servicePort: 20001
```

## Accessing Kiali in Minikube

If you [enabled the Ingress controller]https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#enable-the-ingress-controller,
the default Ingress resource created by the installation (mentioned in the previous section) should be enough to access
Kiali. The following command should open Kiali in your default web browser:

```
xdg-open https://$(minikube ip)/kiali
```

## Accessing Kiali through a LoadBalancer or a NodePort

By default, the Kiali service is created with the `ClusterIP` type. To use a
`LoadBalancer` or a `NodePort`, you can change the service type in the Kiali CR as
follows:

```yaml
spec:
  deployment:
    service_type: LoadBalancer
```

Once the Kiali operator to updates the installation, you should be able to use
the `kubectl get svc -n istio-system kiali` command to retrieve the external
address (or port) to access Kiali. For example, in the following output Kiali
is assigned the IP `192.168.49.201`, which means that you can access Kiali by
visiting \http://192.168.49.201:20001 in a browser:

```
NAME    TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)                          AGE
kiali   LoadBalancer   10.105.236.127   192.168.49.201   20001:31966/TCP,9090:30128/TCP   34d
```

## Accessing Kiali through an Istio Ingress Gateway

If you want to take advantage of Istio's infrastructure, you can expose Kiali
using an Istio Ingress Gateway. The Istio documentation provides a
[good guide explaining how to expose the sample add-ons](https://istio.io/latest/docs/tasks/observability/gateways/).
Even if the Istio guide is focused on the sample add-ons, the steps are the same to expose a Kiali
installed using this [Installation guide]({{< ref "/docs/installation/installation-guide" >}}).

## Accessing Kiali in OpenShift

By default, installation exposes Kiali through a Route. The following command
should open Kiali in your default web browser:

```
xdg-open https://$(oc get routes -n istio-system kiali -o jsonpath='{.spec.host}')/console
```

## Specifying route settings {#route-configs}

Either if you are using your own exposure method, or if you are using one of
the methods mentioned in this page, you may need to configure the route that is
being used to access Kiali.

In the Kiali CR, route settings are broken in several attributes. For example,
to specify that Kiali is being accessed under the
`\https://apps.example.com:8080/dashboards/kiali` URI, you would need to set the
following:

```yaml
spec:
  server:
    web_fqdn: apps.example.com
    web_port: 8080
    web_root: /dashboards/kiali
    web_schema: https
```

If you are letting the installation to create an [Ingress resource for you](#ingress-access),
the Ingress will be adjusted to match these route settings.
If you are using your own exposure method, this is only making Kiali aware
about what is its public endpoint.

It is possible to omit these settings and Kiali may be able to discover some of
these configurations, depending on your exposure method. For example, if you
are exposing Kiali via `LoadBalancer` or `NodePort` service types, Kiali can
discover most of these settings. If you are using some kind of Ingress, Kiali
will honor `X-Forwarded-Proto`, `X-Forwarded-Host` and `X-Forwarded-Port` HTTP
headers if they are properly injected in the request.

The `web_root` receives special treatment, because this is the path where Kiali
will serve itself (both the user interface and its api). This is useful if you
are serving multiple applications under the same domain. It must begin with a
slash and trailing slashes must be omitted. The default value is `/kiali` for
Kubernetes and `/` for OpenShift.

{{% alert color="warning" %}}
Usually, these settings can be omitted. However, a few features require
that the Kiali's public route can be properly discovered or that is properly
configured; most notably, the [OpenID authentication]({{< ref "/docs/configuration/authentication/openid" >}}).
{{% /alert %}}

## Configuring listening ports

{{% alert color="success" %}}
Usually, these settings need to be changed only if you are directly
exposing the Kiali serivce (like when using a `LoadBalancer` service type).
{{% /alert %}}

It is possible to configure the listening ports of the Kiali service to use
your preferred ones:

```yaml
spec:
  server:
    port: 80 # Main port for accessing Kiali
    metrics_port: 8080
```

