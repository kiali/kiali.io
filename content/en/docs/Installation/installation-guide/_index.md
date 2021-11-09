---
title: "Installation Guide"
description: "Installing Kiali for production."
weight: 20
---

This section describes the production installation methods available for Kiali.

The recommended way to deploy Kiali is via the Kiali Operator, either using Helm Charts or OperatorHub.

The Kiali Operator is a [Kubernetes Operator](https://coreos.com/operators/)
and manages your Kiali installation. It watches the _Kiali Custom Resource_
(Kiali CR), a YAML file that holds the deployment configuration.

{{% alert color="success" %}}
It is only necessary to install the Kiali Operator once. After the
operator is installed you only need to [create or edit the Kiali CR]({{< relref "creating-updating-kiali-cr" >}}). *Never* manually
edit resources created by the Kiali Operator.
{{% /alert %}}

{{% alert color="warning" %}}
If you previously installed Kiali via a different mechanism, *you
must first uninstall Kiali* using the original mechanism's uninstall procedures.
There is no migration path between older installation mechanisms and the
install mechanisms explained in this documentation.
{{% /alert %}}

