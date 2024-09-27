---
title: "The Kiali CR"
description: "Creating and updating the Kiali CR."
weight: 40
---

The Kiali Operator watches the _Kiali Custom Resource_ ([Kiali CR](/docs/configuration/kialis.kiali.io)), a custom resource that  contains the Kiali Server deployment configuration. Creating, updating, or removing a
Kiali CR will trigger the Kiali Operator to install, update, or remove Kiali.

{{% alert color="success" %}}
If you want the operator to re-process the Kiali CR (called "reconciliation") without having to change the Kiali CR's `spec` fields, you can modify any annotation on the Kiali CR itself. This will trigger the operator to reconcile the current state of the cluster with the desired state defined in the Kiali CR, modifying cluster resources if necessary to get them into their desired state. Here is an example illustrating how you can modify an annotation on a Kiali CR:
```
$ kubectl annotate kiali my-kiali -n istio-system --overwrite kiali.io/reconcile="$(date)"
```
{{% /alert %}}

The Operator provides comprehensive defaults for all properties of the Kiali
CR. Hence, the minimal Kiali CR does not have a `spec`:

```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
```

Assuming you saved the previous YAML to a file named `my-kiali-cr.yaml`, and that you are
installing Kiali in the same default namespace as Istio, create the resource with the following command:

```
$ kubectl apply -f my-kiali-cr.yaml -n istio-system
```

{{% alert color="success" %}}
Often, but not always, Kiali is installed in the same namespace as Istio, thus the Kiali CR is also created in the Istio namespace.
{{% /alert %}}

Once created, the Kiali Operator should shortly be notified and will process the resource,  performing the Kiali
installation. You can wait for the Kiali Operator to finish the reconcilation by using the standard `kubectl wait`
command and ask for it to wait for the Kiali CR to achieve the condition of `Successful`. For example:

```
kubectl wait --for=condition=Successful kiali kiali -n istio-system
```

You can check the installation progress by inspecting the `status` attribute of the created Kiali CR:

```
$ kubectl describe kiali kiali -n istio-system
Name:         kiali
Namespace:    istio-system
Labels:       <none>
Annotations:  <none>
API Version:  kiali.io/v1alpha1
Kind:         Kiali

  (...some output is removed...)

Status:
  Conditions:
    Last Transition Time:  2021-09-15T17:17:40Z
    Message:               Running reconciliation
    Reason:                Running
    Status:                True
    Type:                  Running
  Deployment:
    Instance Name:  kiali
    Namespace:      istio-system
  Environment:
    Is Kubernetes:       true
    Kubernetes Version:  1.27.3
    Operator Version:    v1.89.0
  Progress:
    Duration:    0:00:16
    Message:     5. Creating core resources
  Spec Version:  default
Events:        <none>
```

{{% alert color="warning" %}}
*Never* manually edit resources created by the Kiali Operator; only edit the Kiali CR.
{{% /alert %}}

You may want to check the [example install page]({{< relref "example-install"
>}}) to see some examples where the Kiali CR has a `spec` and to better
understand its structure. Most available attributes of the Kiali CR are
described in the pages of the [Installation]({{< relref "../" >}}) and
[Configuration]({{< relref "../../Configuration" >}}) sections of the
documentation. For a complete list, see the [Kiali CR Reference](/docs/configuration/kialis.kiali.io).

{{% alert color="danger" %}}
It is important to understand the `spec.deployment.cluster_wide_access` setting in the CR. See the
[Namespace Management page]({{< ref "/docs/configuration/namespace-management" >}})
for more information.
{{% /alert %}}

Once you created a Kiali CR, you can manage your Kiali installation by editing
the resource using the usual Kubernetes tools:

```
$ kubectl edit kiali kiali -n istio-system
```

To confirm your Kiali CR is valid, you can utilize the [Kiali CR validation tool](/docs/configuration/kialis.kiali.io/#validating-your-kiali-cr).
