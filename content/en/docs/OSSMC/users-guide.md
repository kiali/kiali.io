---
title: "OSSMC User Guide"
description: "User Guide providing a quick tour of OSSMC functionality"
weight: 10
---

The OpenShift Service Mesh Console (OSSMC) is an extension to the OpenShift Console which provides visibility into your Service Mesh. With the OSSMC plugin installed, a new **Service Mesh** menu category is available in the navigation menu on the left side of the web console, as well as new **Service Mesh** tabs that enhance the existing **Workloads** and **Services** OpenShift console detail pages.

The features of the OSSMC plugin are the same as those of the standalone Kiali Console, but the pages are organized differently to better integrate with the OpenShift console. The OSSMC plugin does not replace the Kiali Console, and after installing the OSSMC plugin, you can still access the standalone Kiali Console. This User Guide, however, will discuss the extensions you see from within the OpenShift Console itself.

{{% alert color="warning" %}}
The OSSMC [only supports a single tenant today](https://github.com/kiali/openshift-servicemesh-plugin/issues/187). Whether that tenant is configured to access only a subset of OpenShift projects or has access cluster-wide to all projects does not matter, however, only a single tenant can be accessed.
{{% /alert %}}

## Overview

The **Overview** page provides a summary of your mesh by showing cards representing the namespaces participating in the mesh. Each namespace card has summary metric graphs and additional health details. There are links in the cards that take you to other pages within OSSMC.

![Overview](/images/documentation/installation/installation-guide/20-overview.png)

## Traffic Graph

The **Traffic Graph** page provides the full topology view of your mesh. The mesh is represented by nodes and edges - each node representing a component of the mesh and each edge representing traffic flowing through the mesh between components.

![Graph](/images/documentation/installation/installation-guide/21-graph.png)

## Istio Config

The **Istio Config** page provides a list of all Istio configuration files in your mesh with a column that provides a quick way to know if the configuration for each resource is valid.

![Istio Config](/images/documentation/installation/installation-guide/22-istioconfig.png)

## Mesh

The **Mesh** page provides detailed information about the Istio infrastructure status. It shows an infrastructure topology view with core and add-on components, their health, and how they are connected to each other.

![Istio Config](/images/documentation/installation/installation-guide/22-mesh.png)

## Workload

The **Workloads** view has a tab **Service Mesh** that provides a lot of mesh-related detail for the selected workload. The details are grouped into several sub-tabs: Overview, Traffic, Logs, Inbound Metrics, Outbound Metrics, Traces, and Envoy.

### Workload: Overview

The **Workload: Overview** sub-tab provides a summary of the selected workload including a localized topology graph showing the workload with all inbound and outbound edges and nodes.

![Workload: Overview](/images/documentation/installation/installation-guide/23-workload.png)

### Workload: Traffic

The **Workload: Traffic** sub-tab provides information about all inbound and outbound traffic to the workload.

![Workload: Traffic](/images/documentation/installation/installation-guide/24-workload-traffic.png)

### Workload: Logs

The **Workload: Logs** sub-tab provides the logs for the workload's containers. You can view container logs individually or in a unified fashion, ordered by log time. This is especially helpful to see how the Envoy sidecar proxy logs relate to your workload's application logs. You can enable the tracing span integration which then allows you to see which logs correspond to trace spans.

![Workload: Logs](/images/documentation/installation/installation-guide/25-workload-logs.png)

### Workload: Metrics

You can see both inbound and outbound metric graphs in the corresponding sub-tabs. All the workload metrics can be displayed here, providing you with a detail view of the performance of your workload. You can enable the tracing span integration which allows you to see which spans occurred at the same time as the metrics. You can then click on a span marker in the graph to view the specific spans associated with that timeframe.

![Workload: Metrics](/images/documentation/installation/installation-guide/26-workload-metrics.png)

### Workload: Traces

The **Traces** sub-tab provides a chart showing the trace spans collected over the given timeframe. Click on a bubble to drill down into those trace spans; the trace spans can provide you the most low-level detail within your workload application, down to the individual request level.

![Workload: Traces](/images/documentation/installation/installation-guide/27-workload-traces.png)

The trace details view will give further details, including heatmaps that provide you with a comparison of one span in relation to other requests and spans in the same timeframe.

![Workload: Traces Details](/images/documentation/installation/installation-guide/28-workload-traces-details.png)

If you hover over a cell in a heatmap, a tooltip will give some details on the cell data:

![Workload: Traces Heatmap](/images/documentation/installation/installation-guide/29-workload-traces-heatmap.png)

When the OpenShift tracing UI plugin is enabled, Kiali will try to auto discover the plugin settings and the `View in Tracing` Kiali link will redirect to the plugin (for Kiali 2.8.0+). 
If the plugin config needs to be adjusted, the following settings should be updated:

```yaml
{
  "observability": {
    "instance": "sample",
    "namespace": "tempo",
    "tenant": "default"
  }
}
```

### Workload: Envoy

The **Envoy** sub-tab provides information about the Envoy sidecar configuration. This is useful when you need to dig down deep into the sidecar configuration when debugging things such as connectivity issues.

![Workload: Envoy](/images/documentation/installation/installation-guide/30-workload-envoy.png)

## Services

The **Services** view has a tab **Service Mesh** that provides mesh-related detail for the selected service. The details are grouped into several sub-tabs: Overview, Traffic, Inbound Metrics, Traces. These sub-tabs are similar in nature as the Workload sub-tabs with the same names and serve the same functions.

![Services: Overview](/images/documentation/installation/installation-guide/31-services-overview.png)

## Projects

The **Projects** view has a tab **Service Mesh** that provides traffic graph information about that project. It is the same information shown in the [**Traffic Graph**](#traffic-graph) page but specific to that project.

![Projects: Overview](/images/documentation/installation/installation-guide/32-projects-graph.png)
