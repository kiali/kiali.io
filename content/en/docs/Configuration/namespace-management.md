---
title: "Namespace Management"
description: "Configuring the namespaces accessible and visible to Kiali."
---

## Introduction

The default Kiali [installation]({{< ref "/docs/installation/installation-guide" >}}) gives Kiali access to all namespaces available in the cluster and will allow all namespaces to be visible.

It is possible to restrict Kiali so that it can only access a specific set of namespaces by providing [discovery selectors](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#resources-that-support-set-based-requirements) that match those namespaces. Note that Kiali will not use [Istio's discovery selectors](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#MeshConfig); if Istio has been configured with its own discovery selectors, you will likely want to configure Kiali with the same list of discovery selectors.

{{% alert color="info" %}}
This documentation makes a distinction between _accessible_ and _visible_ namespaces. The Kiali Server will be given permission to access either (a) all, or (b) a configured subset, of cluster namespaces. The Kiali Server will only be aware of, query for, and access resources within these accessible namespaces. The set of namespaces visible to an end user, via the Kiali UI, will be a subset of the accessible namespaces. In other words, the namespaces visible to a user may be all, or just some of the namespaces accessible to the Kiali Server.
{{% /alert %}}

{{% alert color="warning" %}}
As of Kiali 2.0, the following settings are no longer supported:
* deployment.accessible_namespaces
* api.namespaces.exclude
* api.namespaces.include
* api.namespaces.label_selector_exclude
* api.namespaces.label_selector_include
{{% /alert %}}

## Cluster Wide Access Mode

By default, the Kiali Server is given cluster-wide access to all namespaces on the local cluster. This is controlled by the Kiali CR setting `deployment.cluster_wide_access`, which has a default value of `true` when not specified.

{{% alert color="info" %}}
You cannot have multiple Kiali Servers with both cluster-wide access and identical instance names. If you wish to install multiple Kiali Servers with cluster-wide access enabled, each must have a unique `deployment.instance_name` value.
{{% /alert %}}

In order to restrict the Kiali Server so that it only has access to certain namespaces on the local cluster, it must first have its cluster-wide access disabled. You do this by setting `deployment.cluster_wide_access` to `false` in the Kiali CR.

{{% alert color="info" %}}
You can still use discovery selectors (explained below) to limit what Kiali will make visible in the UI while `cluster_wide_access` remains `true`. You would want to do this for the performance benefits it provides the Kiali Server. But with this, the Kiali Server will be granted ClusterRole permissions rather than individual Role permissions per namespace. In other words, it will have _access_ to all namespaces, but will not make all of them _visible_.
{{% /alert %}}

## Accessible Namespaces

With cluster-wide access disabled, the Kiali Server must be told what namespaces are accessible to it.  These accessible namespaces are defined by a list of discovery selectors that match namespaces.

The list of accessible namespaces is specified in the Kiali CR via the `deployment.discovery_selectors.default` setting. As an example, if Kiali is to be installed in the `istio-system` namespace, and is expected to monitor all namespaces with the label "my-mesh", the setting would be:

```yaml
spec:
  deployment:
    cluster_wide_access: false
    discovery_selectors:
      default:
      - matchExpressions:
        - key: my-mesh
          operator: Exists
```

When `cluster_wide_access` is set to `false`, the Kiali Operator will examine the `default` selectors under `spec.deployment.discovery_selectors`, as the example above illustrates. The Kiali Operator will then attempt to find all of the namespaces that match the discovery selectors. For each namespace that matches the discovery selectors, the Kiali Operator will create a Role and assign that Role to the Kiali Service Account thus giving Kiali access to those namespaces. These namespaces are therefore called the "accessible namespaces".

{{% alert color="info" %}}
The Kiali Operator will always give the Kiali Server access to the namespace where the Kiali Server is installed and to the Istio control plane namespace (which may be the same namespace), whether those namespaces match a discovery selector or not. When `cluster_wide_access` is `false` and no discovery selectors are defined, the Kiali Server will only be given access to those two namespaces.
{{% /alert %}}

{{% alert color="info" %}}
Because the Kiali Server utilizes Kubernetes watches to watch all accessible namespaces, this may cause performance issues. To increase performance you can set `deployment.cluster_wide_access` to `true` even when specifying a list of discovery selectors. When you do this, the Kiali Server will be given access to the entire cluster and thus it can use a single cluster watch which increases performance and efficiency. However, you must be aware that when you do this, the Kiali Server will be granted access to the cluster via a ClusterRole - individual Roles will not be created per namespace. The `spec.deployment.discovery_selectors` will still be used to determine which namespaces can be visible to users.
{{% /alert %}}

{{% alert color="warning" %}}
If you install Kiali using the [Server Helm Chart]({{< ref "/docs/installation/installation-guide/install-with-helm" >}}), these Roles will not be created; so cluster-wide access must be enabled. This security feature is provided by the operator only, and is one reason why it is recommended to use the operator. The Server Helm Chart is provided only as a convenience.
{{% /alert %}}

{{% alert color="warning" %}}
If you install the Kiali Operator using the [Operator Helm Chart]({{< ref "/docs/installation/installation-guide/install-with-helm#install-with-operator" >}}), to be able to use `cluster_wide_access=true`, you must specify the `--set clusterRoleCreator=true` flag when invoking `helm install`.
{{% /alert %}}

{{% alert color="warning" %}}
When installing multiple Kiali instances into a single cluster, `deployment.discovery_selectors.default` must be mutually exclusive. In other words, a namespace must be matched by the discovery selectors defined by one and only one Kiali CR on the cluster.
{{% /alert %}}

## Istio Discovery Selectors

In Istio's [MeshConfig](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#MeshConfig), a list of discovery selectors can be configured. These Istio discovery selectors define the namespaces that Istio will consider "in the mesh" (see [this blog post](https://istio.io/v1.13/blog/2021/discovery-selectors/) for details). These Istio discovery selectors are utilized only by Istio; they will be ignored by Kiali.

## Operator Namespace Watching

Note that the discovery selectors are evaluated by the Kiali Operator at install time when deciding which namespaces should be accessible (and thus which Roles to create). Namespaces that do not exist at the time of install will not be accessible to Kiali until the operator has a chance to reconcile the Kiali CR. There are several ways in which the operator can be told to reconcile a Kiali CR in order to determine the new set of accessible namespaces.

1. You can ask the Kiali Operator to periodically reconcile the Kiali CR on a fixed schedule. See the [Ansible Operator SDK documentation describing the reconcile-period annotation](https://sdk.operatorframework.io/docs/building-operators/ansible/reference/advanced_options/#ansiblesdkoperatorframeworkioreconcile-period-custom-resource-annotation). In short, you can have the Kiali Operator periodically reconcile a Kiali CR by setting the `ansible.sdk.operatorframework.io/reconcile-period` annotation on the Kiali CR. For example, to reconcile this Kiail CR every 60 seconds:
```yaml
metadata:
  kind: Kiali
  annotations:
    ansible.sdk.operatorframework.io/reconcile-period: 60s
```
2. Modifying the `deployment.discovery_selectors.default` list of discovery selectors will automatically trigger the Kiali Operator to reconcile a Kiali CR and discover new namespaces. In fact, touching any `spec` field in the Kiali CR will trigger a reconciliation of the Kiali CR.
3. Similar to the above, touching any annotation on the Kiali CR will also trigger a reconciliation. One suggestion is to dedicate an annotation whose purpose is solely to trigger operator reconcilations. For example, add or modify the "trigger-reconcile" annotation on the Kiali CR to trigger the operator to run a reconcilation on that Kiali CR:
```sh
kubectl annotate kiali my-kiali-cr --namespace istio-system --overwrite trigger-reconcile="$(date)"
```
4. The Kiali Operator can be enabled to watch for namespaces getting created in the cluster. When new namespaces are created, the Kiali Operator will detect this and will then attempt to reconcile all Kiali CRs in the cluster. To enable operator namespace watching, see the [FAQ]({{< ref "/docs/faq/installation" >}}) describing the operator WATCHES_FILE environment variable. Note that on clusters with large numbers of namespaces that get created, enabling this namespace watching feature can cause the operator to consume a lot of CPU, so you may not wish to use this method.

Once the Kiali Operator is triggered to reconcile a Kiali CR, the operator will create the necessary Roles for all accessible namespaces, giving the Kiali Server access to any new namespaces that have been created since the last reconciliation.

## Multi-Cluster Environments

The Kiali CR `deployment.discover_selectors` section supports multi-cluster configurations.

The `default` discovery selectors define the namespaces on the local cluster that Kiali will have access to (as explained above). These namespaces are made visible to Kiali users.

It is assumed Kiali will have access to the same set of namespaces on the remote clusters as well. So Kiali will make those remote namespaces visible to users. However, if a remote cluster has a different set of namespaces that should be visible to Kiali users, you can set discovery selector `overrides` in `deployment.discovery_selectors` to match those remote namespaces.

{{% alert color="info" %}}
Each remote cluster `overrides` section completely overrides the default discovery selectors. That is to say, if a remote cluster has discovery selector overrides defined, only those selectors are used to determine which remote namespaces are to be visible to users. The `default` discovery selectors will not be used for a particular remote cluster when `overrides` are defined for that remote cluster.
{{% /alert %}}

Here is an example of defining discovery selectors for a remote cluster:

```yaml
spec:
  deployment:
    cluster_wide_access: false
    discovery_selectors:
      # define accessible namespaces on the local cluster
      default:
      - matchExpressions:
        - key: my-mesh
          operator: Exists
      overrides:
        # My remote cluster has a different set of namespaces
        my-remote-cluster:
        - matchLabels:
            org: production
        - matchExpressions:
          - key: region
            operator: In
            values: ["east"]
```

You can define overrides for multiple remote clusters:

```yaml
spec:
  deployment:
    cluster_wide_access: false
    discovery_selectors:
      default:
      - matchLabels:
          region: south
      overrides:
        cluster1:
        - matchLabels:
            region: east
        cluster2:
        - matchLabels:
            region: west
        cluster3:
        - matchLabels:
            region: north
```

## Discovery Selectors

The `default` and `overrides` discovery selectors are processed in the same manner. They follow the same semantics as Istio as described in the [Istio discoverySelectors documentation](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#MeshConfig)

{{% alert color="info" %}}
An empty list of discovery selectors has different semantics depending on the value of `deployment.cluster_wide_access`.
* If `deployment.cluster_wide_access` is `true`, an empty list of discovery selectors means all namespaces will be visible except those that are considered system namespaces (these include namespaces whose names are prefixed with "kube-", "openshift" or "ibm" such as `kube-system`, `openshift-operators`, and `ibm-system`).
* If `deployment.cluster_wide_access` is `false`, an empty list of discovery selectors means only the Istio control plane namespace and the Kiali deployment namespace will be accessible.
{{% /alert %}}

In short, the `default` discovery selectors and each remote cluster `overrides` are lists of equality-based and set-based label selectors, with each item in a list being disjunctive (that is, match results from each selector item in a selector list are OR'ed together).

Each discovery selector list item itself can consist of one `matchLabels`, one `matchExpressions`, or both. A `matchLabels` can match one or more labels; a `matchExpressions` can match one or more expressions. All results within a single discovery selector list item are AND'ed together (that is to say, a namespace must match all label selector conditions in order for that namespace to be selected by that label selector).

For details on equality-based and set-based selector syntax and semantics, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors).

Below are a couple of examples to help you understand these semantics.

This defines a discovery selector list that contains a single label selector that consists of one equality-based selector and one set-based selector. The namespaces that match this discovery selector are those that have a `env=production` label AND a `org=frontdesk` label AND a `app=ticketing` label AND a `color=blue` label:

```yaml
discovery_selectors:
  default:
  - matchLabels:
      env: production
      org: frontdesk
    matchExpressions:
    - key: app
      operator: In
      values: ["ticketing"]
    - key: color
      operator: In
      values: ["blue"]
```

Suppose we want to also make accessible all namespaces that have the label `region=east`. We add another discover selector to the list:

```yaml
discovery_selectors:
  default:
  - matchLabels:
      region: east
  - matchLabels:
      env: production
      org: frontdesk
    matchExpressions:
    - key: app
      operator: In
      values: ["ticketing"]
    - key: color
      operator: In
      values: ["blue"]
```

Now all the same namespaces that matched before are also matched. But in addition, all namespaces that simply have a label `region=east` will also match. This is because both label selectors in the list are OR'ed together.
