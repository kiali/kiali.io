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
pods](https://istio.io/latest/docs/ops/deployment/requirements/#pod-requirements) to attach this information to telemetry. Kiali relies on correctness of these labels for several features.

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

## Monitoring port of the IstioD pod

Kiali connects directly to the IstioD pod (not the Service) to check for its
health. By default, the connection is done to port 15014 which is the default
monitoring port of the IstioD pod.

Under some circumstances, you may need to change the monitoring port of the
IstioD pod to something else. For example, when running IstioD in [_host
network mode_](https://kubernetes.io/docs/concepts/cluster-administration/networking/#the-kubernetes-network-model)
the network is shared between several pods, requiring to change listening ports
of some pods to prevent conflicts.

It is possible to map the newly chosen monitoring port of the IstioD pod in the
related Service to let other services continue working normally. However, since
Kiali connects directly to the IstioD pod, you need to configure the assigned
monitoring port in the Kiali CR:

```yaml
spec:
  external_services:
    istio:
      istiod_pod_monitoring_port: 15014
```

## Multi-cluster support

Kiali has [experimental support for Istio multi-cluster installations]({{< relref "../Features/multi-cluster" >}})
using the [_multi-primary on different networks_ pattern](https://istio.io/latest/docs/setup/install/multicluster/multi-primary_multi-network/).
This support is enabled by default, but requires the Kiali ServiceAccount to
have read access to secrets in the Istio namespace. If you don't have a
multi-cluster setup or don't want Kiali to have read access to secrets in the
Istio namespace, you can disable clustering support:


```yaml
spec:
  kiali_feature_flags:
    clustering:
      enabled: false
```

## Root namespace

Istio's _root namespace_ is the namespace where you can create some resources
to define default Istio configurations and adapt Istio behavior to your
environment. For more information on this Istio configuration, check the [Istio
docs Global Mesh options
page](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/) and
search for "rootNamespace".

Kiali uses the root namespace for some of the validations of Istio resources.
If you customized the Istio root namespace, you will need to replicate that
configuration in Kiali. By default, it is unset:

```yaml
spec:
  external_services:
    istio:
      root_namespace: ""
```

## Sidecar injection, canary upgrade management and Istio revisions

Kiali can assist into configuring automatic sidecar injection, and also can
assist when you are migrating workloads from an old Istio version to a newer
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

Assistance for migrating workloads between Istio revisions when doing a canary
upgrade is turned off by default. This is because it is required to know [what
is the revision name that was used when
installing](https://istio.io/latest/docs/setup/upgrade/canary/#control-plane)
each Istio control plane. You can enable and configure the canary upgrade
support with the following configuration:

```yaml
spec:
  external_services:
    istio:
      istio_canary_revision:
        # Revision string of old Istio version
        current: "1-10-3"
        # Revision string of new Istio version
        upgrade: "1-11-0"
  kiali_feature_flags:
    # Turns on canary upgrade support
    istio_upgrade_action: true
```

{{% alert color="warning" %}}
Please note that Kiali will use _revision labels_ to control sidecar injection
policy only when canary upgrade support is enabled; else, non-revision labels
are used. Make sure you finish the canary upgrade before turning off the canary
upgrade support. If you need to disable Kiali's canary upgrade feature while an
upgrade is unfinished, it will be safer if you also disable the sidecar
injection management feature.
{{% /alert %}}

It is important to note that canary upgrades require adding a revision name
during the installation of control planes. You will notice that the revision
name will be appended to the name of Istio resources. Thus, once/if you are
using Kiali with an Istio control plane that has a revision name you will need
to specify what is the name of a few Istio resources that Kiali uses. For
example, if your control plane has a revision name `1-11-0` you would need to
set these configurations:

```yaml
spec:
  external_services:
    istio:
      config_map_name: "istio-1-11-0"
      istio_sidecar_injector_config_map_name: "istio-sidecar-injector-1-11-0"
      istiod_deployment_name: "istiod-1-11-0"
```

There following are links to sections of Kiali blogs posts that briefly
explains these features:
* [Sidecar auto-injection control description](https://medium.com/kialiproject/kiali-releases-1-21-to-1-24-overview-2a864f7d0fce#0f2c)
* [Istio's canary upgrade assistance description](https://medium.com/kialiproject/kiali-releases-1-34-to-1-39-overview-587f33fac41a#8104) 

