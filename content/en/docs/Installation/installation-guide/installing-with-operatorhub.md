---
title: "Install via OperatorHub"
description: "Using OperatorHub to install the Kiali Operator."
weight: 30
---

## Introduction

The [OperatorHub](https://operatorhub.io/) is a website that contains a
catalog of [Kubernetes Operators](https://kubernetes.io/docs/concepts/extend-kubernetes/operator/).
Its aim is to be the central location to find Operators.

The OperatorHub relies in the [Operator Lifecycle Manager (OLM)](https://github.com/operator-framework/operator-lifecycle-manager)
to install, manage and update Operators on any Kubernetes cluster.

The Kiali Operator is being published to the OperatorHub. So, you can use the
OLM to install and manage the Kiali Operator installation.

## Installing the Kiali Operator using the OLM

Go to the Kiali Operator page in the OperatorHub: https://operatorhub.io/operator/kiali.

You will see an _Install_ button at the right of the page. Press it and you
will be presented with the installation instructions. Follow these instructions
to install and manage the Kiali Operator installation using OLM.

Afterwards, you can [create the Kiali CR]({{< ref creating-updating-kiali-cr >}}) to install Kiali.

## Installing the Kiali Operator in OpenShift

The OperatorHub is bundled in the OpenShift console. To install the Kiali
Operator, simply go to the OperatorHub in the OpenShift console and search for
the Kiali Operator. Then, click on the _Install_ button and follow the
instruction on the screen.

Afterwards, you can [create the Kiali CR]({{< ref creating-updating-kiali-cr >}}) to install Kiali.

