---
title: "Topology"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 1
---

The following observability features help you ensure your mesh is healthy or to quickly identify problem areas in operation. It combines topology, telemetry, traces, logs, events and definitions in a holistic view of your system.

## Overview

Kiali provides a summary page of the Service Mesh namespaces and the status of their Applications, Workloads and Services.

<a class="image-popup-fit-height" href="/images/documentation/features/overview-v1.22.0.png" title="Visualize your service mesh topology">
    <img src="/images/documentation/features/overview-thumb-v1.22.0.png" style="display:block;margin: 0 auto;" />
</a>

## Graph
The graph provides a powerful way to visualize the topology of your service mesh. It shows you which services communicate with each other and the traffic rates and latencies between them, which helps you visually identify problem areas and quickly pinpoint issues. Kiali provides graphs that show a high-level view of service interactions, a low level view of workloads, or a logical view of applications.

The graph also shows which services are configured with virtual services and circuit breakers. It identifies security issues by identifying traffic not configured as expected. You can observe the traffic flow between components by watching the animation or viewing the metrics.

You can configure the graph to show the namespaces and data that are important to you, and display it in the way that best meets your needs.

<a class="image-popup-fit-height" href="/images/documentation/features/graph-overview-v1.22.0.png" title="Visualize your service mesh topology">
    <img src="/images/documentation/features/graph-overview-thumb-v1.22.0.png" style="display:block;margin: 0 auto;" />
</a>

### Health

Colors in the graph represent the health of your service mesh. A node colored red or orange might need attention. The color of an edge between components represents the health of the requests between those components. The node shape indicates the type of component such as services, workloads, or apps.

The health of nodes and edges is refreshed automatically based on the user's preference. The graph can also be paused to examine a particular state, or replayed to re-examine a particular time period.

<a class="image-popup-fit-height" href="/images/documentation/features/graph-health-v1.22.0.png" title="Visualize the health of your mesh">
    <img src="/images/documentation/features/graph-health-thumb-v1.22.0.png" style="display:block;margin: 0 auto;" />
</a>

### Node Detail
You can drill down into one selected component, whether it's a service, a workload, or an application. Kiali offers detail graphs for any node you choose.

Double click on a graph node and you can see a detailed view centered on that component. It shows you only the incoming requests being served and the outgoing requests being made - all from the point-of-view of that component's telemetry.

You can jump back to the main graph and continue where you left off.

<a class="image-popup-fit-height" href="/images/documentation/features/graph-detailed-v1.22.0.png" title="Focus your graph on a selected component">
    <img src="/images/documentation/features/graph-detailed-thumb-v1.22.0.png" style="display:block;margin: 0 auto;" />
</a>

### Side-Panel

Want to get a quick summary of anything in the graph? Select any node with a single-click and the side panel provides a brief summary for that component. This includes:

* **Charts** showing traffic and response times
* **Health** details
* **Links** to fully-detailed pages
* **Response Code** breakdowns.

Or, click the graph background and the side panel to view an overall summary for the entire graph.

<a class="image-popup-fit-height" href="/images/documentation/features/graph-side-panel-v1.22.0.png" title="Quick summary of a selected component">
    <img src="/images/documentation/features/graph-side-panel-thumb-v1.22.0.png" style="display:block;margin: 0 auto;" />
</a>

### Traffic Animation

Kiali offers several display options for the graph, including traffic animation.

For HTTP traffic, circles represent successful requests while red diamonds represent errors. The more dense the circles and diamonds the higher the request rate. The faster the animation the faster the response times.

TCP traffic is represented by offset circles where the speed of the circles indicates the traffic speed.

<a class="video-popup" href="/images/documentation/features/kiali_traffic_animation-v1.22.0.mp4" title="Visualize your traffic flow">
    <video autoplay muted loop width="1333px" src="/images/documentation/features/kiali_traffic_animation_thumb-v1.22.0.mp4" style="display:block;margin:0 auto;" />
</a>

### Graph Types

Kiali offers four different graph renderings of the mesh telemetry. Each graph type provides a different view of the traffic.

* The **workload** graph provides the a detailed view of communication between workloads.

* The **app** graph aggregates the workloads with the same app labeling, which provides a more logical view.

* The **versioned app** graph aggregates by app, but breaks out the different versions providing traffic breakdowns that are version-specific.

* The **service** graph provides a high-level view, which aggregates all traffic for defined services.

<div style="display: flex;">
    <span style="margin: 0 auto;">
      <a class="image-popup-fit-height" href="/images/documentation/features/graph-type-app-v1.22.0.png" title="Visualize Apps">
          <img src="/images/documentation/features/graph-type-app-thumb-v1.22.0.png" style="width: 660px; display:inline;margin: 0 auto;" />
      </a>
      <a class="image-popup-fit-height" href="/images/documentation/features/graph-type-service-v1.22.0.png" title="Visualize Services">
          <img src="/images/documentation/features/graph-type-service-thumb-v1.22.0.png" style="width: 660px; display:inline;margin: 0 auto;" />
      </a>
    </span>
</div>
<div style="display: flex;">
    <span style="margin: 0 auto;">
      <a class="image-popup-fit-height" href="/images/documentation/features/graph-type-version-app-v1.22.0.png" title="Visualize Versioned Apps">
          <img src="/images/documentation/features/graph-type-version-app-thumb-v1.22.0.png" style="width: 660px; display:inline;margin: 0 auto;" />
      </a>
      <a class="image-popup-fit-height" href="/images/documentation/features/graph-type-workload-v1.22.0.png" title="Visualize Workloads">
          <img src="/images/documentation/features/graph-type-workload-thumb-v1.22.0.png" style="width: 660px; display:inline;margin: 0 auto;" />
      </a>
    </span>
</div>

### Replay

Graph replay is a new feature that lets you examine the past state of your service mesh.

<div id="replay-video" style="display:flex;align-items: center; justify-items: center;">
  <iframe
    width="1333"
    height="704"
    style="display:block;margin:0 auto;"
    src="https://www.youtube.com/embed/CC_dl4zSZiU"
    frameborder="0"
    allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture"
    allowfullscreen>
  </iframe>
</div>

### Operation Nodes

Istio v1.6 introduced [Request Classification](https://istio.io/latest/docs/tasks/observability/metrics/classify-metrics/).  This powerful feature allows users to classify requests into aggregates, called "Operations" by convention, to better understand how a service is being used.  If configured in Istio the Kiali graph can show these as Operation nodes.  The user needs only to enable the "Operation Nodes" display option. Operations can span services, for example, "VIP" may be configured for both CarRental and HotelRental services.  To see total "VIP" traffic then display operation nodes without service nodes.  To see "VIP" traffic specific to each service then also enable the "Service Nodes" display option.

When selected, an Operation node also provides a side-panel view.  And when double-clicked a node detail graph is also provided.

Because operation nodes represent aggregate traffic they are not compatible with Service graphs, which themselves are already logical aggregates. For similar reasons response time information is not available on edges leading into or out of operation nodes.  But by selecting the edge the response time information is available in the side panel (if configured).

Operation nodes are represented as pentagons in the Kiali graph:

<a class="image-popup-fit-height" href="/images/documentation/features/graph-operations-v1.22.0.png" title="Operation Nodes">
    <img src="/images/documentation/features/graph-operations-v1.22.0.png" style="width: 1333px; display:block;margin: 0 auto;" />
</a>

