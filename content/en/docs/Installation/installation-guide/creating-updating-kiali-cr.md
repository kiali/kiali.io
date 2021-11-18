---
title: "The Kiali CR"
description: "Creating and updating the Kiali CR."
weight: 40
---

The Kiali Operator watches the _Kiali Custom Resource_ (Kiali CR), a YAML file
that holds the deployment configuration. Creating, updating, or removing a
Kiali CR will trigger the Kiali Operator to install, update, or remove Kiali.

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
installation. You can check installation progress by inspecting the `status` attribute of the created Kiali CR:

```
$ kubectl describe kiali -n istio-system
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
    Kubernetes Version:  1.21.2
    Operator Version:    v1.40.0
  Progress:
    Duration:  0:00:16
    Message:   5. Creating core resources
Events:        <none>
```

{{% alert color="warning" %}}
*Never* manually edit resources created by the Kiali Operator, only the Kiali CR.
{{% /alert %}}

You may want to check the [example install page]({{< relref "example-install"
>}}) to see some examples where the Kiali CR has a `spec` and to better
understand its structre. Most available attributes of the Kiali CR are
described in the pages of the [Installation]({{< relref "../" >}}) and
[Configuration]({{< relref "../../Configuration" >}}) sections of the
documentation.

Alternatively, a [Kiali CR YAML template
file](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml)
is available in the Operator's GitHub repository. This template file contains
and describes all available settings. You can download it and edit it being
*very careful* to maintain proper formatting. Incorrect indentation is a common
problem!

{{% alert color="warning" %}}
The link in the previous paragraph is for the example Kiali CR hosted in
GitHub, in the `master` branch. Use GitHub's branch selector to see the example
file that matches the Kiali Operator version that you are using.
{{% /alert %}}

{{% alert color="danger" %}}
It is important to understand the `spec.deployment.accessible_namespaces` setting in the CR. See the
[Namespace Management page]({{< ref "/docs/configuration/namespace-management" >}})
for more information.
{{% /alert %}}

Once you created a Kiali CR, you can manage your Kiali installation by editing
the resource using the usual Kubernetes tools:

```
$ kubectl edit kiali kiali -n istio-system
```

