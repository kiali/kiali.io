---
title: "Health"
weight: 2
---

Kiali help users know whether their service mesh is healthy. This includes the health of the mesh infrastructure itself, and the deployed application services.

## Service Mesh Infrastructure Health

Users can quickly confirm the health of their infrastructure by looking at the Kiali Masthead. If Kiali detects any health issues with the infrastructure of the mesh it will show an indication in the masthead, severity will be reflected via color, and hovring will show the detail:

![Masthead Health](/images/documentation/features/health-masthead.png "Masthead Health")

## Overview Health

The default Kiali page is an Overview Dashboard.  This view will quickly allow you to identify namespaces with issues.  It provides a summary of configuration health, component health and request traffic health.  The component health is selectable via a dropdown and the page offers various filter, sort and presentation options:

![Overview Health](/images/documentation/features/health-overview.png "Overview Health")

## Graph Health

The Kiali Graph offers a rich visualization of your service mesh traffic.  The health of Nodes and Edges is represented via a standard color system using shades of orange and red to reflect degraded and failure-level traffic health.  Red or orange nodes or edges may need attention. The color of an edge represents the request health between the relevant nodes. Note that node shape indicates the type of component, such as service, workload, or app.

The health of nodes and edges is refreshed automatically based on the user's preference. The graph can also be paused to examine a particular state, or replayed to re-examine a particular time period.

![Graph Health](/images/documentation/features/health-graph.png "Graph Health")

## Health Configuration

Kiali calculates health by combining the individual health of several indicators, such as pods and request traffic.  The _global health_ of a resource reflects the most severe health of its indicators.

### Health Indicators

The table below lists the current health indicators and whether the indicator supports custom configuration for its health calculation.

|Indicator        |Supports Configuration   |
|-----------------|---|
|Pod Status       |No   |
|Traffic Health   |Yes  |

<br />

### Icons and colors

Kiali uses icons and colors to indicate the health of resources and associated request traffic.

<div style="display: flex;">
  <ul>
    <li>
      <img src="/images/documentation/health-configuration/no_health.png" style="width: 40px;height: 40px" /> No Health Information (NA)
    </li>
    <li>
      <img src="/images/documentation/health-configuration/healthy.png" style="width: 40px;height: 40px" /> Healthy
    </li>
    <li>
      <img src="/images/documentation/health-configuration/degraded.png" style="width: 40px;height: 40px" /> Degraded
    </li>
    <li>
      <img src="/images/documentation/health-configuration/failure.png" style="width: 40px;height: 40px" /> Failure
    </li>
  </ul>
</div>

### Custom Request Health

There are times when Kiali's default thresholds for traffic health do not work well for a particular situation.  For example, at times 404 response codes are expected.  Kiali has the ability to set powerful, fine-grained overrides for health configuration.  For details, see [Traffic Health Configuration]({{< ref "docs/configuration/health" >}}).

