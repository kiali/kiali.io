---
title: "Install via Helm"
description: "Using Helm to install the Kiali Operator or Server."
weight: 20
---

## Introduction

[Helm](https://helm.sh/) is a popular tool that lets you manage Kubernetes
applications. Applications are defined in a package named _Helm chart_, which
contains all of the resources needed to run an application.

Kiali has a Helm Charts Repository at
https://kiali.org/helm-charts. Two Helm
Charts are provided:

- The `kiali-operator` Helm Chart installs the Kiali operator which in turn
  installs Kiali when you create a Kiali CR.
- The `kiali-server` Helm Chart installs a standalone Kiali without the need of
  the Operator nor a Kiali CR.

{{% alert color="warning" %}}
The `kiali-server` Helm Chart does not provide all the functionality that the Operator
provides. Some features you read about in the documentation may only be available if
you install Kiali using the Operator. Therefore, although the `kiali-server` Helm Chart
is actively maintained, it is not recommended and is only provided for convenience.
If using Helm, the recommended method is to install the `kiali-operator` Helm Chart
and then create a Kiali CR to let the Operator deploy Kiali.
{{% /alert %}}

Make sure you have the `helm` command available by following the
[Helm installation docs](https://helm.sh/docs/intro/install/).

{{% alert color="warning" %}}
The Kiali Helm Charts have been tested only against Helm version 3.10. There is no guarantee that previous versions will work.
{{% /alert %}}

## Adding the Kiali Helm Charts repository

Add the Kiali Helm Charts repository with the following command:

```
$ helm repo add kiali https://kiali.org/helm-charts
```

{{% alert color="warning" %}}
All `helm` commands in this page assume that you added the Kiali Helm Charts repository as shown.
{{% /alert %}}

If you already added the repository, you may want to update your local cache to
fetch latest definitions by running:

```
$ helm repo update
```

## Installing Kiali using the Kiali operator {#install-with-operator}

{{% alert color="danger" %}}
This installation method gives Kiali access to existing namespaces as
well as namespaces created later. See [Namespace Management]({{< ref "/docs/configuration/namespace-management" >}}) for more information.
{{% /alert %}}

Once you've added the Kiali Helm Charts repository, you can install the latest
Kiali Operator along with the latest Kiali server by running the following
command:

```
$ helm install \
    --set cr.create=true \
    --set cr.namespace=istio-system \
    --namespace kiali-operator \
    --create-namespace \
    kiali-operator \
    kiali/kiali-operator
```

The `--namespace kiali-operator` and `--create-namespace` flags instructs to
create the `kiali-operator` namespace (if needed), and deploy the Kiali
operator on it.  The `--set cr.create=true` and `--set
cr.namespace=istio-system` flags instructs to create a Kiali CR in the
`istio-system` namespace. Since the Kiali CR is created in advance, as soon as
the Kiali operator starts, it will process it to deploy Kiali.

The Kiali Operator Helm Chart is configurable. Check available options and default values by running:

```
$ helm show values kiali/kiali-operator
```

{{% alert color="success" %}}
You can pass the `--version X.Y.Z` flag to the `helm install` and `helm
show values` commands to work with a specific version of Kiali.
{{% /alert %}}

The `kiali-operator` Helm Chart mirrors all settings of the Kiali CR as chart
values that you can configure using regular `--set` flags. For example, the
Kiali CR has a `spec.server.web_root` setting which you can configure in the
`kiali-operator` Helm Chart by passing `--set cr.spec.server.web_root=/your-path`
to the `helm install` command.

For more information about the Kiali CR, see the [Creating and updating the Kiali CR page]({{< ref creating-updating-kiali-cr >}}).

### Operator-Only Install

To install only the Kiali Operator, omit the `--set cr.create` and
`--set cr.namespace` flags of the helm command previously shown. For example:

```
$ helm install \
    --namespace kiali-operator \
    --create-namespace \
    kiali-operator \
    kiali/kiali-operator
```

This will omit creation of the Kiali CR, which you will need to [create later to install Kiali Server]({{< ref creating-updating-kiali-cr >}}).  This
option is good if you plan to do large customizations to the installation.

### Installing Multiple Instances of Kiali

By installing a single Kiali operator in your cluster, you can install multiple instances of Kiali by simply creating multiple Kiali CRs. For example, if you have two Istio control planes in namespaces `istio-system` and `istio-system2`, you can create a Kiali CR in each of those namespaces to install a Kiali instance in each control plane.

If you wish to install multiple Kiali instances in the same namespace, or if you need the Kiali instance to have different resource names than the default of `kiali`, you can specify `spec.deployment.instance_name` in your Kiali CR. The value for that setting will be used to create a unique instance of Kiali using that instance name rather than the default `kiali`. One use-case for this is to be able to have unique Kiali service names across multiple Kiali instances in order to be able to use certain routers/load balancers that require unique service names.

{{% alert color="warning" %}}
Since the `spec.deployment.instance_name` field is used for the Kiali resource names, including the Service name, you must ensure the value you assign this setting follows the [Kubernetes DNS Label Name rules](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#dns-label-names). If it does not, the operator will abort the installation. And note that because Kiali uses this as a prefix (it may append additional characters for some resource names) its length is limited to 40 characters.
{{% /alert %}}

## Standalone Kiali installation

To install the Kiali Server without the operator, use the `kiali-server` Helm Chart:

```
$ helm install \
    --namespace istio-system \
    kiali-server \
    kiali/kiali-server
```

The `kiali-server` Helm Chart mirrors all settings of the Kiali CR as chart
values that you can configure using regular `--set` flags. For example, the
Kiali CR has a `spec.server.web_fqdn` setting which you can configure in the
`kiali-server` Helm Chart by passing the `--set server.web_fqdn` flag as
follows:

```
$ helm install \
    --namespace istio-system \
    --set server.web_fqdn=example.com \
    kiali-server \
    kiali/kiali-server
```

## Upgrading Helm installations

If you want to upgrade to a newer Kiali version (or downgrade to older
versions), you can use the regular `helm upgrade` commands. For example, the
following command should upgrade the Kiali Operator to the latest version:

```
$ helm upgrade \
    --namespace kiali-operator \
    --reuse-values \
    kiali-operator \
    kiali/kiali-operator
```

WARNING: No migration paths are provided. However, Kiali is a stateless
application and if the `helm upgrade` command fails, please uninstall the
previous version and then install the new desired version.

{{% alert color="success" %}}
By upgrading the Kiali Operator, existent Kiali Server installations
managed with a Kiali CR will also be upgraded once the updated operator starts.
{{% /alert %}}

## Managing configuration of Helm installations {#managing-installation-config}

After installing either the `kiali-operator` or the `kiali-server` Helm Charts,
you may be tempted to manually modify the created resources to modify the
installation. However, we recommend using `helm upgrade` to update your
installation.

For example, assuming you have the following installation:

```
$ helm list -n kiali-operator
NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
kiali-operator  kiali-operator  1               2021-09-14 18:00:45.320351026 -0500 CDT deployed        kiali-operator-1.40.0   v1.40.0
```

Notice that the current installation is version `1.40.0` of the
`kiali-operator`.  Let's assume you want to use your own mirrors of the Kiali
Operator container images. You can update your installation with the following
command:

```
$ helm upgrade \
    --namespace kiali-operator \
    --reuse-values \
    --set image.repo=your_mirror_registry_url/owner/kiali-operator-repo \
    --set image.tag=your_mirror_tag \
    --version 1.40.0 \
    kiali-operator \
    kiali/kiali-operator
```

{{% alert color="warning" %}}
Make sure that you specify the `--reuse-values` flag to take the
configuration of your current installation. Then, you only need to specify the
new settings you want to change using `--set` flags.
{{% /alert %}}

{{% alert color="warning" %}}
Make sure that you specify the `--version X.Y.Z` flag with the
version of your current installation. Otherwise, you may end up upgrading to a
new version.
{{% /alert %}}

## Uninstalling

### Removing the Kiali operator and managed Kialis

If you used the `kiali-operator` Helm chart, first you must ensure that all
Kiali CRs are deleted. For example, the following command will agressively
delete all Kiali CRs in your cluster:

```
$ kubectl delete kiali --all --all-namespaces
```

The previous command may take some time to finish while the Kiali operator
removes all Kiali installations.

Then, remove the Kiali operator using a standard `helm uninstall` command. For
example:

```
$ helm uninstall --namespace kiali-operator kiali-operator
$ kubectl delete crd kialis.kiali.io
```

{{% alert color="warning" %}}
You have to manually delete the `kialis.kiali.io` CRD because
[Helm won't delete it.](https://helm.sh/docs/topics/charts/#limitations-on-crds)
{{% /alert %}}

{{% alert color="warning" %}}
If you fail to delete the Kiali CRs before uninstalling the operator,
a proper cleanup may not be done.
{{% /alert %}}

#### Known problem: uninstall hangs (unable to delete the Kiali CR)

Typically this happens if not all Kiali CRs are deleted prior to uninstalling
the operator. To force deletion of a Kiali CR, you need to clear its finalizer.
For example:

```
$ kubectl patch kiali kiali -n istio-system -p '{"metadata":{"finalizers": []}}' --type=merge
```

{{% alert color="danger" %}}
This forces deletion of the Kiali CR and will skip uninstallation of
the Kiali Server. Remnants of the Kiali Server may still exist in your cluster
which you will need to manually remove.
{{% /alert %}}

### Removing standalone Kiali

If you installed a standalone Kiali by using the `kiali-server` Helm chart, use
the standard `helm uninstall` commands. For example:

```
$ helm uninstall --namespace istio-system kiali-server
```
