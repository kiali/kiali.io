---
title: "Quick Start"
description: "Installing Kiali for demo or evaluation."
weight: 1
---

## Run Kiali locally

Kiali can be run directly on your machine without being installed into a Kubernetes cluster. It uses your kubeconfig to connect to your cluster(s). If needed, it can port-forward into the cluster to connect to your external services (prometheus, tracing, istio, grafana).

{{% alert color="info" %}}
Running Kiali locally is currently experimental. Functionality may change between releases.
{{% /alert %}}

Download the Kiali binary from the [Kiali GitHub releases page](https://github.com/kiali/kiali/releases/latest) for your OS and Arch.

Start Kiali which runs the backend server on localhost and opens your default browser to the Kiali UI.

```
kiali run
```

To see the full list of options

```
kiali run --help
```

If you want to run Kiali locally without a Prometheus instance, use the `--disable-prometheus` flag:

```
kiali run --disable-prometheus
```

This is useful for quickly exploring Kiali's non-metrics features (workloads, services, Istio configuration, mesh topology) without needing a Prometheus deployment. See [Disabling Prometheus]({{< relref "/docs/configuration/p8s-jaeger-grafana/prometheus#disabling-prometheus" >}}) for more details.

{{% alert color="info" %}}
If the cluster name in your kubeconfig does not match the cluster name in Istio you can override this with `--cluster-name-overrides kubeconfig-name=istio-cluster-name`. The flag is a comma separated list so you can override as many names as you need.
{{% /alert %}}

## Install Kiali

You can quickly install Kiali into your cluster via one of the following two methods.

{{% alert color="warning" %}}
These instructions are not recommended for production environments. Find more detailed information on installing Kiali,
see the [installation guide]({{< ref "/docs/installation" >}}).
{{% /alert %}}

{{% alert color="warning" %}}
Before you install Kiali you must have already installed Istio. For full functionality, you should also install a telemetry storage addon (i.e. Prometheus), though Kiali can run without it if you disable Prometheus in the configuration. You might also consider installing Istio's optional tracing addon (i.e. Jaeger) and optional Grafana addon but those are not required by Kiali. Refer to the [Istio documentation](https://istio.io/docs/setup/getting-started) for details.
{{% /alert %}}

### Install via Istio Addons

If you [downloaded Istio](https://istio.io/latest/docs/setup/getting-started/#download), the easiest way to install and try Kiali is by running:

```
kubectl apply -f ${ISTIO_HOME}/samples/addons/kiali.yaml
```

To uninstall:

```
kubectl delete -f ${ISTIO_HOME}/samples/addons/kiali.yaml --ignore-not-found
```

### Install via Helm {#install-via-helm}

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

Then, access Kiali by visiting https://localhost:20001/ in your preferred web browser.
