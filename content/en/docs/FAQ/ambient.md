---
title: "Ambient"
description: "Questions about Ambient Mesh features."
---


### Why I can't see the traffic graph when not using a Waypoint?

There can be multiple reasons, but here there are some troubleshooting steps: 

- Is the application correctly enrolled in Ambient? 
We can check if there is the Ambient label in the control plane card in Kiali, or the namespace is labeled with `istio.io/dataplane-mode=ambient`. 

![Ambient dataplane](/images/documentation/faq/ambient/dataplane.png)

This means that the traffic graph will have L4 metrics if there are traffic, so make sure the traffic selectors are matching this type of traffic:

![Ambient traffic](/images/documentation/faq/ambient/ambient-traffic.png)

At least, Tcp and Ztunnel traffic should be selected.

- Is there any traffic? 

The traffic is created based on the period of time selected. If there are no traffic, the graph won't be shown. 
Try to select a bigger period of time or enable the Display option to see the idle nodes.

![Idle nodes](/images/documentation/faq/ambient/idle-nodes.png)

- Are the right metrics generated in Prometheus?

Kiali requires some metrics and attributes to generate the graph, that can be checked [here]({{< ref "/docs/FAQ/general#requiredmetrics" >}}).

For this particular scenario, the most important ones would be the `istio_tcp_received_bytes_total` and `istio_tcp_sent_bytes_total` where `app=ztunnel`. It can be checked if they exist in Prometheus. 

Other graph issues are listed [here]({{< ref "/docs/FAQ/graph" >}}).

### Why I can't see the traffic graph when the application has a Waypoint proxy?

There can be multiple reasons, but here there are some troubleshooting steps:

- Is the application correctly enrolled in Ambient?
  We can check if there is the Ambient label in the control plane card in Kiali, or the namespace is labeled with `istio.io/dataplane-mode=ambient`.

![Ambient dataplane](/images/documentation/faq/ambient/dataplane.png)

Also, it must be correctly enrolled in a Waypoint proxy. Check the application details and verify that it has the L7 label and a Waypoint proxy link:

![App Enrolled](/images/documentation/faq/ambient/app-enrolled.png)

- Is there any traffic?

The traffic is created based on the period of time selected. If there are no traffic, the graph won't be shown.
Try to select a bigger period of time or enable the Display option to see the idle nodes.

![Idle nodes](/images/documentation/faq/ambient/idle-nodes.png)

- Are the right metrics generated in Prometheus?

Kiali requires some metrics and attributes to generate the graph, that can be checked [here]({{< ref "/docs/FAQ/general#requiredmetrics" >}}).

For this particular scenario, the most important ones would be the `istio_requests_total` where `reporter=waypoint`. It can be checked if they exist in Prometheus.

Other graph issues are listed [here]({{< ref "/docs/FAQ/graph" >}}).

### Why can't I see traces?

In Ambient, Ztunnel doesn't report traces, as the component is limited to L4 metrics. 
This means that the application should be enrolled in Waypoint to have traces. 

If the application is enrolled in a Waypoint proxy, the traces will be created from the Waypoint itself. 
First, check if the Waypoint proxy is generating traces in the Tracing provider:

![Waypoint traces](/images/documentation/faq/ambient/waypoint-traces.png)

If there are not, verify that the Waypoint proxy is handling traffic.

If there are, verify that the Waypoint proxy has traces in Kiali.

![Waypoint traces Kiali](/images/documentation/faq/ambient/waypoint-traces-kiali.png)

If there are not, there might be a problem configuring the [distributed tracing]({{< ref "/docs/FAQ/distributed-tracing" >}}). 

If there traces, from Kiali 2.5.0, they will be filtered by the service name to be shown in the application details. 

![Kiali app traces](/images/documentation/faq/ambient/kiali-app-traces.png)

In that case, there are some validations to perform:

- Kiali version is >= 2.5.0
- The service name is the operation name that appears in the traces. Check the Kiali logs for further information.

### Why do I see double edges in the Graph?

When the application is part of the Ambient Mesh and also has a Waypoint proxy, it can happen that there are telemetry from L4 (Ztunnel) and L7 (Waypoint). 

![Duplicated Edges](/images/documentation/faq/ambient/duplicated-edges.png)

We can filter by just the Waypoint Traffic to remove the same telemetry reported from different components.

![Waypoint traffic](/images/documentation/faq/ambient/waypoint-traffic.png)

### Related documentation

- Other tracing issues can be checked [here]({{< ref "/docs/FAQ/distributed-tracing" >}}).
- Ambient documentation is [here]({{< ref "/docs/features/ambient" >}}).