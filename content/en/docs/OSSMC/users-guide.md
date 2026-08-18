---
title: "OSSMC User Guide"
description: "User Guide providing a quick tour of OSSMC functionality"
weight: 10
---

The OpenShift Service Mesh Console (OSSMC) is an extension to the OpenShift Console which provides visibility into your Service Mesh. With the OSSMC plugin installed, a new **Service Mesh** menu category is available in the navigation menu on the left side of the web console.

Which pages appear depends on whether a Kiali server is connected to the plugin:

* **With a connected Kiali server** — When a Kiali instance is connected and reachable, OSSMC provides the full Kiali-powered experience: dedicated list and detail pages for mesh components, plus **Service Mesh** tabs on OpenShift **Workloads**, **Services**, **Projects**, and **Istio configuration** detail pages. The features match those of the standalone Kiali Console, organized to integrate with the OpenShift Console.
* **Without a connected Kiali server** — When no Kiali instance is connected (or Kiali is not reachable), OSSMC still provides **Istio control planes** and **Kiali instances** pages that list every Istio and Kiali CR on the cluster. These pages do not require a Kiali server and are especially useful for navigating many mesh instances from one console. See [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/).

The OSSMC plugin does not replace the standalone Kiali Console. After installing OSSMC, you can still access Kiali through its own route when a Kiali server is deployed. This User Guide discusses the extensions you see from within the OpenShift Console itself — primarily the Kiali-powered pages. For **Istio control planes** and **Kiali instances**, see [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/).

{{% alert color="warning" %}}
The OSSMC [only supports a single tenant today](https://github.com/kiali/openshift-servicemesh-plugin/issues/187). Whether that tenant is configured to access only a subset of OpenShift projects or has access cluster-wide to all projects does not matter, however, only a single tenant can be accessed.
{{% /alert %}}

## Service Mesh Navigation

The OSSMC plugin adds a **Service Mesh** category to the OpenShift Console sidebar. The pages available depend on whether a Kiali server is connected to the plugin.

### Pages that require a connected Kiali server

When a Kiali instance is connected and reachable, the following pages appear in the Service Mesh menu. Each is documented in its own section later in this guide.

* **Overview** — Namespace summary with health and metric cards
* **Traffic Graph** — Full mesh topology view
* **Mesh** — Istio infrastructure status
* **Namespaces** — Namespace list with health, labels, and detail links
* **Applications** — Application list with a dedicated detail page
* **Services** — Service list with detail pages
* **Workloads** — Workload list with health, type, and Istio configuration
* **Istio Config** — Istio configuration list with validation status

All of these pages are standalone routes within the OSSMC plugin, providing a consistent Kiali-powered experience without leaving the OpenShift Console context.

OSSMC connects to the connected Kiali instance through the plugin proxy configured on the OSSMConsole CR. **Service Mesh** tabs on workload, service, project, and Istio resource detail pages are also available when a Kiali server is connected.

If OSSMC is configured to use a Kiali server but cannot connect to it, pages that require Kiali show a **Service Mesh is not configured** message with guidance to install and configure Kiali through the Kiali Operator. **Istios** and **Kialis** remain available — see [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/).

If a page that requires Kiali fails unexpectedly, OSSMC displays a **Service Mesh Console Unavailable** message instead of affecting the rest of the OpenShift Console. If you use the **Fleet Service Mesh** perspective and are not using those Kiali-backed pages on that cluster, you can ignore this message.

### Navigating Multiple Meshes with OSSMC

**Istios** and **Kialis** are always available in the Service Mesh menu. When a Kiali server is also connected, they appear at the bottom of the menu below a separator. Use them to browse every Istio and Kiali instance on the cluster and to connect or disconnect which Kiali server the plugin uses for observability.

See [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/) for details.

## Overview

The **Overview** page provides a summary of your mesh by showing cards representing the namespaces participating in the mesh. Each namespace card has summary metric graphs and additional health details. There are links in the cards that take you to other pages within OSSMC.

![Overview](/images/documentation/ossmc/05-overview.png)

## Traffic Graph

The **Traffic Graph** page provides the full topology view of your mesh. The mesh is represented by nodes and edges — each node representing a component of the mesh and each edge representing traffic flowing through the mesh between components.

![Graph](/images/documentation/ossmc/06-graph.png)

## Mesh

The **Mesh** page provides detailed information about the Istio infrastructure status. It shows an infrastructure topology view with core and add-on components, their health, and how they are connected to each other.

![Mesh](/images/documentation/ossmc/07-mesh.png)

## Namespaces

The **Namespaces** page provides a list of namespaces participating in the mesh along with their health status and labels. Clicking a namespace opens a detail page with a split-panel layout: the left panel contains stacked cards showing namespace attributes, resource links, and health information, while the right panel displays a namespace-scoped traffic minigraph.

![Namespaces](/images/documentation/ossmc/08-namespaces.png)

## Applications

The **Applications** page provides a list of applications detected in the mesh. Clicking an application opens a dedicated detail page with sub-tabs for Overview, Traffic, Inbound Metrics, and Traces. The application detail page displays an application badge and provides the same level of detail as the standalone Kiali Console.

![Applications](/images/documentation/ossmc/09-applications.png)

## Services

The **Services** page provides a list of services in the mesh. Clicking a service opens a detail page with sub-tabs for Overview, Traffic, Inbound Metrics, and Traces.

![Services](/images/documentation/ossmc/10-services.png)

## Workloads

The **Workloads** page provides a list of workloads in the mesh along with their health status, type, and associated Istio configuration. Clicking a workload navigates to the corresponding Kubernetes resource detail page (Deployment, ReplicaSet, DaemonSet, StatefulSet, etc.) with the Service Mesh tab selected.

![Workloads](/images/documentation/ossmc/11-workloads.png)

## Istio Config

The **Istio Config** page provides a list of all Istio configuration files in your mesh with a column that provides a quick way to know if the configuration for each resource is valid. You can also create new Istio configuration resources from this page. The list page uses Kiali's full filtering capabilities, including type, name, and validation status filters.

![Istio Config](/images/documentation/ossmc/12-istioconfig.png)

## Workload Details

The **Workloads** detail view (accessible from the OpenShift **Workloads** pages such as Deployments, Pods, ReplicaSets, StatefulSets, and DaemonSets) has a tab **Service Mesh** that provides mesh-related detail for the selected workload. The details are grouped into several sub-tabs: Overview, Traffic, Logs, Inbound Metrics, Outbound Metrics, Traces, and Envoy.

### Workload: Overview

The **Workload: Overview** sub-tab provides a summary of the selected workload including a localized topology graph showing the workload with all inbound and outbound edges and nodes.

![Workload: Overview](/images/documentation/ossmc/13-workload-overview.png)

### Workload: Traffic

The **Workload: Traffic** sub-tab provides information about all inbound and outbound traffic to the workload.

![Workload: Traffic](/images/documentation/ossmc/14-workload-traffic.png)

### Workload: Logs

The **Workload: Logs** sub-tab provides the logs for the workload's containers. You can view container logs individually or in a unified fashion, ordered by log time. This is especially helpful to see how the Envoy sidecar proxy logs relate to your workload's application logs. You can enable the tracing span integration which then allows you to see which logs correspond to trace spans.

![Workload: Logs](/images/documentation/ossmc/15-workload-logs.png)

### Workload: Metrics

You can see both inbound and outbound metric graphs in the corresponding sub-tabs. All the workload metrics can be displayed here, providing you with a detail view of the performance of your workload. You can enable the tracing span integration which allows you to see which spans occurred at the same time as the metrics. You can then click on a span marker in the graph to view the specific spans associated with that timeframe.

![Workload: Metrics](/images/documentation/ossmc/16-workload-metrics.png)

### Workload: Traces

The **Traces** sub-tab provides a chart showing the trace spans collected over the given timeframe. Click on a bubble to drill down into those trace spans; the trace spans can provide you the most low-level detail within your workload application, down to the individual request level.

![Workload: Traces](/images/documentation/ossmc/17-workload-traces.png)

The trace details view will give further details, including heatmaps that provide you with a comparison of one span in relation to other requests and spans in the same timeframe.

![Workload: Traces Details](/images/documentation/ossmc/18-workload-traces-details.png)

When the OpenShift tracing UI plugin is enabled, Kiali will try to auto discover the plugin settings and the `View in Tracing` Kiali link will redirect to the plugin (for Kiali 2.8.0+).
If the plugin config needs to be adjusted, the following settings should be included in the `plugin-conf` ConfigMap:

```yaml
{
  ...
  "observability": {
    "instance": "sample",
    "namespace": "tempo",
    "tenant": "default"
  }
}
```

### Workload: Envoy

The **Envoy** sub-tab provides information about the Envoy sidecar configuration. This is useful when you need to dig down deep into the sidecar configuration when debugging things such as connectivity issues.

![Workload: Envoy](/images/documentation/ossmc/19-workload-envoy.png)

## Application Details

The **Applications** detail page provides mesh-related detail for the selected application, including a localized topology graph, traffic information, inbound metrics, and traces. The detail page is accessible both from the OSSMC Applications list page and from graph node navigation.

![Application Details](/images/documentation/ossmc/20-applications-overview.png)

## Service Details

The **Services** detail view has a tab **Service Mesh** that provides mesh-related detail for the selected service. The details are grouped into several sub-tabs: Overview, Traffic, Inbound Metrics, Traces. These sub-tabs are similar in nature as the Workload sub-tabs with the same names and serve the same functions.

![Services: Overview](/images/documentation/ossmc/21-services-overview.png)

## Project Details

The **Projects** detail view has a tab **Service Mesh** that provides mesh-related detail for that project with a split-panel layout showing project attributes, resource links, health information, and a namespace-scoped traffic minigraph.

![Projects: Overview](/images/documentation/ossmc/22-projects-overview.png)

## Istio Config Details

The detail pages for **Istio configuration resources** (such as VirtualService, DestinationRule, Gateway, AuthorizationPolicy, and others) have a **Service Mesh** tab that shows an overview and validation status for the resource.

![Istio Config Details](/images/documentation/ossmc/23-istioconfig-details.png)
