---
title: Istio Ambient Mesh
description: Visualizing Ambient Mesh with Kiali
---

Kiali provides visualization for Ambient Mesh components: 

* [Control Plane Ambient Mesh](#control-plane-ambient-mesh)
* [Ambient nampespace](#ambient-namespace)
* [Workloads in Ambient Mesh](#workloads-in-ambient-mesh)
* [Waypoint proxy details](#waypoint-proxy-details)
* [Ztunnel details](#ztunnel-details)
* [Ambient Telemetry](#ambient-telemetry)
* [Ambient tracing](#ambient-tracing)

{{% alert color="warning" %}}
The Kiali Ambient features, as well as Ambient Mesh, are evolving. Some of these features are in alpha status. For enhancements or detected issues, don’t hesitate to open a [GitHub issue](https://github.com/kiali/kiali/issues/new/choose). 
{{% /alert %}}

### Control Plane Ambient Mesh

When the control plane is in Ambient mode, Kiali will show an Ambient badge on the Overview page control plane namespace card.  It will also be reflected in the control plane side-panel on the Mesh page.
This badge indicates that Kiali has detected a ztunnel (the L4 component for Ambient) in the control plane.

![Ambient Control Plane](/images/documentation/features/ambient/ambient-control-plane.png)

{{% alert color="warning" %}}
For Kiali to detect Ambient, it needs to have access to the namespace were ztunnel is deployed. This is usually the istio namespace, but on platforms such as OpenShift, it may differ.
{{% /alert %}}

### Ambient Namespace

When a namespace is labeled with `istio.io/dataplane-mode=ambient` it is included in Ambient Mesh, and Kiali will show the Ambient badge on that Overview page namespace card: 

![Ambient Data Plane](/images/documentation/features/ambient/ambient-data-plane.png)

### Workloads in Ambient Mesh

When a workload, application, or service is part of the Ambient Mesh, a badge will appear in the namespace details. When hovering over this badge, further information about the workload will be displayed:

* In Mesh: Indicating that it was included in Ambient, and the traffic is redirected to ztunnel to provide L4 features (L4 authorization and telemetry, and encrypted data transport)

![Workload Captured by Ambient](/images/documentation/features/ambient/ztunnel-captured-pod.png)

* In Mesh with waypoint enabled: Additionally, it can include the L7 badge which means that a waypoint proxy is deployed (providing additional L7 capabilities):

![Workloads Captured by Ambient](/images/documentation/features/ambient/pod-captured.png)

* It is possible to check each pod protocol in the information tooltip. In Ambient, instead of TCP, it uses HBONE. 

![Pod details protocol](/images/documentation/features/ambient/protocol.png)

* When the workload traffic is handled by a waypoint, the workload details will show a link to the proxy:

![Waypoint link](/images/documentation/features/ambient/waypoint-link.png)

* Kiali will correlate the ztunnel and waypoint logs related to the application and provide a checkbox to include them with the application logs. This ensures that all relevant information for the application is available in one place:

![Workload logs](/images/documentation/features/ambient/ambient-logs.png)

### Waypoint proxy details

The workload details for a waypoint has specific waypoint data. It is identified with the L7 label: 

![Waypoint label](/images/documentation/features/ambient/waypoint-label.png)

The proxy status shows a new info message when some of the Discovery Services are IGNORED, and there are no other errors: 

![Waypoint proxy status](/images/documentation/features/ambient/waypoint-proxy-status.png)

This condition is usually expected, but it is shown as an info in case it is not. 

The waypoint proxy generates traces for the services for which it handles traffic, and this is where it can be checked, because the proxy generates the traces with the waypoint service name:

![Waypoint traces](/images/documentation/features/ambient/waypoint-traces.png)

Waypoint proxies have a specific tab to show information about the Services and Workloads enrolled. 
The `Labeled by` label identifies where the waypoint label was added. It can be in the namespace, in the service or the workload.

![waypoint_tab](/images/documentation/features/ambient/waypoint-tab.png)

For waypoint proxies, it is also possible to see the Envoy tab: 

![Waypoint Envoy](/images/documentation/features/ambient/waypoint-envoy.png)

### Ztunnel details

The workload details for a ztunnel workload has specific data. It has a new ztunnel tab containing the configuration for the services and workloads for which it handles traffic. 
It shows the same information that can be seen using the `istioctl ztunnel-config`, which can be useful for troubleshooting. 

![Ztunnel details](/images/documentation/features/ambient/ztunnel-details.png)

### Ambient Telemetry

The Traffic graph generated with Ambient telemetry differs slightly from the usual graph, as the HTTP traffic and TCP traffic have different reporters.

The telemetry reported with sidecars represents the kind of traffic for the request (green edges for HTTP, blue edges for TCP).
In Ambient, this information depends on the element reporting the Telemetry. The ztunnel will report all the traffic as TCP:

![ztunnel graph](/images/documentation/features/ambient/ztunnel-graph.png)

The following _bookinfo_ namespace is in Ambient Mesh with a waypoint proxy enabled. Therefore, the telemetry is reported from ztunnel and from the waypoint, resulting in double edges connecting different nodes (Note that the Graph page toolbar offers a `Traffic` menu, letting you be selective about the protocols shown): 

![Ambient Telemetry](/images/documentation/features/ambient/ambient-telemetry.png)

It is possible to filter the traffic by the Ambient reporter (ztunnel or waypoint) from the Traffic menu option: 

![Ambient Traffic selector](/images/documentation/features/ambient/traffic-selector.png)

There is an additional display option, **waypoint proxies** for the Ambient Mesh, that will display the waypoint proxies in the graph:

![Waypoint proxies](/images/documentation/features/ambient/waypoint-proxies.png)

The waypoint proxies often serve as both the source and destination of traffic within the same workload, represented in the graph by bidirectional edges. 
When you click on an edge, the summary panel will display the waypoint proxy as the destination workload. However, you can also view the waypoint as the source by clicking on the double arrow icon located to the left of the "From/To" labels in the summary panel.

![bidirectional edges](/images/documentation/features/ambient/double-edges.png)

When the ingress waypoint routing is enabled on a service (`istio.io/ingress-use-waypoint=true`), the traffic goes from the gateway to the waypoint, instead of going to the service. 
In that case, the gateway node will show the waypoint icon:

![ingress use waypoint](/images/documentation/features/ambient/gateway-waypoint.png)

#### Ambient Tracing

Ambient traces are emitted from the waypoint proxies. The traces involving a workload can be found looking for the waypoint service name. 

In order to correlate the waypoint traces from a specific workload, app or service, Kiali looks for traces of the waypoint proxy in which the workload is enrolled. It then filters the traces related to the application using the operation name from the span. 

![ambient traces](/images/documentation/features/ambient/ambient-traces.png)

The same approach is used to show the spans in the workload logs: 

![ambient span logs](/images/documentation/features/ambient/ambient-span-logs.png)

Also for the inbound and outbound metrics:

![ambient spans](/images/documentation/features/ambient/ambient-spans.png)

As the workload name is not part of the trace information, there are some gaps in the trace overlay (These gaps will hopefully be fixed in upstream Istio in a future Istio release - see this [GitHub issue](https://github.com/kiali/kiali/issues/8108) for details on that enhancement request). Also, for the workload view, there might be traces that are not part of a particular workload, but they are shown because they match the service name of the workload.

![Trace overlay](/images/documentation/features/ambient/span-overlays.png)

Starting with Istio 1.28, traces are reported using the service name instead of the waypoint name.
Starting with Kiali 2.22, there is a configuration option, `external_services.tracing.use_waypoint_name` (disabled by default), that allows using the waypoint name as the service used for trace lookup.
