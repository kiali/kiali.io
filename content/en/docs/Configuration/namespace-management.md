---
title: "Namespace Management"
description: "Configuring the namespaces accessible and visible to Kiali."
---

## Introduction

The default Kiali installation (as mentioned in the [Installation guide]({{< ref
"/docs/installation/installation-guide" >}})) gives Kiali access to all
namespaces available in the cluster.

It is possible to restrict Kiali to a set of desired namespaces by providing a list
of the ones you want, excluding the ones you don't want. You can also filter namespaces by using [Istio's discovery selectors](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#MeshConfig). You can use a combination of these options together.

{{% alert color="warning" %}}
As of Kiali 1.67, the following settings are deprecated:
* api.namespaces.exclude
* api.namespaces.include
* api.namespaces.label_selector_exclude
* api.namespaces.label_selector_include

It is recommended to instead use Istio Discovery Selectors to limit the namespaces in the mesh.
{{% /alert %}}

## Accessible Namespaces

The "accessible namespaces" setting configures which namespaces are accessible to the Kiali server itself.
The accessible namespaces are defined by a list of regex expressions that match against the namespace names
visible to the Kiali operator. If left unset, the Kiali server will be given access to all namespaces in
the cluster.

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

When you set `accessible_namespaces` to a list of namespaces as the example above illustrates, by default the operator will create a Role for each accessible namespace. Each Role will be assigned to the Kiali Service Account thus providing Kiali permissions to those namespaces. To change that default behavior, `deployment.cluster_wide_access` can be set to `true`. This will tell the operator not to create these Roles and just create a single ClusterRole and assign it to the Kiali Server (see below).

{{% alert color="info" %}}
Because Kiali server utilizes Kubernetes watches to watch all namespaces in `deployment.accessible_namespaces`, this may cause performance issues. To increase performance you can set `deployment.cluster_wide_access` to `true` when specifying a list of namespaces in `accessible_namespaces`. When you do this, the Kiali Server will be given access to the entire cluster and thus it can use a single cluster watch which increases performance and efficiency. However, you must be aware that when you do this, the Kiali Server will be granted access to the cluster via a ClusterRole - individual Roles will not be created per namespace. The `deployment.accessible_namespaces` will still be used to determine which namespaces to make available to users.
{{% /alert %}}

{{% alert color="warning" %}}
If you install Kiali using the [Server Helm Chart]({{< ref "/docs/installation/installation-guide/install-with-helm" >}}), these Roles will not be created. This security feature is provided by the operator only, and is one reason why it is recommended to use the operator. The Server Helm Chart is provided only as a convenience.
{{% /alert %}}

Note that the namespaces declared here (including any regex expressions) are evaluated and discovered by the operator at install time. Namespaces that do not exist at the time of install will not be accessible to Kiali until the operator has a chance to reconcile the Kiali CR (which should happen fairly quickly after the new namespace is created). Adding the new namespace to the list of `accessible_namespaces` will also trigger the operator to reconcile the Kiali CR. When the operator reconciles the Kiali CR, the necessary Role will be created giving the Kiali Server access to the new namespace.

{{% alert color="warning" %}}
As you can see in the example, the namespace where Kiali is installed must be listed as accessible (often, but not always, this is the same namespace as the Istio control plane namespace). If it is not in the list, it will be added for you by the operator.
{{% /alert %}}

As mentioned earlier, if you leave `accessible_namespaces` unset, this denotes that the Kiali server is given access to all namespaces in the cluster, including any namespaces that are created in the future. If you do this, individual Roles are not created per namespace; instead a single ClusterRole is created and assigned to the Kiali Service Account thus providing Kiali access to all namespaces in the cluster.

```yaml
spec:
  deployment: {}
```

{{% alert color="warning" %}}
If you install the operator using the [Helm Charts]({{< ref "/docs/installation/installation-guide/install-with-helm#install-with-operator" >}}), to be able to use this default `accessible_namespaces` behavior, you must specify the `--set clusterRoleCreator=true` flag when invoking `helm install`.
{{% /alert %}}

When installing multiple Kiali instances into a single cluster,
`accessible_namespaces` must be mutually exclusive. In other words, a namespace
set must be matched by only one Kiali CR. Regular expressions must not have
overlapping patterns.

{{% alert color="warning" %}}
A cluster can have at most one Kiali instance with `accessible_namespaces` unset.
{{% /alert %}}

## Istio Discovery Selectors

In Istio's [MeshConfig](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#MeshConfig), you can provide a list of discovery selectors that Istio will consider when processing namespaces. The Kiali server will also utilize these same discovery selectors when determining which namespaces to make available to users. Therefore, these discovery selectors work in conjunction with the `accessible_namespaces` setting. The `accessible_namespaces` setting dictates which namespaces are _accessible_ to the Kiali Server, and hence to users of Kiali. The Istio discovery selectors tell Kiali to make _available_ to users those namespaces within the `accessible_namespaces` list. So discovery selectors are a subset of `accessible_namespaces`.

{{% alert color="info" %}}
You must make sure you configure `accessible_namespaces` with a list of namespaces that are equal to, or are a superset of, the namespaces that result from evaluating the Istio discovery selectors.
{{% /alert %}}

## Included Namespaces

{{% alert color="warning" %}}
This feature is deprecated as of 1.67. It is recommended to instead use Istio Discovery Selectors.
{{% /alert %}}

When `accessible_namespaces` is unset, you can still limit the namespaces a user will see in Kiali. The `api.namespaces.include` setting allows you to configure the subset of namespaces that Kiali will show the user. This list is specified in a way similar to `accessible_namespaces`, as a list of namespaces that can include regex patterns. The difference is that this list is processed by the server, not the operator, each time the list of namespaces needs to be obtained by Kiali. This means it will handle namespaces that exist when Kiali is installed, or namespaces created later.

```yaml
spec:
  api:
    namespaces:
      include:
      - istio-system
      - mycorp_.*
  deployment: {}
```

{{% alert color="info" %}}
The `api.namespaces.include` setting is ignored if `accessible_namespaces` is set.
{{% /alert %}}

{{% alert color="info" %}}
The `api.namespaces.include` will implicitly include the control plane namespace (e.g. `istio-system`) even if you do not explicitly specify it in the list.
{{% /alert %}}

Note that this setting is merely a filter and does not provide security in any way.

## Excluded Namespaces

{{% alert color="warning" %}}
This feature is deprecated as of 1.67. It is recommended to instead use Istio Discovery Selectors.
{{% /alert %}}

The `api.namespaces.exclude` setting configures namespaces to exclude from being shown to the user. This setting can be used both when `accessible_namespaces` is unset or set to an explicit list of namespaces. It can also be used regardless of whether `api.namespaces.include` is defined. The exclude filter has precedence - if a namespace matches any regex pattern defined for `api.namespaces.exclude`, it will not be shown in Kiali. Like `api.namespaces.include`, the exclude setting is only a filter and does not provide security in any way.

For example, if the `accessible_namespaces` configuration includes `mycorp_.*` but it is not desirable to see test namespaces, the following configuration can be used:

```yaml
spec:
  api:
    namespaces:
      exclude:
      - mycorp_test.*
  deployment:
    accessible_namespaces:
    - istio-system
    - mycorp_.*
```

{{% alert color="info" %}}
You cannot exclude the control plane namespace. If you specify it in `api.namespaces.exclude`, it will be ignored.
{{% /alert %}}

## Namespace Selectors

{{% alert color="warning" %}}
This feature is deprecated as of 1.67. It is recommended to instead use Istio Discovery Selectors.
{{% /alert %}}

In addition to the Include and Exclude lists (as explained above), Kiali supports optional Kubernetes label selectors for both including and excluding namespaces.

The include label selector is defined in the Kiali CR setting `api.namespaces.label_selector_include`.

The exclude label selector is defined in the Kiali CR setting `api.namespaces.label_selector_exclude`.

The example below selects all namespaces that have a label `kiali-enabled: true`:

```yaml
spec:
  api:
    namespaces:
      label_selector_include: kiali-enabled=true
  deployment: {}
```

The example below hides all namespaces that have a label `infrastructure: system`:

```yaml
spec:
  api:
    namespaces:
      label_selector_exclude: infrastructure=system
```

### Important Note About `label_selector_include`

It is very important to understand how the `api.namespaces.label_selector_include` setting is used when `deployment.accessible_namespaces` is set to an explicit list of namespaces versus when it is unset.

When `accessible_namespaces` is unset then `label_selector_include` simply provides a filter just like `api.namespaces.include`. The difference is that `label_selector_include` filters by namespace label whereas `include` filters by namespace name. Thus, `label_selector_include` provides an additional way to limit which namespaces the Kiali user will see when `accessible_namespaces` is unset.

It is recommended to leave `label_selector_include` unset when `accessible_namespaces` is set to an explicit list of namespaces. This is because the operator adds the configured label (name and value) to each namespace defined by `accessible_namespaces`. This allows the Kiali code to use the `label_selector_include` value to easily select all of the `accessible_namespaces`. Unless you have a good reason to customize, the default value is highly recommended in this scenario.

{{% alert color="warning" %}}
If Kiali is installed via the Server Helm Chart, labels are not added to the accessible namespaces. The user must ensure `api.namespaces.label_selector_include` (if defined) selects all namespaces declared in `accessible_namespaces` (when unset). It is a user-error if this is not configured correctly.
{{% /alert %}}

For further information on how this `api.namespaces.label_selector_include` interacts with `deployment.accessible_namespaces` read the [Kiali CR Reference documentation](/docs/configuration/kialis.kiali.io/#.spec.api.namespaces.label_selector_include).

## Soft Multi-Tenancy

When deploying multiple control planes in the same cluster, the `label_selector_include`'s value must be unique to each control plane. This allows each Kiali instance to select only the namespaces relevant to each control plane. Thus you can have multiple control planes in the same cluster, with each control plane having its own Kiali instance. In this "soft-multitenancy" mode, `deployment.accessible_namespaces` is typically set to an explicit set of namespaces. In that case, you do not have to do anything with this `label_selector_include` because the default value of `label_selector_include` is `kiali.io/member-of: <spec.istio_namespace>`. If you set your own Kiali instance name in the Kiali CR (i.e. you set `deployment.instance_name` to something other than `kiali`), then the default will be `kiali.io/<spec.deployment.instance_name>.member-of: <spec.istio_namespace>`.

