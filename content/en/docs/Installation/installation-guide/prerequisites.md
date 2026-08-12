---
title: "Prerequisites"
description: "Hardware and Software compatibility and requirements."
weight: 15
---

## Istio

Before you install Kiali you must have already installed Istio. For full
functionality, you should also install a telemetry storage addon (e.g.
Prometheus), though Kiali can run without it if you disable Prometheus in the
configuration. You might also consider installing Istio's optional tracing
addon (e.g. Tempo) and optional Grafana addon but those are not required by
Kiali. Refer to the
[Istio documentation](https://istio.io/docs/setup/getting-started) for details.

### Optionally Enable the Debug Interface

Like `istioctl`, Kiali can make use of Istio's port 8080 "Debug Interface" API. Despite the naming, this is required for accessing the status of the proxies.

The `ENABLE_DEBUG_ON_HTTP` setting controls the relevant API access. Istio suggests to disable this for security, but Kiali requires `ENABLE_DEBUG_ON_HTTP=true`,
which is the default.

If you prefer not to enable the Istio API then certain Kiali features will be unavailable. If disabled, set `spec.external_services.istio.istio_api_enabled: false` in the Kiali CR.

For more information, see the [Istio documentation](https://istio.io/latest/docs/ops/best-practices/security/#control-plane).

### Version Compatibility

{{% alert color="success" %}}
It is always recommended that users run a supported version of Istio.
[The Istio news page](https://istio.io/news/) posts end-of-support (EOL)
dates. Supported Kiali versions include only the Kiali versions associated with
supported Istio versions.
{{% /alert %}}

Starting with Kiali v2.4, each Kiali release is tested against the [currently supported Istio releases](https://istio.io/latest/news).
Unless otherwise noted, a Kiali release will be compatible with those releases. Older, untested Istio versions may also be compatible.
Known incompatibilities will be noted in the table below. Prior to Kiali v2.4, compatibility is guaranteed only against the latest
Istio release at the time. Although compatibility may be fine with other versions.

{{<compat-table-istio>}}

<br />

## OpenShift Service Mesh Version Compatibility

{{% alert color="warning" %}}
If you are running Red Hat OpenShift Service Mesh (OSSM), use only the bundled, supported version of Kiali.
{{% /alert %}}

| <div style="width:100px">OSSM</div> | <div style="width:100px">Kiali</div> | Notes                      |
| ----------------------------------- | ------------------------------------ | -------------------------- |
| 3.4                                 | 2.27                                 |                            |
| 3.3                                 | 2.22                                 |                            |
| 3.2                                 | 2.17                                 |                            |
| 3.1                                 | 2.11                                 |                            |
| 3.0                                 | 2.4                                  |                            |
| 2.6                                 | 1.73                                 | OSSM 2.6 is out of support |
| 2.5                                 | 1.73                                 | OSSM 2.5 is out of support |
| 2.4                                 | 1.65                                 | OSSM 2.4 is out of support |
| 2.3                                 | 1.57                                 | OSSM 2.3 is out of support |
| 2.2                                 | 1.48                                 | OSSM 2.2 is out of support |

<br />

## OpenShift Console Plugin (OSSMC) Version Compatibility

The OSSMC plugin can be installed with only the Kiali Operator — a Kiali server is not required for the standalone **Kialis** and **Istios** pages.

When a Kiali instance is promoted and connected to OSSMC, the Kiali server version must match the OSSMC plugin version. See the compatibility table below.

{{<compat-table-ossmc>}}

<br />

## Maistra Version Compatibility

{{% alert color="warning" %}}
Maistra (OSSM 2.x) has reached end of life and is out of support.
{{% /alert %}}

## Browser Compatibility {#supported-browsers}

Kiali requires a modern web browser and supports the last two versions of Chrome, Firefox, Safari or Edge.

## Hardware Requirements

Any machine capable of running a Kubernetes based cluster should also be able
to run Kiali.

However, Kiali tends to grow in resource usage as your cluster grows. Usually
the more namespaces and workloads you have in your cluster, the more memory you
will need to allocate to Kiali.

## Platform-specific requirements

### OpenShift

If you are installing on OpenShift, you must grant the `cluster-admin` role to the user that is installing Kiali. If OpenShift is installed locally on the machine you are using, the following command should log you in as user `system:admin` which has this `cluster-admin` role:

```
$ oc login -u system:admin
```

{{% alert color="success" %}}
For most commands listed on this documentation, the Kubernetes CLI command `kubectl` is used to interact with the cluster environment. On OpenShift you can simply replace `kubectl` with `oc`, unless otherwise noted.
{{% /alert %}}

### Google Cloud Private Cluster {#google-prereqs}

Private clusters on Google Cloud have network restrictions. Kiali needs your cluster's firewall to allow access from the Kubernetes API to the Istio Control Plane namespace, for both the `8080` and `15000` ports.

To review the master access firewall rule:

```
gcloud compute firewall-rules list --filter="name~gke-${CLUSTER_NAME}-[0-9a-z]*-master"
```

To replace the existing rule and allow master access:

```
gcloud compute firewall-rules update <firewall-rule-name> --allow <previous-ports>,tcp:8080,tcp:15000
```

{{% alert color="success" %}}
Istio deployments on private clusters also need extra ports to be opened. Check the [Istio installation page for GKE](https://istio.io/latest/docs/setup/platform-setup/gke/) to see all the extra installation steps for this platform.
{{% /alert %}}
