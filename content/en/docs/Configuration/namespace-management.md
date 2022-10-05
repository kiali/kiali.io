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

The main configuration setting that is used to configure which namespaces
are accessible and observable through Kiali is the "accessible namespaces" setting.
You can use regex expressions which will be matched against the operator's
visible namespaces. If not set in the Kiali CR, the default
makes accessible all cluster namespaces, with the exception of
a predefined set of the cluster's system namespaces.

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

The operator will create a Role for each accessible namespace. Each Role will be assigned to the Kiali Service Account thus providing Kiali access to those namespaces.

{{% alert color="warning" %}}
If you install Kiali using the [Server Helm Chart]({{< ref "/docs/installation/installation-guide/install-with-helm" >}}), these Roles will not be created. This security feature is provided by the operator only, and is one reason why it is recommended to use the operator. The Server Helm Chart is provided only as a convenience.
{{% /alert %}}

Note that the namespaces declared here (including any regex expressions) are evaluated and discovered by the operator at install time. Namespaces that do not exist at the time of install but are created later in the future will not be accessible by Kiali. For Kiali to be given access to namespaces created in the future, you must edit the Kiali CR and update the `accessible_namespaces` setting to include the new namespaces. However, if you set `accessible_namespaces` to the special value `["**"]` all namespaces (including any namespaces created in the future) will be accessible to Kiali.

{{% alert color="warning" %}}
As you can see in the example, the namespace where Kiali is installed must be listed as accessible (often, but not always, this is the same namespace as Istio). If it is not in the list, it will be added for you by the operator.
{{% /alert %}}

As mentioned earlier, this configuration setting accepts the special pattern `["**"]` which denotes that Kiali is given access to all namespaces in the cluster, including any namespaces that are created in the future. If you do this, individual Roles are not created per namespace; instead a single ClusterRole is created and assigned to the Kiali Service Account thus providing Kiali access to all namespaces in the cluster.

```yaml
spec:
  deployment:
    accessible_namespaces: ["**"]
```

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

## Included Namespaces

If `accessible_namespaces` is set to `["**"]` you still have an option to limit what namespaces a user will see in Kiali by utilizing the `api.namespaces.include` setting. This option allows you to specify a subset of namespaces that Kiali will show the user. This list is specified in a similar way as `accessible_namespaces` (e.g. it is a list of namespaces, and can include regex expressions). The difference is this list of namespace regexes is processed by the server (not the operator) each time a list of namespaces needs to be obtained by Kiali. This means you can include namespaces that do not yet exist at the time Kiali is installed. If you create those namespaces after Kiali is installed, Kiali will detect them.

```yaml
spec:
  api:
    namespaces:
      include:
      - istio-system
      - mycorp_.*
  deployment:
    accessible_namespaces: ["**"]
```

{{% alert color="info" %}}
The `api.namespaces.include` setting is ignored if `accessible_namespaces` is not set to `["**"]`.
{{% /alert %}}

Note that this setting is merely a filter and does not provide security in any way.

## Excluded Namespaces

You can exclude namespaces from being shown to the user by setting the `api.namespaces.exclude` setting. This filter applies regardless if `accessible_namespaces` is set to `["**"]` or not, and you can use this filter if `api.namespaces.include` is used or not. The exclude filter has precedence - if a namespace matches a regex pattern in this `api.namespaces.exclude` setting, it will not be shown in Kiali. And just like `api.namespaces.include`, this exclude feature is merely a filter and does not provide security in any way.

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

## Namespace Selectors

In addition to the Include and Exclude lists (as explained above), Kiali supports optional Kubernetes label selectors for both including and excluding namespaces.

The include label selector is defined in the Kiali CR setting `api.namespaces.label_selector_include`.

The exclude label selector is defined in the Kiali CR setting `api.namespaces.label_selector_exclude`.

The example below selects all namespaces that have a label `kiali-enabled: true`:

```yaml
spec:
  api:
    namespaces:
      label_selector_include: kiali-enabled=true
  deployment:
    accessible_namespaces: ["**"]
```

The example below hides all namespaces that have a label `infrastructure: system`:

```yaml
spec:
  api:
    namespaces:
      label_selector_exclude: infrastructure=system
```

### Important Note About `label_selector_include`

It is very important to understand how the `api.namespaces.label_selector_include` setting is used when `deployment.accessible_namespaces` is set to an explicit list of namespaces versus when it is set to `["**"]`.

When `accessible_namespaces` is set to `["**"]` then `label_selector_include` simply provides a filter just like `api.namespaces.include`. The difference is `label_selector_include` filters by namespace label whereas `include` filters by namespace name. Thus, `label_selector_include` merely provides an additional way to limit what namespaces the Kiali user will see when `accessible_namespaces` is set to `["**"]`.

When `accessible_namespaces` contains an explicit list of namespaces (i.e. is not set to `["**"]`), `label_selector_include` defines the label (name and value) that will be added by the operator to each namespace defined in `accessible_namespaces`. After the operator installs Kiali, every accessible namespace will have this label. Thus, Kiali can then use `label_selector_include` to select all namespaces as defined in `accessible_namespaces`.

{{% alert color="warning" %}}
If Kiali is installed via the Server Helm Chart, labels are not added to the accessible namespaces. The user must ensure `api.namespaces.label_selector_include` (if defined) selects all namespaces declared in `accessible_namespaces` (when not set to `["**"]`). It is a user-error if this is not configured correctly.
{{% /alert %}}

For further information on how this `api.namespaces.label_selector_include` interacts with `deployment.accessible_namespaces` read the [Kiali CR Reference documentation](/docs/configuration/kialis.kiali.io/#.spec.api.namespaces.label_selector_include).

## Soft Multi-Tenancy

When deploying multiple control planes in the same cluster, the `label_selector_include`'s value must be unique to each control plane. This allows each Kiali instance to select only the namespaces relevant to each control plane. Thus you can have multiple control planes in the same cluster, with each control plane having its own Kiali instance. In this "soft-multitenancy" mode, `deployment.accessible_namespaces` is typically set to an explicit set of namespaces (i.e. not `["**"]`). In that case, you do not have to do anything with this `label_selector_include` because the default value of `label_selector_include` is `kiali.io/member-of: <spec.istio_namespace>`. If you set your own Kiali instance name in the Kiali CR (i.e. you set `deployment.instance_name` to something other than `kiali`), then the default will be `kiali.io/<spec.deployment.instance_name>.member-of: <spec.istio_namespace>`.

