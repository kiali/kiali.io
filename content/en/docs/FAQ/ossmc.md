---
title: "OSSMC"
description: "Questions about the OpenShift Service Mesh Console plugin."
---


### What OSSMC features work without Kiali installed?

When the OpenShift Service Mesh Console (OSSMC) plugin is installed but no Kiali server is connected to the plugin, the Service Mesh menu still provides standalone **Kialis** and **Istios** pages that list and display Kiali CRs and Istio CRs from the cluster API. These pages do not require a Kiali server.

Pages that require a connected Kiali server (Overview, Traffic Graph, Mesh, Namespaces, Applications, Services, Workloads, Istio Config) and **Service Mesh** tabs on OpenShift resource detail pages need a promoted and reachable Kiali instance. See the [OSSMC User Guide](/docs/ossmc/users-guide/#standalone-features-without-a-connected-kiali-server) and [OSSMConsole CR installation guide](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/#promoting-a-kiali-instance-to-the-console).

### Why do I only see Kialis and Istios in the Service Mesh menu?

No Kiali server is currently connected to the OSSMC plugin, or OSSMC cannot reach the promoted Kiali server. In that case, only the standalone **Kialis** and **Istios** pages appear in the Service Mesh menu.

To enable pages that require Kiali, install a Kiali server (if needed), then open **Service Mesh** → **Kialis**, select your Kiali instance, and click **Promote to Console**. Alternatively, configure `spec.kiali` on the OSSMConsole CR. See [Promoting a Kiali instance to the console](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/#promoting-a-kiali-instance-to-the-console).

If you recently promoted a Kiali instance but those pages still do not appear, verify that the Kiali pod is running and that the OSSMConsole CR status shows a successful reconciliation, then refresh the OpenShift Console browser window.
