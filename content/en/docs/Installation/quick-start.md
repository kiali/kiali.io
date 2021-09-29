---
title: "Quick Start"
date: 2019-03-20T09:04:38+02:00
aliases:
- /quick-start
- /getting-started
- /gettingstarted
- /documentation/getting-started
- /documentation/latest/getting-started
draft: false
weight: 1
---

You can quickly install and try Kiali via one of the following two methods.

{{% alert color="warning" %}}
These instructions are not recommended for production environments. Find more detailed information on installing Kiali,
see the [installation guide]({{< ref "/docs/installation" >}}).
{{% /alert %}}

## Install via Istio Addons

If you [downloaded Istio](https://istio.io/latest/docs/setup/getting-started/#download), the easiest way to install and try Kiali is by running:

```
kubectl apply -f ${ISTIO_HOME}/samples/addons/kiali.yaml
```

To uninstall:

```
kubectl delete -f ${ISTIO_HOME}/samples/addons/kiali.yaml --ignore-not-found
```

## Install via Helm 

{{% alert color="warning" %}}
Only Helm v3 has been tested. Previous Helm versions may or may not work.
{{% /alert %}}

To install the latest version of Kiali Server using [Helm](https://helm.sh/), run the following command:

```
helm install \
  --namespace istio-system \
  --set auth.strategy="anonymous" \
  --repo https://kiali.org/helm-charts \
  kiali-server \
  kiali-server
```

{{% alert color="warning" %}}
If you get a validation error, you may have to pass the option `--disable-openapi-validation` (this is needed on some versions of OpenShift, for example).
{{% /alert %}}

To uninstall:

```
helm uninstall --namespace istio-system kiali-server
```

## Access to the UI

Run the following command:

```
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

Then, access Kiali by visiting \https://localhost:20001/ in your preferred web browser.


