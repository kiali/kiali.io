---
title: "Prerequisites"
description: "Hardware and Software compatibility and requirements."
weight: 10
---

## Service Mesh Compatibility

Each Kiali release is tested against the most recent Istio release. In general,
Kiali tries to maintain compatibility with older Istio releases and Kiali
versions later than those posted in the below table may work, but such
combinations are not tested and will not be supported. Known incompatibilities
are noted in the compatibility table below.

### Istio Version Compatibility

{{% alert color="success" %}}
It is always recommended that users run a supported version of Istio.
[The Istio news page](https://istio.io/news/) posts end-of-support (EOL)
dates. Supported Kiali versions include only the Kiali versions associated with
supported Istio versions.
{{% /alert %}}

|<div style="width:50px">Istio</div>|<div style="width:125px">Kiali</div>|Notes|
|-------|------------------|---|
|1.12   |1.42.0 or later   |   |
|1.11   |1.38.1 to 1.41.x  |   |
|1.10   |1.34.1 to 1.37.x  |   |
|1.9    |1.29.1 to 1.33.x  |Istio 1.9 is out of support. |
|1.8    |1.26.0 to 1.28.x  |Istio 1.8 removes all support for mixer/telemetry V1, as does Kiali 1.26.0. Use earlier versions of Kiali for mixer support.   |
|1.7    |1.22.1 to 1.25.x  |Istio 1.7 istioctl will no longer install Kiali. Use the Istio samples/addons all-in-one yaml or the Kiali Helm Chart for quick demo installs. Istio 1.7 is out of support.   |
|1.6    |1.18.1 to 1.21.x  |Istio 1.6 introduces CRD and Config changes, Kiali 1.17 is recommended for Istio < 1.6.   |

<br />

### Maistra Version Compatibility

{{% alert title="OpenShift" color="warning" %}}
If you are running Red Hat OpenShift Service Mesh (RH OSSM), use only the bundled version of Kiali.
{{% /alert %}}

|<div style="width:70px">Maistra</div>|<div style="width:100px">SMCP CR</div>|<div style="width:50px">Kiali</div>|Notes|
|---|---|---|---|
|2.1   |2.1   |1.36   |Using Maistra 2.1 to install service mesh control plane 2.1 requires Kiali Operator v1.36. Other operator versions are not compatible.   |
|2.1   |2.0   |1.24   |Using Maistra 2.1 to install service mesh control plane 2.0 requires Kiali Operator v1.36. Other operator versions are not compatible.   |
|2.1   |1.1   |1.12   |Using Maistra 2.1 to install service mesh control plane 1.1 requires Kiali Operator v1.36. Other operator versions are not compatible.   |
|2.0   |2.0   |1.24   |Using Maistra 2.0 to install service mesh control plane 2.0 requires Kiali Operator v1.36. Other operator versions are not compatible.   |
|2.0   |1.1   |1.12   |Using Maistra 2.0 to install service mesh control plane 1.1 requires Kiali Operator v1.36. Other operator versions are not compatible.   |
|1.1   |1.1   |1.12   |Using Maistra 1.1 to install service mesh control plane 1.1 requires Kiali Operator v1.36. Other operator versions are not compatible.   |
|n/a   |1.0   |n/a    |Service mesh control plane 1.0 is out of support.   |

<br />

## Browser Version Requirements {#supported-browsers}

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


