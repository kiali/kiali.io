---
title: "Accessing Kiali"
description: "Accessing and exposing the Kiali UI."
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

These commands will block. Access Kiali by visiting `https://localhost:20001/` in
your preferred web browser.

{{% alert color="danger" %}}
Please note that this method exposes Kiali *only* to the local machine, no external users.  You must
have the necessary privileges to perform port forwarding.
{{% /alert %}}

## Accessing Kiali through an Ingress {#ingress-access}

You can configure Kiali to be installed with an
[Ingress resource](https://github.com/kiali/kiali-operator/blob/master/roles/default/kiali-deploy/templates/kubernetes/ingress.yaml)
defined, allowing you to access
the Kiali UI through the Ingress. By default, an Ingress will not be created. You can
enable a simple Ingress by setting `spec.deployment.ingress.enabled` to `true` in the Kiali
CR (a similar setting for the server Helm chart is available if you elect to install Kiali
via Helm as opposed to the Kiali Operator).

Exposing Kiali externally through this `spec.deployment.ingress` mechanism is a
convenient way of exposing Kiali externally but it will not necessarily work or
be the best way to do it because the way in which you should expose Kiali
externally will be highly dependent on your specific cluster environment and
how services are exposed generally for that environment.

{{% alert color="info" %}}
When installing on an OpenShift cluster, an OpenShift Route will be installed (not an Ingress).
This Route *will* be installed by default unless you explicitly
disable it via `spec.deployment.ingress.enabled: false`. Note that the Route is required
if you configure Kiali to use the auth strategy of `openshift` (which is the default
auth strategy Kiali will use when installed on OpenShift).
{{% /alert %}}

The default Ingress that is created will be configured for a typical NGinx implementation. If you have your own
Ingress implementation you want to use, you can override the default configuration through
the settings `spec.deployment.ingress.override_yaml` and `spec.deployment.ingress.class_name`.
More details on customizing the Ingress can be found below.

The Ingress IP or domain name should then be used to access the Kiali UI. To find your Ingress IP or domain name, as per
[the Kubernetes documentation](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#create-an-ingress),
try the following command (though this may not work if using Minikube without the ingress addon):

```
kubectl get ingress kiali -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

If it doesn't work, unfortunately, it depends on how and where you had setup
your cluster. There are several Ingress controllers available and some cloud
providers have their own controller or preferred exposure method. Check
the documentation of your cloud provider. You may need to customize the
pre-installed Ingress rule or expose Kiali using a different method.

### Customizing the Ingress resource

The created Ingress resource will route traffic to Kiali regardless of the domain in the URL.
You may need a more specific Ingress resource that routes traffic
to Kiali only on a specific domain or path. To do this, you can [specify route settings](#route-configs).

Alternatively, and for more advanced Ingress configurations, you can provide your own
Ingress declaration in the Kiali CR. For example:

{{% alert color="info" %}}
When installing on an OpenShift cluster, the `deployment.ingress.override_yaml` will be applied
to the created Route. The `deployment.ingress.class_name` is ignored on OpenShift.
{{% /alert %}}

```yaml
spec:
  deployment:
    ingress:
      class_name: "nginx"
      enabled: true
      override_yaml:
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

If you [enabled the Ingress controller](https://kubernetes.io/docs/tasks/access-application-cluster/ingress-minikube/#enable-the-ingress-controller),
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

Once the Kiali operator updates the installation, you should be able to use
the `kubectl get svc -n istio-system kiali` command to retrieve the external
address (or port) to access Kiali. For example, in the following output Kiali
is assigned the IP `192.168.49.201`, which means that you can access Kiali by
visiting `http://192.168.49.201:20001` in a browser:

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

By default, Kiali is exposed through a Route if installed on OpenShift. The following command
should open Kiali in your default web browser:

```
xdg-open https://$(oc get routes -n istio-system kiali -o jsonpath='{.spec.host}')/console
```

## Specifying route settings {#route-configs}

If you are using your own exposure method or if you are using one of
the methods mentioned in this page, you may need to configure the route that is
being used to access Kiali.

In the Kiali CR, route settings are broken in several attributes. For example,
to specify that Kiali is being accessed under the
`https://apps.example.com:8080/dashboards/kiali` URI, you would need to set the
following:

```yaml
spec:
  server:
    web_fqdn: apps.example.com
    web_port: 8080
    web_root: /dashboards/kiali
    web_schema: https
```

If you are letting the installation create an [Ingress resource for you](#ingress-access),
the Ingress will be adjusted to match these route settings.
If you are using your own exposure method, these spec.server settings are only making Kiali aware
of what its public endpoint is.

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
that the Kiali's public route be properly discoverable or that it is properly
configured; most notably, the [OpenID authentication]({{< ref "/docs/configuration/authentication/openid" >}}).
{{% /alert %}}

## Configuring listening ports

{{% alert color="success" %}}
Usually, these settings need to be changed only if you are directly
exposing the Kiali service (like when using a `LoadBalancer` service type).
{{% /alert %}}

It is possible to configure the listening ports of the Kiali service to use
your preferred ones:

```yaml
spec:
  server:
    port: 80 # Main port for accessing Kiali
    metrics_port: 8080
```

