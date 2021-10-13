---
title: "Prerequisites"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 1
---

## Platform Setup

This tutorial assumes you will have access to a Kubernetes cluster with Istio installed.

This tutorial has been tested using:

* a [Minikube](https://istio.io/latest/docs/setup/platform-setup/minikube/) installation.
* an [OpenShift](https://istio.io/latest/docs/setup/platform-setup/openshift/) installation.

{{% alert title="Tip" color="warning" %}}
Platform dependent tasks will be indicated with a special note like this.
{{% /alert %}}

{{% alert color="warning" %}}
This tutorial has been tested using:
* __minikube v1.16.0__, __istio 1.8.1__ and __kiali v1.28.0__
* __openshift v4.8.3__, __istio 1.11.0__ and __kiali v1.39.0__
{{% /alert %}}


## Install Istio

Once you have your Kubernetes cluster ready, follow the [Istio Getting Started, window="_blank"](https://istio.io/latest/docs/setup/getting-started/) to install and setup a demo profile that will be used in this tutorial.

{{% alert color="warning" %}}
Determining ingress IP and ports and creating DNS entries will be necessary in the following steps.
{{% /alert %}}

DNS entries can be added in a basic way to the `/etc/hosts` file but you can use any other DNS service that allows to resolve a domain with the external Ingress IP.

{{% alert title="Minikube" color="warning" %}}
This tutorial uses [Minikube tunnel](https://istio.io/latest/docs/setup/platform-setup/minikube/) feature for external Ingress IP.
{{% /alert %}}

{{% alert title="OpenShift" color="warning" %}}
This tutorial uses a route for external Ingress IP.
{{% /alert %}}


## Update Kiali

Istio defines a specific Kiali version as an addon.

In this tutorial we are going to update Kiali to the latest release version.

Assuming you have installed the addons following the [Istio Getting Started](https://istio.io/latest/docs/setup/getting-started/) guide, you can uninstall Kiali with the command:

`kubectl delete -f ${ISTIO_HOME}/samples/addons/kiali.yaml --ignore-not-found`

There are multiple ways to install a recent version of Kiali, this tutorial follows the [Quick Start using Helm Chart]({{< ref "/docs/Installation/quick-start#_install_via_helm" >}}).

```
helm install \
  --namespace istio-system \
  --set auth.strategy="anonymous" \
  --repo https://kiali.org/helm-charts \
  kiali-server \
  kiali-server
```


## Access the Kiali UI

The Istio `istioctl` client has an easy method to expose and access Kiali:

`${ISTIO_HOME}/bin/istioctl dashboard kiali`

There are other alternatives to expose Kiali or other Addons in Istio. Check [Remotely Accessing Telemetry Addons](https://istio.io/latest/docs/tasks/observability/gateways/) for more information.

After the *Prerequisites* you should be able to access Kiali. Verify its version by clicking the "?" icon and selecting "About":

![Verify Kiali Access](/images/tutorial/01-04-access-kiali-v1.39.0.png "Verify Kiali Access")

