---
title: "Getting started"
date: 2018-06-20T19:04:38+02:00
draft: false
type: "gettingstarted"
menu:
  main:
    weight: 20
---

## Getting started on OpenShift

Kiali is still in development. Snapshots releases are pushed on Dockerhub from the CI pipeline.

To deploy Kiali to your Istio-enabled OpenShift cluster you can run the following. Kiali currently requires Istio version 1.0.0 (see below if you have not yet installed Istio).

### Preparation

First you need to grant the user that is installing Istio and Kiali the `cluster-admin` role.

If OpenShift is installed locally on the machine you are using, the follow command should log you in as a user with the 'cluster-admin' role:

````
oc login -u system:admin

````

You can now install Istio if needed. See https://istio.io/docs/setup/ for details.

### Install Kiali

Then install Kiali:

```
curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/openshift/kiali-configmap.yaml | \
   VERSION_LABEL=master envsubst | oc create -n istio-system -f -

curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/openshift/kiali-secrets.yaml | \
   VERSION_LABEL=master envsubst | oc create -n istio-system -f -

curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/openshift/kiali.yaml | \
   IMAGE_NAME=kiali/kiali \
   IMAGE_VERSION=latest \
   NAMESPACE=istio-system \
   VERSION_LABEL=master \
   VERBOSE_MODE=4 envsubst | oc create -n istio-system -f -

```

If you do not have `envsubst` installed, you can get it via the Gnu `gettext` package.

If you need the Jaeger or Grafana service you need to set the URL in the configuration

```
curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/openshift/kiali-configmap.yaml | \
   VERSION_LABEL=master JAEGER_URL=http://jaeger-query-istio-system.127.0.0.1.nip.io GRAFANA_URL=http://grafana-istio-system.127.0.0.1.nip.io envsubst | oc create -n istio-system -f -
```

Once the above has completed and the Docker image has been pulled from Dockerhub, go to the OpenShift console, select the istio-system project and determine the base-URL of Kiali

![OpenShift console](/images/gettingstarted/os-console.png)

In this case it is `http://kiali-istio-system.192.168.64.13.nip.io`. In your case this could be a different IP.

You can also use the `oc` command to determine the base-url:

```
oc get route -n istio-system -l app=kiali
```

## Getting started on Kubernetes

To deploy Kiali to your Istio-enabled Kubernetes cluster you can run the following. Kiali currently requires Istio version 0.8.0 (see below if you have not yet installed Istio).

[NOTE]
If you wish to install in Minikube, ensure that you enable the Ingress add-on by executing `minikube addons enable ingress`.

```
curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/kubernetes/kiali-configmap.yaml | \
   VERSION_LABEL=master envsubst | kubectl create -n istio-system -f -

curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/kubernetes/kiali-secrets.yaml | \
   VERSION_LABEL=master envsubst | kubectl create -n istio-system -f -

curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/kubernetes/kiali.yaml | \
   IMAGE_NAME=kiali/kiali \
   IMAGE_VERSION=latest \
   NAMESPACE=istio-system \
   VERSION_LABEL=master \
   VERBOSE_MODE=4 envsubst | kubectl create -n istio-system -f -

```
If you do not have `envsubst` installed, you can get it via the Gnu `gettext` package.

If you need the Jaeger or Grafana service you need to set the URL in the configuration

```
curl https://raw.githubusercontent.com/kiali/kiali/master/deploy/kubernetes/kiali-configmap.yaml | \
   VERSION_LABEL=master JAEGER_URL=http://jaeger-query-istio-system.127.0.0.1.nip.io GRAFANA_URL=http://grafana-istio-system.127.0.0.1.nip.io envsubst | kubectl create -n istio-system -f -
```

Once this is done, Kiali will be deployed and running in Kubernetes. An Ingress will have been set up so you can go directly to the Kiali UI at the URL `http://[minikube-ip]/` where `[minikube-ip]` is what is reported when you run the command: `minikube ip`.

## Quick Start

If you do not already have an Istio-enabled cluster but want to see what Kiali is all about, you can try to run the convenience hack script [cluster-openshift.sh](https://github.com/kiali/kiali/tree/master/hack) which will install OpenShift, Istio, and Kiali all at once:

```
wget https://raw.githubusercontent.com/kiali/kiali/master/hack/cluster-openshift.sh
sh cluster-openshift.sh --kiali-enabled true up
```

[NOTE]
If you do not already have an Istio-enabled application to test with, you can install one using the [Bookinfo Sample install script](https://github.com/kiali/kiali/blob/master/hack/istio) provided as a convenience. See [the Istio docs](https://istio.io/docs/guides/bookinfo/) for more details about this sample application.

## The Kiali UI

Log in to Kiali-UI as `admin`/`admin`.

To achieve the best results you should have an example application like 'bookinfo' from the Istio examples deployed.

### Detail view of a single service

![Service view](/images/gettingstarted/kiali-service.png)


### Distributed tracing view

![Jaeger view](/images/gettingstarted/kiali-jaeger.png)
