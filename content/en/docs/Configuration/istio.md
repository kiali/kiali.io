---
title: "Istio Environment"
description: >
  Kiali's default configuration matches settings present in [Istio's
  installation configuration profiles](https://istio.io/latest/docs/setup/additional-setup/config-profiles/).
  If you are [customizing your Istio installation](https://istio.io/latest/docs/setup/additional-setup/customize-installation/)
  some Kiali settings may need to be adjusted.

  Also, some Istio management features can be enabled or disabled selectively.
---

## Labels and resource names

Istio recommends [adding `app` and `version` labels to
pods](https://istio.io/latest/docs/ops/deployment/application-requirements/#pod-requirements) to attach this information to telemetry. Kiali relies on correctness of these labels for several features.

In Istio, it is possible to use a different set of labels, like
`app.kubernetes.io/name` and `app.kubernetes.io/version`, however you must
configure Kiali to the labels you are using. By default, Kiali uses Istio's
recommended labels:

```yaml
spec:
  istio_labels:
    app_label_name: "app"
    version_label_name: "version"
```

{{% alert color="warning" %}}
Although Istio lets you use different labels on different pods, Kiali can only
use a single set.

For example, Istio lets you use the `app` label in one pod and the
`app.kubernetes.io/name` in another pod and it will generate telemetry
correctly. However, you will have no way to configure Kiali for this case.
{{% /alert %}}

## Root namespace

Istio's _root namespace_ is the namespace where you can create some resources
to define default Istio configurations and adapt Istio behavior to your
environment. For more information on this Istio configuration, check the [Istio
docs Global Mesh options
page](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/) and
search for "rootNamespace".

Kiali uses the root namespace for some of the validations of Istio resources.
**Kiali automatically detects the root namespace for each Istio control plane**,
so no manual configuration is required. This enables Kiali to properly support
environments with multiple Istio control planes, where each control plane may
have a different root namespace.

{{% alert color="info" %}}
Prior to Kiali v2.16, the root namespace was configured manually via the
`external_services.istio.root_namespace` setting. This configuration option
has been removed as Kiali now autodetects the appropriate root namespace
for each control plane.
{{% /alert %}}

## Sidecar injection, canary upgrade management and Istio revisions

Kiali can assist with configuring automatic sidecar injection and
migrating workloads from an old Istio version to a newer
one using [the canary upgrade
method](https://istio.io/latest/docs/setup/upgrade/canary/). Kiali uses the
[standard Istio labels to control sidecar injection
policy](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection/#controlling-the-injection-policy)
and canary upgrades.

Management of sidecar injection is enabled by default. If you don't want this
feature, you can disable it with the following configuration:

```yaml
spec:
  kiali_feature_flags:
    istio_injection_action: false
```

Using Kiali to apply revision labels through the UI during a canary
upgrade is turned off by default. You can enable this in Kiali with the following configuration:

```yaml
spec:
  kiali_feature_flags:
    # Turns on canary upgrade support
    istio_upgrade_action: true
```

Upgrade actions will appear in the namespaces menu (Kiali <= 2.23)

![Canary upgrade action](/images/documentation/configuration/canary-upgrade-action.png "Canary upgrade action")

The progress of the canary upgrade process can be tracked on the mesh page, which displays the namespaces pending migration to the canary Istio control plane.

![Canary upgrade process](/images/documentation/configuration/istio-canary-upgrade.png "Canary upgrade process")

There following are links to sections of Kiali blogs posts that briefly
explains these features:

- [Sidecar auto-injection control description](https://medium.com/kialiproject/kiali-releases-1-21-to-1-24-overview-2a864f7d0fce#0f2c)
- [Istio's canary upgrade assistance description](https://medium.com/kialiproject/kiali-releases-1-34-to-1-39-overview-587f33fac41a#8104)
