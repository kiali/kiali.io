---
title: "Topology"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 1
---

Kiali offers multiple ways for users to examine their mesh Topology.  Each combines several information types to help users quickly evaluate the health of their service architecture.

## Overview

Kiali's default page is the topology _Overview_.  It presents a high-level view of the namespaces accessible to Kiali, for this user.  It combines service and application information, along with telemetry, validations and health, to provide a holistic summary of system behvior.  The _Overview_ page provides numerous filtering, sorting and presentation options.  From here users can perform namespace-level Actions, or quickly navigate to more detailed views.

![Topology namespace overview](/images/documentation/features/topology-overview.png)


## Graph

The Kiali _Graph_ offers a powerful visualization of your mesh traffic.  The topology combines real-time request traffic with your Istio configuration information to present immediate insight into the behavior of service mesh, allowing you to quickly pinpoint issues.  Multiple _Graph Types_ allow you to visualize traffic as a high-level service topology, a low-level workload topology, or as an application-level topology.

Graph nodes are decorated with a variety of information, pointing out various route routing options like virtual services and service entries, as well as special configuration like fault-injection and circuit breakers.  It can identify mTLS issues, latency issues, error traffic and more.  The _Graph_ is highly configurable, can show traffic animation, and has powerful Find and Hide abilities.

You can configure the graph to show the namespaces and data that are important to you, and display it in the way that best meets your needs.

![Topology graph](/images/documentation/features/topology-graph.png)


### Health

Colors in the graph represent the health of your service mesh. A node colored red or orange might need attention. The color of an edge between components represents the health of the requests between those components. The node shape indicates the type of component such as services, workloads, or apps.

The health of nodes and edges is refreshed automatically based on the user's preference. The graph can also be paused to examine a particular state, or replayed to re-examine a particular time period.

![Topology graph health](/images/documentation/features/topology-graph-health.png)


### Side-Panel

The collapsible side-panel summarizes the current graph selection, or the graph as a whole.  A single-click will select the node, edge, or box of interest.  The side panel provides:

* **Charts** showing traffic and response times.
* **Health** details.
* **Links** to fully-detailed pages.
* **Response Code** and Host breakdowns.
* **Traces** involving the selected component.

![Topology graph side-panel app](/images/documentation/features/topology-graph-sidepanel.png)
![Topology graph side-panel service](/images/documentation/features/topology-graph-sidepanel-2.png)
![Topology graph side-panel workload](/images/documentation/features/topology-graph-sidepanel-3.png)


### Node Detail

A single-click selects a graph node.  A double-click drills in to show the node's _Detail Graph_.  The node detail graph visualizes traffic from the point-of-view of that node, meaning
it shows only the traffic reported by that node's Istio proxy.

You can return back to the main graph, or double-click to change to a different node's detail graph.

![Topology graph node detail](/images/documentation/features/topology-graph-node-detail.png)


### Traffic Animation

Kiali offers several display options for the graph, including traffic animation.

For HTTP traffic, circles represent successful requests while red diamonds represent errors. The more dense the circles and diamonds the higher the request rate. The faster the animation the faster the response times.

TCP traffic is represented by offset circles where the speed of the circles indicates the traffic speed.

![Topology graph animation](/images/documentation/features/topology-graph-node-animation.gif)


### Graph Types

Kiali offers four different traffic-graph renderings:

* The **workload** graph provides the a detailed view of communication between workloads.

* The **app** graph aggregates the workloads with the same app labeling, which provides a more logical view.

* The **versioned app** graph aggregates by app, but breaks out the different versions providing traffic breakdowns that are version-specific.

* The **service** graph provides a high-level view, which aggregates all traffic for defined services.

![Topology graph type workload](/images/documentation/features/topology-graph-type-workload.png)
![Topology graph type app](/images/documentation/features/topology-graph-type-app.png)
![Topology graph type versioned app](/images/documentation/features/topology-graph-type-versioned-app.png)
![Topology graph service](/images/documentation/features/topology-graph-type-service.png)


### Replay

Graph replay allows you to replay traffic from a selected past time-period.  This gives you a chance to thoroughly examine a time period of interest, or share it with a co-worker.  The graph is fully bookmarkable, including replay.

{{< youtube CC_dl4zSZiU >}}


### Operation Nodes

Istio v1.6 introduced [Request Classification](https://istio.io/latest/docs/tasks/observability/metrics/classify-metrics/).  This powerful feature allows users to classify requests into aggregates, called "Operations" by convention, to better understand how a service is being used.  If configured in Istio the Kiali graph can show these as Operation nodes.  The user needs only to enable the "Operation Nodes" display option. Operations can span services, for example, "VIP" may be configured for both CarRental and HotelRental services.  To see total "VIP" traffic then display operation nodes without service nodes.  To see "VIP" traffic specific to each service then also enable the "Service Nodes" display option.

When selected, an Operation node also provides a side-panel view.  And when double-clicked a node detail graph is also provided.

Because operation nodes represent aggregate traffic they are not compatible with Service graphs, which themselves are already logical aggregates. For similar reasons response time information is not available on edges leading into or out of operation nodes.  But by selecting the edge the response time information is available in the side panel (if configured).

Operation nodes are represented as pentagons in the Kiali graph:

![Topology graph operation](/images/documentation/features/topology-graph-operation.png)

