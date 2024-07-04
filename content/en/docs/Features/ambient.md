---
title: Istio Ambient Mesh
description: Visualizing Ambient Mesh with Kiali
---

Kiali provides visualization for Ambient Mesh components: 

* [Control Plane Ambient Mesh](#control-plane-ambient-mesh)
* [Ambient nampespace](#ambient-namespace)
* [Workloads in Mesh](#workloads-in-ambient-mesh)
* [Ambient Telemetry](#ambient-telemetry)

{{% alert color="warning" %}}
The Kiali Ambient features, as well as Ambient Mesh, are evolving. Some of these features are in alpha status. For enhancements or detected issues, don’t hesitate to open a [GitHub issue](https://github.com/kiali/kiali/issues/new/choose). 
{{% /alert %}}

### Control Plane Ambient Mesh

When the control plane is in Ambient mode, Kiali will show an Ambient badge on the Overview page control plane namespace card.  It will also be reflected in the control plane side-panel on the Mesh page.
This badge indicates that Kiali has detected a ztunnel (the L4 component for Ambient) in the control plane.

![Ambient Control Plane](/images/documentation/features/ambient/ambient-control-plane.png)

### Ambient Namespace

When a namespace is labeled with `istio.io/dataplane-mode=ambient` it is included in Ambient Mesh, and Kiali will show the Ambient badge on that Overview page namespace card: 

![Ambient Data Plane](/images/documentation/features/ambient/ambient-data-plane.png)

### Workloads in Ambient Mesh

When a workload, application, or service is part of the Ambient Mesh, a badge will appear in the namespace details. When hovering over this badge, further information about the workload will be displayed:

* In Mesh: Indicating that it was included in Ambient, and the traffic is redirected to ztunnel to provide L4 features (L4 authorization and telemetry, and encrypted data transport)

  ![Workload Captured by Ambient](/images/documentation/features/ambient/ztunnel-captured-pod.png)

* In Mesh with waypoint enabled: Additionally, it can include the L7 badge which means that a waypoint proxy is deployed (providing additional L7 capabilities):

![Workloads Captured by Ambient](/images/documentation/features/ambient/pod-captured.png)

### Ambient Telemetry

The Traffic graph generated with the Ambient telemetry differs slightly from the usual graph, as the HTTP traffic and TCP traffic have different reporters.

The telemetry reported with sidecars represents the kind of traffic for the request (green edges for HTTP, blue edges for TCP).
In Ambient, this information depends on the element reporting the Telemetry. The Ztunnel will report all the traffic as TCP:

![ztunnel graph](/images/documentation/features/ambient/ztunnel-graph.png)

The following _bookinfo_ namespace is in Ambient Mesh with a waypoint proxy enabled. Therefore, the telemetry is reported from ztunnel and from the Waypoint, resulting in double edges connecting different nodes: 

![Ambient Telemetry](/images/documentation/features/ambient/ambient-telemetry.png)

There is an additional display option, **Waypoint proxies** for the Ambient Mesh, that will display the waypoint proxies in the graph (This is still a *work in progress* feature):

![Ambient Telemetry](/images/documentation/features/ambient/waypoint-proxies.png)