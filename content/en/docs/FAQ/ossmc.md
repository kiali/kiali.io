---
title: "OSSMC"
description: "Questions about the OpenShift Service Mesh Console plugin."
---


### What OSSMC features work without Kiali installed?

When the OpenShift Service Mesh Console (OSSMC) plugin is installed but no Kiali server is integrated, OSSMC runs in lite mode. The Service Mesh menu provides **Kialis** and **Istios** pages that list and display Kiali CRs and Istio CRs from the cluster API.

Full-mode pages (Overview, Traffic Graph, Mesh, Namespaces, Applications, Services, Workloads, Istio Config) and **Service Mesh** tabs on OpenShift resource detail pages require a promoted and reachable Kiali instance. See the [OSSMC User Guide](/docs/ossmc/users-guide/#lite-mode-and-full-mode) and [OSSMConsole CR installation guide](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/#promoting-a-kiali-instance-to-the-console).

### Why do I only see Kialis and Istios in the Service Mesh menu?

OSSMC is in **lite mode** — no Kiali server is currently integrated with the plugin, or OSSMC cannot reach the promoted Kiali server.

To enable full-mode pages, install a Kiali server (if needed), then open **Service Mesh** → **Kialis**, select your Kiali instance, and click **Promote to Console**. Alternatively, configure `spec.kiali` on the OSSMConsole CR. See [Promoting a Kiali instance to the console](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/#promoting-a-kiali-instance-to-the-console).

If you recently promoted a Kiali instance but full-mode pages still do not appear, verify that the Kiali pod is running and that the OSSMConsole CR status shows a successful reconciliation, then refresh the OpenShift Console browser window.
