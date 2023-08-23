---
title: "Prerequisites"
description: "How to prepare for running the tutorial."
weight: 2
---

This tutorial is a walkthrough guide to install everything. For this reason, we will need:

- minikube
- istioctl
- helm

This tutorial was tested on:

- Minikube v1.30.1
- Istio v1.18.1
- Kiali v1.70

Clusters are provided by minikube instances, but this tutorial should work on on any Kubernetes environment.

We will set up some environment variables for the following commands:

```
CLUSTER_EAST="east"
CLUSTER_WEST="west"
ISTIO_DIR="absolute-path-to-istio-folder"
```

As Istio will be installed on more than one cluster and needs to communicate between clusters, we need to create certificates for the Istio installation. We will follow the [Istio documentation related to certificates](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/) to achieve this:

```
mkdir -p certs
pushd certs

make -f $ISTIO_DIR/tools/certs/Makefile.selfsigned.mk root-ca

make -f $ISTIO_DIR/tools/certs/Makefile.selfsigned.mk $CLUSTER_EAST-cacerts
make -f $ISTIO_DIR/tools/certs/Makefile.selfsigned.mk $CLUSTER_WEST-cacerts

popd
```

The result is two certificates for then use when installing Istio in the future.
