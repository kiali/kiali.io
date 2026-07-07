---
title: "Prerequisites"
description: "How to prepare for running the tutorial."
weight: 1
---

## Platform Setup

This tutorial assumes you will have access to a Kubernetes cluster with Istio installed.

This tutorial is being updated and qualified using:

* a [Kind](https://kind.sigs.k8s.io/) (Kubernetes in Docker) cluster with Helm-based Kiali install.
* an [OpenShift](https://istio.io/latest/docs/setup/platform-setup/openshift/) cluster with Kiali Operator install (qualification pending).

{{% alert title="Tip" color="warning" %}}
Platform dependent tasks will be indicated with a special note like this.
{{% /alert %}}

{{% alert color="warning" %}}
Version pins will be recorded here as the tutorial is re-qualified. Use current stable releases of Kind, Istio, and Kiali unless noted otherwise.
{{% /alert %}}

## Setup a Kind Cluster

Kind runs a local Kubernetes cluster using Docker. Istio and this tutorial also require a way to assign external IPs to `LoadBalancer` services (for the Istio ingress gateway).

### Prerequisites

Install the following tools:

* [Docker](https://docs.docker.com/get-docker/)
* [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Helm](https://helm.sh/docs/intro/install/) v3

The Istio install script in the next section downloads Istio (including `istioctl`) if it is not already present.

### Create the cluster

The Kiali project provides a script that creates a Kind cluster with MetalLB configured for `LoadBalancer` services. If you have the [Kiali source repository](https://github.com/kiali/kiali), run:

```
./hack/start-kind.sh --name travels-tutorial
```

This creates a two-node Kind cluster named `travels-tutorial` with a MetalLB load balancer. Verify the cluster context:

```
kubectl config use-context kind-travels-tutorial
kubectl cluster-info
```

{{% alert title="Kind" color="warning" %}}
If you prefer not to use the Kiali script, follow the [Kind load balancer guide](https://kind.sigs.k8s.io/docs/user/loadbalancer/) to enable `LoadBalancer` services before installing Istio.
{{% /alert %}}

## Install Istio

### Kind

The Kiali project provides a script that installs Istio with the **demo** profile and telemetry addons (Prometheus, Grafana, Jaeger). From the [Kiali source repository](https://github.com/kiali/kiali), run:

```
./hack/istio/install-istio-via-istioctl.sh -c kubectl -cp demo
```

This downloads Istio (if needed), installs the control plane and ingress gateway, and deploys the addons used later in this tutorial.

Verify the installation:

```
kubectl get pods -n istio-system
kubectl get svc istio-ingressgateway -n istio-system
```

The `istio-ingressgateway` service should show an `EXTERNAL-IP` (MetalLB assigns this on Kind). [Join the Mesh]({{< relref "./03-join-the-mesh" >}}) uses that address for ingress.

{{% alert title="Kind" color="warning" %}}
If `istio-ingressgateway` stays `<pending>`, confirm MetalLB is running: `kubectl get pods -n metallb-system`
{{% /alert %}}

{{% alert color="info" %}}
Prefer to install Istio yourself? Follow the [Istio Getting Started](https://istio.io/latest/docs/setup/getting-started/) guide using the **demo** profile, and install the Prometheus and Jaeger addons from `${ISTIO_HOME}/samples/addons/`.
{{% /alert %}}

### OpenShift

Follow the [Istio OpenShift platform setup](https://istio.io/latest/docs/setup/platform-setup/openshift/) to install Istio on your cluster.

Alternatively, from the [Kiali source repository](https://github.com/kiali/kiali), the install script defaults to the **openshift** profile when using `oc`:

```
./hack/istio/install-istio-via-istioctl.sh -c oc
```

Verify the control plane is running:

```
oc get pods -n istio-system
```

[Join the Mesh]({{< relref "./03-join-the-mesh" >}}) uses an OpenShift route to expose the ingress gateway.

## Install Kiali

Remove any Kiali installed from the Istio addons bundle before proceeding (set `ISTIO_HOME` to your Istio install directory, or the path under `kiali/_output/` if you used the hack script):

```
kubectl delete -f ${ISTIO_HOME}/samples/addons/kiali.yaml --ignore-not-found
```

This tutorial uses different install methods depending on the platform. On Kind, a standalone Helm install keeps setup minimal. On OpenShift, install via the Kiali Operator — the [recommended production method]({{< ref "/docs/Installation/installation-guide" >}}).

### Kind

Install the Kiali server using the [Quick Start Helm instructions]({{< ref "/docs/Installation/quick-start#install-via-helm" >}}). The Istio install above deploys Jaeger, but Kiali does not enable tracing integration by default — enable it explicitly:

```
helm install \
  --namespace istio-system \
  --set auth.strategy="anonymous" \
  --set external_services.tracing.enabled=true \
  --set external_services.tracing.external_url="http://tracing.istio-system:16685/jaeger" \
  --repo https://kiali.org/helm-charts \
  kiali-server \
  kiali-server
```

Wait for the Kiali deployment to become ready:

```
kubectl rollout status deployment/kiali -n istio-system --timeout=300s
kubectl get pods,svc -n istio-system -l app.kubernetes.io/name=kiali
```

Confirm tracing is configured (the `enabled` field should be `true`):

```
kubectl get configmap kiali -n istio-system -o jsonpath='{.data.config\.yaml}' | grep -A2 'tracing:'
```

{{% alert color="info" %}}
The `kiali-server` Helm chart is intended for demo and evaluation. For production clusters, use the [Kiali Operator]({{< ref "/docs/Installation/installation-guide/install-with-helm#install-with-operator" >}}).
{{% /alert %}}

### OpenShift

Install the Kiali Operator from [OperatorHub in the OpenShift console]({{< ref "/docs/Installation/installation-guide/installing-with-operatorhub" >}}), then [create a Kiali CR]({{< ref "/docs/Installation/installation-guide/creating-updating-kiali-cr" >}}) in the `istio-system` namespace.

For a minimal tutorial setup with anonymous login, you can install the operator and CR in one step using Helm:

```
helm repo add kiali https://kiali.org/helm-charts
helm install \
  --set cr.create=true \
  --set cr.namespace=istio-system \
  --set cr.spec.auth.strategy="anonymous" \
  --set cr.spec.external_services.tracing.enabled=true \
  --namespace kiali-operator \
  --create-namespace \
  kiali-operator \
  kiali/kiali-operator
```

Wait for the operator to reconcile the Kiali CR:

```
kubectl wait --for=condition=Successful kiali kiali -n istio-system --timeout=300s
kubectl get pods,svc -n istio-system -l app.kubernetes.io/name=kiali
```

See [Creating and updating the Kiali CR]({{< ref "/docs/Installation/installation-guide/creating-updating-kiali-cr" >}}) for customization options. Production OpenShift deployments typically use the `openshift` auth strategy instead of `anonymous`.

## Access the Kiali UI

### Kind

Port-forward the Kiali service to your local machine:

```
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

Open http://localhost:20001/ in your browser.

The Kiali repo also provides a convenience script: `./hack/kiali-port-forward.sh`

### OpenShift

The Kiali operator creates an OpenShift route by default. Get the URL:

```
oc get route kiali -n istio-system
```

Open the route host in your browser (for example, `https://<route-host>/`).

See [Accessing Kiali]({{< ref "/docs/Installation/installation-guide/accessing-kiali#accessing-kiali-in-openshift" >}}) for more options.

After the *Prerequisites* you should be able to access Kiali. Verify its version by clicking the "?" icon and selecting "About":

![Verify Kiali Access](/images/tutorial/01-04-access-kiali-v1.39.0.png "Verify Kiali Access")

{{% alert color="info" %}}
The screenshot above will be updated to match the current Kiali UI during tutorial refresh.
{{% /alert %}}
