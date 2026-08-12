---
title: "Navigating Multiple Meshes with OSSMC"
linkTitle: "Navigating Multiple Meshes"
description: "Browse and manage Istio and Kiali instances in the OpenShift Console — without requiring a Kiali server connected to the plugin."
weight: 5
---

OpenShift Service Mesh Console (OSSMC) includes **Istios** and **Kialis** pages in the OpenShift Console **Service Mesh** menu. These pages let you browse and inspect every Istio and Kiali custom resource on the cluster directly from the console — without requiring a Kiali server to be connected to the plugin.

This is especially useful when a cluster hosts many mesh instances. Platform teams that operate dozens or hundreds of Istio control planes (and the Kiali instances that observe them) on a cluster can navigate that inventory in one place instead of jumping between CLI commands, individual operator UIs, or separate Kiali routes.

## Why this matters

* **One inventory for the whole cluster** — List every Istio CR and every Kiali CR from the OpenShift Console sidebar.
* **No Kiali server required** — The pages talk to the Kubernetes API. You can install the OSSMC plugin independently of any Kiali Server and still get this multi-mesh navigation.
* **Works alongside Kiali-powered observability** — When you do connect a Kiali server to the plugin, Overview, Traffic Graph, and the other observability pages appear for that promoted instance. **Istios** and **Kialis** stay in the menu so you can still manage the full fleet.

## Istios

The **Istios** page lists every cluster-scoped Istio CR managed by the OSSM/Sail Operator. Open a row to see details for that Istio installation.

Use this page when you need a console view of mesh control-plane instances on the cluster — for example, confirming which Istio CRs exist, opening one for more information, or orienting yourself before promoting a related Kiali instance.

## Kialis

The **Kialis** page lists every Kiali CR on the cluster. Open a row to see configuration from that Kiali CR.

From the list or details page you can **Promote to Console** or **Demote** a Kiali instance:

* **Promote to Console** — Connects that Kiali server to the OSSMC plugin so Overview, Traffic Graph, Mesh, and the other Kiali-powered pages become available for that instance.
* **Demote** — Disconnects that Kiali instance from the plugin. **Istios** and **Kialis** remain available so you can keep navigating the fleet and promote a different instance when needed.

Promote and demote require permission to patch the OSSMConsole CR (`ossmconsoles.kiali.io`).

{{% alert color="info" %}}
OSSMC [supports a single tenant at a time](https://github.com/kiali/openshift-servicemesh-plugin/issues/187) for Kiali-powered observability pages. Promote the Kiali instance you want to use for deep observability; use **Istios** and **Kialis** to navigate the rest of the fleet and switch when needed.
{{% /alert %}}

## When a Kiali server is connected — and when it is not

| Situation | What you see in the Service Mesh menu |
| --- | --- |
| No Kiali server connected (or the promoted server is unreachable) | **Istios** and **Kialis** only |
| A Kiali instance is promoted and reachable | Observability pages (Overview, Traffic Graph, Mesh, and others) plus **Istios** and **Kialis** at the bottom of the menu (below a separator) |

If the plugin is configured to use a Kiali server but cannot reach it, pages that need Kiali show a **Service Mesh is not configured** message. **Istios** and **Kialis** continue to work.

## Getting started

1. Install the Kiali Operator (a Kiali server is optional for these pages).
2. Create an OSSMConsole CR to install the plugin — see [The OSSMConsole CR](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/).
3. Open **Service Mesh** → **Istios** or **Kialis** in the OpenShift Console.

To connect a Kiali server for deep observability on one instance, promote it from the **Kialis** page or set `spec.kiali` on the OSSMConsole CR. See [Promoting a Kiali instance to the console](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/#promoting-a-kiali-instance-to-the-console).

For a tour of the Kiali-powered pages (Overview, Traffic Graph, and the rest), see the [OSSMC User Guide](/docs/ossmc/users-guide/).
