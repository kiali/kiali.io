---
title: "Prerequisites"
description: "Hardware and Software compatibility and requirements."
weight: 10
---

## Istio

Before you install Kiali you must have already installed Istio along with its
telemetry storage addon (i.e. Prometheus). You might also consider installing
Istio's optional tracing addon (i.e. Jaeger) and optional Grafana addon but
those are not required by Kiali. Refer to the
[Istio documentation](https://istio.io/docs/setup/getting-started) for details.

### Enable the Debug Interface

Like `istioctl`, Kiali makes use of Istio's port 8080 "Debug Interface". Despite the naming, this is required for accessing the status of the proxies
and the Istio registry.

The `ENABLE_DEBUG_ON_HTTP` setting controls the relevant access. Istio suggests to disable this for security, but Kiali requires `ENABLE_DEBUG_ON_HTTP=true`,
which is the default.

For more information, see the [Istio documentation](https://istio.io/latest/docs/ops/best-practices/security/#control-plane).


### Version Compatibility

Each Kiali release is tested against the most recent Istio release. In general,
Kiali tries to maintain compatibility with older Istio releases and Kiali
versions later than those posted in the below table may work, but such
combinations are not tested and will not be supported. Known incompatibilities
are noted in the compatibility table below.

{{% alert color="success" %}}
It is always recommended that users run a supported version of Istio.
[The Istio news page](https://istio.io/news/) posts end-of-support (EOL)
dates. Supported Kiali versions include only the Kiali versions associated with
supported Istio versions.
{{% /alert %}}

{{% readfile file="/content/en/docs/Installation/installation-guide/compatibility-istio.md" %}}

<br />

## Maistra Version Compatibility

{{% readfile file="/content/en/docs/Installation/installation-guide/compatibility-maistra.md" %}}

<br />

## OpenShift Service Mesh Version Compatibility

{{% alert title="OpenShift" color="warning" %}}
If you are running Red Hat OpenShift Service Mesh (RH OSSM), use only the bundled version of Kiali.
{{% /alert %}}

|<div style="width:70px">OSSM</div>|<div style="width:100px">Kiali</div>|Notes|
|-------|------------------|---|
|2.3   |1.57 |   |
|2.2   |1.48 |   |
|2.1   |1.36 |   |

<br />

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


