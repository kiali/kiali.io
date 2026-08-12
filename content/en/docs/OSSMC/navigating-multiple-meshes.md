---
title: "Navigating Multiple Meshes with OSSMC"
linkTitle: "Navigating Multiple Meshes"
description: "Browse and manage Istio and Kiali instances in the OpenShift Console — without requiring a Kiali server connected to the plugin."
weight: 5
---

OpenShift Service Mesh Console (OSSMC) includes **Istio control planes** and **Kiali instances** pages in the OpenShift Console **Service Mesh** menu. These pages let you browse and inspect every Istio and Kiali CR on the cluster directly from the console — without requiring a Kiali server to be connected to the plugin.

This is especially useful when a cluster hosts many mesh instances. Platform teams that operate dozens or hundreds of Istio control planes (and the Kiali instances that observe them) on a cluster can navigate that inventory in one place instead of jumping between CLI commands, individual operator UIs, or separate Kiali routes.

## Why this matters

* **One inventory for the whole cluster** — List every Istio CR and every Kiali CR from the OpenShift Console sidebar.
* **No Kiali server required** — The pages talk to the Kubernetes API. You can install the OSSMC plugin independently of any Kiali Server and still get this multi-mesh navigation.
* **Works alongside Kiali-powered observability** — When you do connect a Kiali server to the plugin, Overview, Traffic Graph, and the other observability pages appear for that connected instance. **Istio control planes** and **Kiali instances** stay in the menu so you can still manage the full fleet.

## Istio control planes

The **Istio control planes** page lists every cluster-scoped Istio CR managed by the OSSM/Sail Operator. Open a row to see details for that Istio installation.

Use this page when you need a console view of mesh control-plane instances on the cluster — for example, confirming which Istio CRs exist, opening one for more information, or orienting yourself before connecting a related Kiali instance.

## Kiali instances

The **Kiali instances** page lists every Kiali CR on the cluster. Open a row to see configuration from that Kiali CR.

{{% alert color="warning" %}}
Both pages only list CRs your OpenShift user has permission to read. If your account has namespace-scoped access instead of cluster-wide access to `istios.sailoperator.io` or `kialis.kiali.io`, the list may show fewer instances than actually exist on the cluster — or appear empty. If you expect to see an instance that is missing, ask your cluster administrator to grant `list`/`get` permission on the relevant CR in that namespace (or cluster-wide).
{{% /alert %}}

The list includes:

* **Connected** — Shows **Active** when that Kiali instance is the OSSMC backend, or **Inactive** when it is not. If OSSMConsole resources cannot be read, the status shows **Unknown**.
* **Observe** — When route hosts are available, links to the Kiali UI and the OpenShift Console (**Kiali** | **Console**).
* **Actions** — **Connect** or **Disconnect** to change which Kiali server OSSMC uses.

From the list or detail page you can **Connect** or **Disconnect** a Kiali instance:

* **Connect** — Connects that Kiali server to the OSSMC plugin so Overview, Traffic Graph, Mesh, and the other Kiali-powered pages become available for that instance.
* **Disconnect** — Disconnects that Kiali instance from the plugin. **Istio control planes** and **Kiali instances** remain available so you can keep navigating the fleet and connect a different instance when needed.

Connect and disconnect require permission to patch the OSSMConsole CR (`ossmconsoles.kiali.io`).

{{% alert color="info" %}}
OSSMC [supports a single tenant at a time](https://github.com/kiali/openshift-servicemesh-plugin/issues/187) for Kiali-powered observability pages. Connect the Kiali instance you want to use for deep observability; use **Istio control planes** and **Kiali instances** to navigate the rest of the fleet and switch when needed.
{{% /alert %}}

## When a Kiali server is connected — and when it is not

What you see in the Service Mesh menu depends on whether OSSMC has a connected, reachable Kiali server:

* **When no Kiali server is connected** — Expect **Istio control planes** and **Kiali instances** only.
* **When a Kiali instance is connected and reachable** — Expect observability pages (Overview, Traffic Graph, Mesh, and others) in the menu, with **Istio control planes** and **Kiali instances** at the bottom, below a separator.

If OSSMC is configured to use a Kiali server but cannot reach it, observability pages show a **Service Mesh is not configured** message. **Istio control planes** and **Kiali instances** continue to work — the same as when no server is connected.

## Getting started

1. Install the Kiali Operator (a Kiali server is optional for these pages).
2. Create an OSSMConsole CR to install the plugin — see [The OSSMConsole CR](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/).
3. Open **Service Mesh** → **Istio control planes** or **Kiali instances** in the OpenShift Console.

To connect a Kiali server for deep observability on one instance, use **Connect** on the **Kiali instances** page or set `spec.kiali` on the OSSMConsole CR. See [Connecting a Kiali instance to the console](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/#connecting-a-kiali-instance-to-the-console).

For a tour of the Kiali-powered pages (Overview, Traffic Graph, and the rest), see the [OSSMC User Guide](/docs/ossmc/users-guide/).
