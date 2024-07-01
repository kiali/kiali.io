---
title: Istio Ambient Mesh
description: Kiali provides visualization for Ambient Mesh components.
---

Kiali provides visualization for Ambient Mesh components: 

* [Control Plane Ambient Mesh](#control-plane-ambient-mesh)
* [Ambient nampespace](#ambient-namespace)
* [Workloads in Mesh](#workloads-in-ambient-mesh)
* [Ambient Telemetry](#ambient-telemetry)

{{% alert color="warning" %}}
The Ambient features are evolving as well as Ambient Mesh. Some of these features are in alpha status.
For enhancements or issues detected, don't hesitate to open a [GitHub issue](https://github.com/kiali/kiali/issues/new/choose). 
{{% /alert %}}

### Control Plane Ambient Mesh

When the Control plane is in Ambient mode, Kiali will show an Ambient label in the control plane card. 
This label means that Kiali has detected a ztunnel (The L4 component for Ambient) in the control plane. 

![Ambient Control Plane](/images/documentation/features/ambient/ambient-control-plane.png)

### Ambient Namespace

When a namespace is included in Ambient Mesh, because it has the Istio Ambient label, Kiali will show the Ambient label in that namespace card: 

![Ambient Data Plane](/images/documentation/features/ambient/ambient-data-plane.png)

### Workloads in Ambient Mesh

When a workload, application or service is part of the Ambient Mesh, it will show a label in the namespace details. When hovering over this label, it will show further information for a workload:

* In Mesh: Indicating that it was included in Ambient, and the traffic is redirected to ztunnel to provide L4 features (L4 authorization and telemetry, and encrypted data transport)

  ![Workload Captured by Ambient](/images/documentation/features/ambient/ztunnel-captured-pod.png)

* In Mesh with waypoint enabled: Additionally, it can include the L7 label which means that has a waypoint proxy deployed (Which provides additional L7 capabilities):

![Workloads Captured by Ambient](/images/documentation/features/ambient/pod-captured.png)

### Ambient Telemetry

The Traffic graph generated with the Ambient telemetry differs a bit that the usual graph, as the HTTP traffic and TCP traffic have different meanings.

The telemetry reported with sidecars represent the kind of traffic for the request (green edges for HTTP, blue edges for TCP).
In Ambient, this information depends on the element reporting the Telemetry. The Ztunnel will report all the traffic as TCP:

![ztunnel graph](/images/documentation/features/ambient/ztunnel-graph.png)

The following _bookinfo_ namespace is in Ambient Mesh with a waypoint proxy enabled, so there is Telemetry reported from ztunnel and from the Waypoint, that's why there are double edges connecting different nodes: 

![Ambient Telemetry](/images/documentation/features/ambient/ambient-telemetry.png)

There is an additional display option, **Waypoint proxies**, for the Ambient Mesh, that will display the waypoint proxies in the graph (This is still a *work in progress* feature):

![Ambient Telemetry](/images/documentation/features/ambient/ambient-telemetry.png)