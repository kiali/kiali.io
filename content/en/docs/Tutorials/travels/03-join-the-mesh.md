---
title: "Join the Mesh"
description: "Sidecar injection and ingress gateway."
weight: 3
---

## Sidecar Proxies

The Travel Demo was deployed in the previous chapter **without** Istio sidecar proxies. These are Envoy proxies that can be injected into the application pods.

Without a sidecar, workloads do not connect to the Istio control plane and do not report mesh telemetry (metrics, access logs, or distributed traces).

### Confirm in Kiali

As shown in [Install Travel Demo]({{< relref "./02-install-travel-demo" >}}), the demo namespaces appear on the **Namespaces** page with type **`-`** (*Not part of the mesh*):

![Travel Demo namespaces not in mesh](/images/tutorial/02-01-namespaces-not-in-mesh.png "Travel Demo namespaces not in mesh")

The **Overview** page still summarizes only what is in the mesh — Istio control plane counts should remain unchanged and data plane namespaces should stay at **0**.

On the **Graph** page, select the Travel Demo namespaces (`travel-control`, `travel-portal`, and `travel-agency`) in the namespace dropdown. Without sidecar proxies there is no request telemetry, so Kiali reports an empty graph:

![Empty Graph](/images/tutorial/03-01-empty-graph.png "Empty Graph")

The **Workloads** and **Applications** pages make the missing sidecars explicit. Open **Workloads**, select the `travel-control` namespace, and look for the missing-sidecar badge on the *control* workload:

![Missing Sidecar](/images/tutorial/03-01-missing-sidecar.png "Missing Sidecar")

## Enable Sidecars

In this tutorial we add namespaces and workloads to the service mesh one step at a time. That makes it easier to see how Istio sidecar injection works before the rest of the demo joins the mesh.

We start with the *control* workload in the *travel-control* namespace.

{{% alert title="Step 1" color="success" %}}
Enable Auto Injection on the *travel-control* namespace
{{% /alert %}}

1. Open **Namespaces**.
2. Click the **travel-control** namespace name to open its detail page.
3. Select **Actions** → **Enable Auto Injection**.
4. Confirm in the dialog.

This adds the `istio-injection=enabled` label to the namespace. Existing pods are **not** restarted yet — only new pods created after injection is enabled receive a sidecar automatically.

![Enable Auto Injection per Namespace](/images/tutorial/03-02-travel-control-namespace.png "Enable Auto Injection per Namespace")

{{% alert title="Step 2" color="success" %}}
Enable Auto Injection for the *control* workload
{{% /alert %}}

1. Open **Workloads**.
2. Select the **travel-control** namespace.
3. Click the **control** workload.
4. Select **Actions** → **Enable Auto Injection**.

Kiali updates the workload so the next pod receives an Istio sidecar. Kubernetes rolls out a new *control* pod; when it is ready you should see **2/2** containers (application + `istio-proxy`):

```
kubectl get pods -n travel-control
NAME                       READY   STATUS    RESTARTS   AGE
control-xxxxxxxxxx-xxxxx   2/2     Running   0          42s
```

![Enable Auto Injection per Workload](/images/tutorial/03-02-control-workload.png "Enable Auto Injection per Workload")

Understanding what happened:

[(i) Sidecar Injection](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/)

[(ii) Automatic Sidecar Injection](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#automatic-sidecar-injection)

## Open Travel Demo to Outside Traffic

The *control* workload now has an Istio sidecar, but the application is still not reachable from outside the cluster.

In this section you expose the *control* service through an Istio **Gateway** and route external HTTP traffic to it with a **VirtualService**.

{{% alert title="Step 1" color="success" %}}
Create a DNS entry for the *control* service using the external address of the Istio ingress gateway
{{% /alert %}}

{{% alert color="warning" %}}
There are several ways to provide a hostname for ingress depending on your platform. See Istio's [Determining the Ingress IP and Ports](https://istio.io/latest/docs/setup/getting-started/#determining-the-ingress-ip-and-ports) for general guidance.
{{% /alert %}}

{{% alert title="Kind" color="warning" %}}
If you created the cluster with `./hack/start-kind.sh`, MetalLB is already configured. `LoadBalancer` services such as `istio-ingressgateway` receive an external IP address.
{{% /alert %}}

For Kind, check the external IP of the ingress gateway:

```
kubectl get svc istio-ingressgateway -n istio-system
NAME                   TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)                                                                      AGE
istio-ingressgateway   LoadBalancer   10.101.6.144   10.101.6.144   15021:30757/TCP,80:32647/TCP,443:30900/TCP,31400:30427/TCP,15443:31072/TCP   19h
```

Add an entry to `/etc/hosts` on the machine where you run the browser (use your cluster's `EXTERNAL-IP`):

```
...
10.101.6.144 control.travel-control.istio-cluster.org
...
```

From that machine, `control.travel-control.istio-cluster.org` resolves to the Istio ingress gateway.

{{% alert title="Kind" color="warning" %}}
If `EXTERNAL-IP` stays `<pending>`, confirm MetalLB is running: `kubectl get pods -n metallb-system`
{{% /alert %}}

{{% alert title="OpenShift" color="warning" %}}
OpenShift does not populate Kubernetes `EXTERNAL-IP` for `LoadBalancer` services the same way. Expose the ingress gateway as a route instead.
{{% /alert %}}

For OpenShift, expose the ingress gateway as a route:

```
oc expose service istio-ingressgateway -n istio-system
oc get routes -n istio-system
NAME                   HOST/PORT                                  PATH   SERVICES               PORT    TERMINATION          WILDCARD
istio-ingressgateway   <YOUR_ROUTE_HOST>                                 istio-ingressgateway   http2                        None
```

Use `<YOUR_ROUTE_HOST>` wherever this chapter shows `control.travel-control.istio-cluster.org` (no `/etc/hosts` entry is required on OpenShift).

{{% alert title="Step 2" color="success" %}}
Use the Request Routing wizard on the *control* service
{{% /alert %}}

1. Open **Services**.
2. Select the **travel-control** namespace.
3. Click the **control** service.
4. Select **Actions** → **Request Routing**.

Use **Add Route Rule** to add a default rule that sends all requests to the *control* workload.

![Request Routing Wizard](/images/tutorial/03-03-service-actions.png "Request Routing Wizard")

![Routing Rule](/images/tutorial/03-03-request-routing.png "Routing Rule")

Open **Show advanced options**, select the **Gateways** tab, enable **Add Gateway**, choose **Create Gateway**, and set the gateway host to `control.travel-control.istio-cluster.org` (port **80**).

![Create Gateway](/images/tutorial/03-03-create-gateway.png "Create Gateway")

Before clicking **Create**, review the DestinationRule, Gateway, and VirtualService generated by the wizard:

![Gateway Config](/images/tutorial/03-03-gateway-config.png "Gateway Config")

Click **Create** to apply the configuration.

On the **Istio Config** page, confirm the new objects were created and validated in the `travel-control` namespace:

![Istio Config](/images/tutorial/03-03-istio-config.png "Istio Config")

{{% alert title="Step 3" color="success" %}}
Test the *control* service in your browser
{{% /alert %}}

Open http://control.travel-control.istio-cluster.org/ (on OpenShift, use your route host instead).

You should see the Travel Demo business dashboard — the same UI you previewed with `kubectl port-forward` in the previous chapter, now reachable through the mesh ingress.

![Test Gateway](/images/tutorial/03-03-test-gateway.png "Test Gateway")

{{% alert title="Step 4" color="success" %}}
Review the *travel-control* namespace in Kiali
{{% /alert %}}

Open the **Graph** page, select the **travel-control** namespace, and refresh if needed. After browsing the dashboard, Kiali should show request telemetry from the ingress gateway through the *control* workload.

The graph may also show *travel-portal* services as destinations of outbound traffic from *control*. Only the *control* workload has a sidecar at this point — workloads in *travel-portal* and *travel-agency* still show missing sidecars on the **Workloads** page.

![Travel Control Graph](/images/tutorial/03-03-travel-control-graph.png "Travel Control Graph")

Understanding what happened:

- External traffic enters the cluster through an Istio **Gateway** bound to the ingress gateway.
- A **VirtualService** routes that traffic to the *control* service.
- The *control* sidecar reports telemetry that Kiali displays on the graph.
- Only the *control* workload participates in the mesh so far; the remaining demo workloads are added in [Observe the Mesh]({{< relref "./04-observe-the-mesh" >}}).

[(i) Istio Gateway](https://istio.io/latest/docs/reference/config/networking/gateway/)

[(ii) Istio Virtual Service](https://istio.io/latest/docs/reference/config/networking/virtual-service/)
