---
title: "OSSMC"
description: "Questions about the OpenShift Service Mesh Console plugin."
---


### What OSSMC features work without Kiali installed?

When the OpenShift Service Mesh Console (OSSMC) plugin is installed but no Kiali server is connected to the plugin, the Service Mesh menu still provides **Istios** and **Kialis** pages. Those pages list every Istio and Kiali custom resource on the cluster so you can navigate multiple mesh instances from the OpenShift Console. They do not require a Kiali server.

Pages that require a connected Kiali server (Overview, Traffic Graph, Mesh, Namespaces, Applications, Services, Workloads, Istio Config) and **Service Mesh** tabs on OpenShift resource detail pages need a connected and reachable Kiali instance.

See [Navigating Multiple Meshes]({{< relref "../OSSMC/navigating-multiple-meshes" >}}) and [Connecting a Kiali instance to the console]({{< relref "../Installation/installation-guide/creating-updating-ossmconsole-cr#connecting-a-kiali-instance-to-the-console" >}}).

### Why do I only see Kiali instances and Istio control planes in the Service Mesh menu?

No Kiali server is currently connected to the OSSMC plugin, or OSSMC cannot reach the connected Kiali server. In that case, only **Istios** and **Kialis** appear in the Service Mesh menu — which is enough to browse the mesh and Kiali inventory on the cluster. See [Navigating Multiple Meshes]({{< relref "../OSSMC/navigating-multiple-meshes" >}}).

To enable pages that require Kiali, install a Kiali server (if needed), then open **Service Mesh** → **Kiali instances**, select your Kiali instance, and click **Connect**. Alternatively, configure `spec.kiali` on the OSSMConsole CR. See [Connecting a Kiali instance to the console]({{< relref "../Installation/installation-guide/creating-updating-ossmconsole-cr#connecting-a-kiali-instance-to-the-console" >}}).

If you recently connected a Kiali instance but those pages still do not appear, verify that the Kiali pod is running and that the OSSMConsole CR status shows a successful reconciliation, then refresh the OpenShift Console browser window.

### Why is the Istio control planes or Kiali instances list empty (or missing entries) even though I know they exist?

The **Istios** and **Kialis** pages only show custom resources your OpenShift user account has permission to read. If your account has namespace-scoped access rather than cluster-wide access to `istios.sailoperator.io` or `kialis.kiali.io`, instances in namespaces you cannot access will not appear. Ask your cluster administrator to grant `list`/`get` permission on the relevant custom resource, either cluster-wide or in the specific namespaces you need to see.

### What TLS configuration does the OSSMC plugin use?

The OSSMC plugin backend is an nginx server that serves the plugin's static assets over HTTPS (port 9443). When OSSMC is installed by the Kiali Operator, its TLS configuration (protocols, cipher suites, and key exchange groups) is rendered from the cluster's TLS security profile (`spec.tlsSecurityProfile` on `APIServer/cluster`) — the same profile the Kiali server follows when `deployment.tls_config.source` is `auto`. See [TLS Policy]({{< relref "../Configuration/tls-policy" >}}).

When the cluster TLS security profile changes, the operator re-renders the nginx configuration and restarts the OSSMC pod to pick it up. If the cluster profile is invalid for OSSMC (for example, the `Old` profile, which requires TLS 1.0 or 1.1 that OSSMC does not allow), the operator scales the OSSMC deployment to zero and leaves the last known good configuration in place — OSSMC serves nothing rather than serve TLS outside the cluster's policy. It recovers automatically once a valid profile is set.
