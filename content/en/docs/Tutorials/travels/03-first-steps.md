---
title: "First Steps"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 3
---

## Missing Sidecars

The Travel Demo has been deployed in the previous step but without installing any Istio sidecar proxy.

In that case, the application won't connect to the control plane and won't take advantage of Istio's features.

In Kiali, we will see the new namespaces in the overview page:

![Overview](/images/tutorial/03-01-overview.png "Overview")

But we won't see any traffic in the graph page for any of these new namespaces:

![Empty Graph](/images/tutorial/03-01-empty-graph.png "Empty Graph")

If we examine the Applications, Workloads or Services page, it will confirm that there are missing sidecars:

![Missing Sidecar](/images/tutorial/03-01-missing-sidecar.png "Missing Sidecar")

## Enable Sidecars

In this tutorial, we will add namespaces and workloads into the ServiceMesh individually step by step.

This will help you to understand how Istio sidecar proxies work and how applications can use Istio's features.

We are going to start with the *control* workload deployed into the *travel-control* namespace:

{{% alert title="Step 1" color="success" %}}
Enable Auto Injection on the *travel-control* namespace
{{% /alert %}}

![Enable Auto Injection per Namespace](/images/tutorial/03-02-travel-control-namespace.png "Enable Auto Injection per Namespace")

{{% alert title="Step 2" color="success" %}}
Enable Auto Injection for *control* workload
{{% /alert %}}

![Enable Auto Injection per Workkload](/images/tutorial/03-02-control-workload.png "Enable Auto Injection per Workkload")

Understanding what happened:

[(i) Sidecar Injection](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)

[(ii) Injection Concepts](https://istio.io/latest/docs/ops/configuration/mesh/injection-concepts/)

## Open Travel Demo to Outside Traffic

The *control* workload now has an Istio sidecar proxy injected but this application is not accessible from the outside.

In this step we are going to expose the *control* service using an Istio Ingress Gateway which will map a path to a route at the edge of the mesh.

{{% alert title="Step 1" color="success" %}}
Create a DNS entry for the *control* service associated with the External IP of the Istio Ingress
{{% /alert %}}

{{% alert color="warning" %}}
There are multiple ways to create a DNS entry depending of the platform, servers or services that you are using. 
This step depends on the platform you have chosen, please review [Determining the Ingress IP and Ports](https://istio.io/latest/docs/setup/getting-started/#determining-the-ingress-ip-and-ports) for more details.
{{% /alert %}}

{{% alert title="Minikube" color="warning" %}}
Kubernetes Service EXTERNAL-IP for "LoadBalancer" TYPE is provided in minikube plaform using the [minikube tunnel](https://minikube.sigs.k8s.io/docs/handbook/accessing/#using-minikube-tunnel) tool.
{{% /alert %}}

For minikube we will check the External IP of the Ingress gateway:

```
$ kubectl get services/istio-ingressgateway -n istio-system
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                                                                      AGE
istio-ingressgateway   LoadBalancer   10.101.6.144   10.101.6.144   15021:30757/TCP,80:32647/TCP,443:30900/TCP,31400:30427/TCP,15443:31072/TCP   19h
```

And we will add a simple entry to the `/etc/hosts` of the tutorial machine with the desired DNS entry:

```
...
10.101.6.144 control.travel-control.istio-cluster.org
...
```

Then, from this machine, the url `control.travel-control.istio-cluster.org` will resolve to the External IP of the Ingress Gateway of Istio.

{{% alert title="OpenShift" color="warning" %}}
OpenShift does not provide the Kubernetes Service EXTERNAL-IP for "LoadBalancer" TYPE. Instead, you can expose the istio-ingressgateway service.
{{% /alert %}}

For OpenShift we will expose the Ingress gateway as a service:

```
$ oc expose service istio-ingressgateway -n istio-system
$ oc get routes -n istio-system
NAME                   HOST/PORT                                  PATH   SERVICES               PORT    TERMINATION          WILDCARD
istio-ingressgateway   <YOUR_ROUTE_HOST>                                 istio-ingressgateway   http2                        None
```

Then, from this machine, the host <YOUR_ROUTE_HOST> will resolve to the External IP of the Ingress Gateway of Istio. For OpenShift we will
not define a DNS entry, instead, where you see `control.travel-control.istio-cluster.org` in the steps below, subsitute the value of <YOUR_ROUTE_HOST>.


{{% alert title="Step 2" color="success" %}}
Use the Request Routing Wizard on the *control* service to generate a traffic rule
{{% /alert %}}

![Request Routing Wizard](/images/tutorial/03-03-service-actions.png "Request Routing Wizard")

Use "Add Route Rule" button to add a default rule where any request will be routed to the *control* workload.

![Routing Rule](/images/tutorial/03-03-request-routing.png "Routing Rule")

Use the Advanced Options and add a gateway with host `control.travel-control.istio-cluster.org` and create the Istio config.

![Create Gateway](/images/tutorial/03-03-create-gateway.png "Create Gateway")

Verify the Istio configuration generated.

![Istio Config](/images/tutorial/03-03-istio-config.png "Istio Config")

{{% alert title="Step 3" color="success" %}}
Test the *control* service by pointing your browser to `\http://control.travel-control.istio-cluster.org`
{{% /alert %}}

![Test Gateway](/images/tutorial/03-03-test-gateway.png "Test Gateway")

{{% alert title="Step 4" color="success" %}}
Review *travel-control* namespace in Kiali
{{% /alert %}}

![Travel Control Graph](/images/tutorial/03-03-travel-control-graph.png "Travel Control Graph")

Understanding what happened:

- External traffic enters into the cluster through a Gateway
- Traffic is routed to the *control* service through a VirtualService
- Kiali Graph visualizes the traffic telemetry reported from the *control* sidecar proxy
  - Only the *travel-control* namespace is part of the mesh

[(i) Istio Gateway](https://istio.io/latest/docs/reference/config/networking/gateway/)

[(ii) Istio Virtual Service](https://istio.io/latest/docs/reference/config/networking/virtual-service/)

