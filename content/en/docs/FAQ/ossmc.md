---
title: "OSSMC"
description: "Questions about the OpenShift Service Mesh Console plugin."
---


### What OSSMC features work without Kiali installed?

When the OpenShift Service Mesh Console (OSSMC) plugin is installed but no Kiali server is connected to the plugin, the Service Mesh menu still provides **Istio control planes** and **Kiali instances** pages. Those pages list every Istio and Kiali custom resource on the cluster so you can navigate multiple mesh instances from the OpenShift Console. They do not require a Kiali server.

Pages that require a connected Kiali server (Overview, Traffic Graph, Mesh, Namespaces, Applications, Services, Workloads, Istio Config) and **Service Mesh** tabs on OpenShift resource detail pages need a connected and reachable Kiali instance.

See [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/) and [Connecting a Kiali instance to the console](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/#connecting-a-kiali-instance-to-the-console).

### Why do I only see Kiali instances and Istio control planes in the Service Mesh menu?

No Kiali server is currently connected to the OSSMC plugin, or OSSMC cannot reach the connected Kiali server. In that case, only **Istio control planes** and **Kiali instances** appear in the Service Mesh menu — which is enough to browse the mesh and Kiali inventory on the cluster. See [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/).

To enable pages that require Kiali, install a Kiali server (if needed), then open **Service Mesh** → **Kiali instances**, select your Kiali instance, and click **Connect**. Alternatively, configure `spec.kiali` on the OSSMConsole CR. See [Connecting a Kiali instance to the console](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/#connecting-a-kiali-instance-to-the-console).

If you recently connected a Kiali instance but those pages still do not appear, verify that the Kiali pod is running and that the OSSMConsole CR status shows a successful reconciliation, then refresh the OpenShift Console browser window.
