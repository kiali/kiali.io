---
title: Uninstall Travel Demo
description: "Wrap up the tutorial."
weight: 99
---

Remove components in reverse order of installation: the Travel Demo application, Kiali, Istio, and (on Kind) the cluster itself.

## Uninstall the Travel Demo

Delete the demo namespaces:

```
kubectl delete namespace travel-agency
kubectl delete namespace travel-portal
kubectl delete namespace travel-control
```

Alternatively, delete the manifests first (this removes any Istio resources created in those namespaces during the tutorial):

```
kubectl delete -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml) -n travel-agency --ignore-not-found
kubectl delete -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml) -n travel-portal --ignore-not-found
kubectl delete -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_control.yaml) -n travel-control --ignore-not-found

kubectl delete namespace travel-agency
kubectl delete namespace travel-portal
kubectl delete namespace travel-control
```

{{% alert title="OpenShift" color="warning" %}}
If you used the Kiali Travel Demo install script, it can also remove OpenShift-specific resources (SecurityContextConstraints and NetworkAttachmentDefinitions):

```
./hack/istio/install-travel-agency-demo.sh -c oc -d true
```
{{% /alert %}}

## Uninstall Kiali

### Kind

```
helm uninstall --namespace istio-system kiali-server
```

### OpenShift

Delete the Kiali CR first so the operator removes the Kiali server:

```
kubectl delete kiali kiali -n istio-system
```

Then uninstall the operator:

```
helm uninstall --namespace kiali-operator kiali-operator
kubectl delete crd kialis.kiali.io
```

{{% alert color="warning" %}}
You must delete all Kiali CRs before uninstalling the operator. See [Uninstalling Helm installations]({{< ref "/docs/Installation/installation-guide/install-with-helm#uninstalling-helm-installations" >}}) if removal hangs.
{{% /alert %}}

If you installed the operator from OperatorHub, uninstall it from the OpenShift console using the same mechanism you used to install it.

## Uninstall Istio

### Kind

From the [Kiali source repository](https://github.com/kiali/kiali):

```
./hack/istio/install-istio-via-istioctl.sh -c kubectl -di true
```

### OpenShift

```
./hack/istio/install-istio-via-istioctl.sh -c oc -di true
```

Or use `istioctl uninstall --purge -y` and delete the `istio-system` namespace.

## Delete the Kind cluster

If you created the cluster with `hack/start-kind.sh`, delete it when you are finished:

```
kind delete cluster --name travels-tutorial
```

This removes the Kind cluster and all resources running on it.
