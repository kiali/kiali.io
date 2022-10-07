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

The "accessible namespaces" setting configures which namespaces are accessible and observable through Kiali.
The accessible namespaces are defined by a list of regex expressions that match against the namespace names
visible to the Kiali operator. If left unset the default is the full set of namespaces visible to the Kiali
operator, less a set of predefined system namespaces.

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

Note that the namespaces declared here (including any regex expressions) are evaluated and discovered by the operator at install time. Namespaces that do not exist at the time of install will not be accessible by Kiali. For Kiali to be given access to a new namespace you must edit the Kiali CR. Adding the new namespace to the list of `accessible_namespaces` will trigger an operator reconciliation and the necessary Role will be created. Note that if the new namespace is already covered by an existing regex entry, the CR must still be changed in some way to trigger the operator reconciliation. However, if `accessible_namespaces` is set to the special value `["**"]` all namespaces (including any namespaces created in the future) will be accessible to Kiali.

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

When `accessible_namespaces` is set to `["**"]` you can still limit the namespaces a user will see in Kiali. The `api.namespaces.include` setting allows you to configure the subset of namespaces that Kiali will show the user. This list is specified in a way similar to `accessible_namespaces`, as a list of namespaces that can include regex patterns. The difference is that this list is processed by the server, not the operator, each time the list of namespaces needs to be obtained by Kiali. This means it will handle namespaces that exist when Kiali is installed, or namespaces created later.

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

{{% alert color="info" %}}
The `api.namespaces.include` will implicitly include the control plane namespace (e.g. `istio-system`) even if you do not explicitly specify it in the list.
{{% /alert %}}

Note that this setting is merely a filter and does not provide security in any way.

## Excluded Namespaces

The `api.namespaces.exclude` setting configures namespaces to exclude from being shown to the user. This setting can be used both when `accessible_namespaces` is set to `["**"]` or set to an explicit list of namespaces. It can also be used regardless of whether `api.namespaces.include` is defined. The exclude filter has precedence - if a namespace matches any regex pattern defined for `api.namespaces.exclude`, it will not be shown in Kiali. Like `api.namespaces.include`, the exclude setting is only a filter and does not provide security in any way.

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

When `accessible_namespaces` is set to `["**"]` then `label_selector_include` simply provides a filter just like `api.namespaces.include`. The difference is that `label_selector_include` filters by namespace label whereas `include` filters by namespace name. Thus, `label_selector_include` provides an additional way to limit which namespaces the Kiali user will see when `accessible_namespaces` is set to `["**"]`.

It is recommended to leave `label_selector_include` unset when `accessible_namespaces` is not set to `["**"]` (i.e. `accessible_namespaces` is set to an explicit list of namespaces). This is because the operator adds the configured label (name and value) to each namespace defined by `accessible_namespaces`. This allows the Kiali code to use the `label_selector_include` value to easily select all of the `accessible_namespaces`. Unless you have a good reason to customize, the default value is highly recommended in this scenario.

{{% alert color="warning" %}}
If Kiali is installed via the Server Helm Chart, labels are not added to the accessible namespaces. The user must ensure `api.namespaces.label_selector_include` (if defined) selects all namespaces declared in `accessible_namespaces` (when not set to `["**"]`). It is a user-error if this is not configured correctly.
{{% /alert %}}

For further information on how this `api.namespaces.label_selector_include` interacts with `deployment.accessible_namespaces` read the [Kiali CR Reference documentation](/docs/configuration/kialis.kiali.io/#.spec.api.namespaces.label_selector_include).

## Soft Multi-Tenancy

When deploying multiple control planes in the same cluster, the `label_selector_include`'s value must be unique to each control plane. This allows each Kiali instance to select only the namespaces relevant to each control plane. Thus you can have multiple control planes in the same cluster, with each control plane having its own Kiali instance. In this "soft-multitenancy" mode, `deployment.accessible_namespaces` is typically set to an explicit set of namespaces (i.e. not `["**"]`). In that case, you do not have to do anything with this `label_selector_include` because the default value of `label_selector_include` is `kiali.io/member-of: <spec.istio_namespace>`. If you set your own Kiali instance name in the Kiali CR (i.e. you set `deployment.instance_name` to something other than `kiali`), then the default will be `kiali.io/<spec.deployment.instance_name>.member-of: <spec.istio_namespace>`.

