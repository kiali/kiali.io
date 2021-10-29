---
title: "Namespace Management"
description: "Configuring the namespaces accessible and visible to Kiali."
---

## Introduction

The default Kiali installation (as mentioned in the [Installation guide]({{< ref
"/docs/installation/installation-guide" >}})) gives Kiali access to all
namespaces available in the cluster.

It is possible to restrict Kiali to a set of desired namespaces by providing a list
of the ones you want, excluding the ones you don't want, or filtering by a
label selector. You can use a combination of these options.

## Accessible Namespaces

You can configure which namespaces are accessible and observable through
Kiali. You can use regex expressions which will be matched against the operator's
visible namespaces. If not set in the Kiali CR, the default
makes accessible all cluster namespaces, with the exception of
a predefined set of the cluster's system workloads.

The list of accessible namespaces is specified in the Kiali CR via the
`accessible_namespaces` setting, under the main `deployment` section. As an
example, if Kiali is to be installed in the `istio-system` namespace, and is
expected to monitor all namespaces prefixed with `mycorp_`, the setting would
be:

```yaml
spec:
  deployment:
    accessible_namespaces:
    - istio-system
    - mycorp_.*
```

{{% alert color="warning" %}}
As you can see in the example, the namespace where Kiali is
installed must be listed as accessible (often, but not always, the same namespace as Istio).
{{% /alert %}}

This configuration accepts the special pattern `accessible_namespaces: ["**"]`
which denotes that Kiali is given access to all namespaces in the cluster. 

{{% alert color="warning" %}}
If you install the operator using the [Helm Charts]({{< ref "/docs/installation/installation-guide/install-with-helm#install-with-operator" >}}), 
to be able to use the special pattern `accessible_namespaces: ["**"]`,
you must specify the `--set clusterRoleCreator=true` flag when invoking `helm
install`.
{{% /alert %}}

When installing multiple Kiali instances into a single cluster,
`accessible_namespaces` must be mutually exclusive. In other words, a namespace
set must be matched by only one Kiali CR. Regular expressions must not have
overlapping patterns.

{{% alert color="warning" %}}
A cluster can have at most one Kiali instance with the special pattern `accessible_namespaces: ["**"]`.
{{% /alert %}}

Maistra supports multi-tenancy and the `accessible_namespaces` extends that
feature to Kiali. However, explicit naming of accessible namespaces can benefit
non-Maistra installations as well - with it Kiali does not need cluster roles
and the Kiali Operator does not need permissions to create cluster roles.

## Excluded Namespaces

The Kiali CR tells the Kiali Operator which _accessible namespaces_ should be excluded from the list of namespaces provided by the API and UI. This can be useful if wildcards are used when specifying [Accessible Namespaces]({{< ref "#accessible-namespaces" >}}). This setting has no effect on namespace accessibility. It is only a filter, not security-related.

For example, if the `accessible_namespaces` configuration includes `mycorp_.*` but it is not desirable to see test namespaces, the following configuration can be used:

```yaml
api:
  namespaces:
    exclude:
      - mycorp_test.*
```

## Namespace Selectors

To fetch a subset of the available namespaces, Kiali supports an optional Kubernetes label selector. This selector is especially useful when `spec.deployment.accessible_namespaces` is set to `["**"]` but you want to reduce the namespaces presented in the UI's namespace list.

The label selector is defined in the Kiali CR setting `spec.api.namespaces.label_selector`.

The example below selects all namespaces that have a label `kiali-enabled: true`:

```yaml
api:
  namespaces:
    label_selector: kiali-enabled=true
```

For further information on how this label_selector interacts with `spec.deployment.accessible_namespaces` read the [technical documentation](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml).

To label a namespace you can use the following command. For more information see the [Kubernete's official documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels).

```
  kubectl label namespace my-namespace kiali-enabled=true
```

Note that when deploying multiple control planes in the same cluster, you will want to set the label selector's value unique to each control plane. This allows each Kiali instance to select only the namespaces relevant to each control plane. Because in this "soft-multitenancy" mode `spec.deployment.accessible_namespaces` is typically set to an explicit set of namespaces (i.e. not `["**"]`), you do not have to do anything with this `label_selector`. This is because the default value of `label_selector` is `kiali.io/member-of: <spec.istio_namespace>` when `spec.deployment.accessible_namespaces` is not set to the "all namespaces" value `["**"]`. This allows you to have multiple control planes in the same cluster, with each control plane having its own Kiali instance. If you set your own Kiali instance name in the Kiali CR (i.e. you set `spec.deployment.instance_name` to something other than `kiali`), then the default label will be `kiali.io/<spec.deployment.instance_name>.member-of: <spec.istio_namespace>`.

