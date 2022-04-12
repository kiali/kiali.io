---
title: "Observe"
description: "Observability with Kiali: graphs, metrics, logs, tracing..."
weight: 4
---

## Enable Sidecars in all workloads

An Istio sidecar proxy adds a workload into the mesh.

Proxies connect with the control plane and provide [Service Mesh functionality](https://istio.io/latest/about/service-mesh/#what-is-istio).

Automatically providing metrics, logs and traces is a major feature of the sidecar.

In the previous steps we have added a sidecar only in the *travel-control* namespace's *control* workload.

We have added new powerful features but the application is still missing visibility from other workloads.

{{% alert title="Step 1" color="success" %}}
Switch to the Workload graph and select multiple namespaces to identify missing sidecars in the Travel Demo application
{{% /alert %}}

![Missing Sidecars](/images/tutorial/04-01-missing-sidecars.png "Missing Sidecars")

That *control* workload provides good visibility of its traffic, but telemetry is partially enabled, as *travel-portal* and *travel-agency* workloads don't have sidecar proxies.

{{% alert title="Step 2" color="success" %}}
Enable proxy injection in *travel-portal* and *travel-agency* namespaces
{{% /alert %}}

In the First Steps of this tutorial we didn't inject the sidecar proxies on purpose to show a scenario where only some workloads may have sidecars.

Typically, Istio users annotate namespaces before the deployment to allow Istio to automatically add the sidecar when the application is rolled out into the cluster. Perform
the following commands:

```
kubectl label namespace travel-agency istio-injection=enabled
kubectl label namespace travel-portal istio-injection=enabled

kubectl rollout restart deploy -n travel-portal
kubectl rollout restart deploy -n travel-agency
```

<br />

Verify that *travel-control*, *travel-portal* and *travel-agency* workloads have sidecars deployed:

![Updated Workloads](/images/tutorial/04-01-updated-workloads.png "Updated Workloads")

{{% alert title="Step 3" color="success" %}}
Verify updated telemetry for *travel-portal* and *travel-agency* namespaces
{{% /alert %}}

![Updated Telemetry](/images/tutorial/04-01-updated-telemetry.png "Updated Telemetry")

## Graph walkthrough

The graph provides a powerful set of [Graph Features]({{< ref "/docs/Features/topology" >}}) to visualize the traffic topology of the service mesh.

In this step, we will show how to use the Graph to show relevant information in the context of the Travel Demo application.

Our goal will be to identify the most critical service of the demo application.

{{% alert title="Step 1" color="success" %}}
Select all *travel-* namespaces in the graph and enable *Traffic Distribution* edge labels in the Display Options:
{{% /alert %}}

![Graph Request Distribution](/images/tutorial/04-02-graph-request-distribution.png "Graph Request Distribution")

Review the status of the mesh, everything seems healthy, but also note that *hotels* service has more load compared to other services inlcuded in the *travel-agency* namespace.

{{% alert title="Step 2" color="success" %}}
Select the *hotels* service, use the graph side-panel to select a trace from the Traces tab:
{{% /alert %}}

![Hotels Normal Trace](/images/tutorial/04-02-hotels-normal-trace.png "Hotels Normal Trace")

Combining telemetry and tracing information will show that there are traces started from a portal that involve multiple services but also other traces that only consume the *hotels* service.

![Hotels Single Trace](/images/tutorial/04-02-hotels-single-trace.png "Hotels Single Trace")

{{% alert title="Step 3" color="success" %}}
Select the main *travels* application and double-click to zoom in
{{% /alert %}}

![Travels Zoom](/images/tutorial/04-02-travels-zoom.png "Travels Zoom")

The graph can focus on an element to study a particular context in detail. Note that a contextual menu is available using
right-click, to easily shortcut the navigation to other sections.

## Application details

Kiali provides [Detail Views]({{< ref "/docs/Features/details" >}}) to navigate into applications, workloads and services.

These views provide information about the structure, health, metrics, logs, traces and Istio configuration for any application component.

In this tutorial we are going to learn how to use them to examine the main *travels* application of our example.

{{% alert title="Step 1" color="success" %}}
Navigate to the *travels* application
{{% /alert %}}

![Travels Application](/images/tutorial/04-03-travels-application.png "Travels Application")

An *application* is an abstract group of workloads and services labeled with the same "application" name.

From Service Mesh perspective this concept is significant as telemetry and tracing signals are mainly grouped by "application" even if multiple workloads are involved.

At this point of the tutorial, the *travels* application is quite simple, just a *travels-v1* workload exposed through the *travels* service. Navigate to the
*travels-v1* workload detail by clicking the link in the *travels* application overview.

![Travels-v1 Workload](/images/tutorial/04-03-travels-v1-workload.png "Travels-v1 Workload")

{{% alert title="Step 2" color="success" %}}
Examine *Outbound Metrics* of *travels-v1* workload
{{% /alert %}}

![Travels-v1 Metrics](/images/tutorial/04-03-travels-v1-metrics.png "Travels-v1 Metrics")

The Metrics tab provides a powerful visualization of telemetry collected by the Istio proxy sidecar. It presents a dashboard of charts, each of which can be
expanded for closer inspection. Expand the *Request volume* chart:

![Travels-v1 Request Volume Chart](/images/tutorial/04-03-travels-v1-metrics-request-volume.png "Travels-v1 Request Volume Chart")

Metrics Settings provides multiple predefined criteria out-of-the-box.  Additionally, enable the *spans* checkbox to correlate metrics and tracing spans
in a single chart.

We can see in the context of the Travels application, the *hotels* service request volume differs from that of the other *travel-agency* services.

By examining the Request Duration chart also shows that there is no suspicious delay, so probably this asymmetric volume is part of the application business' logic.

{{% alert title="Step 3" color="success" %}}
Review *Logs* of *travels-v1* workload
{{% /alert %}}

The Logs tab provides a unified view of application container logs with the Istio sidecar proxy logs. It also offers a *spans* checkbox, providing
a correlated view of both logs and tracing, helping identify spans of interest.

From the application container log we can spot that there are two main business methods: *GetDestinations* and *GetTravelQuote*.

In the Istio sidecar proxy log we see that *GetDestinations* invokes a `GET /hotels` request without parameters.

![Travels-v1 Logs GetDestinations](/images/tutorial/04-03-travels-v1-logs-getdestinations.png "Travels-v1 Logs GetDestinations")

However, *GetTravelQuote* invokes multiple requests to other services using a specific city as a parameter.

![Travels-v1 Logs GetTravelQuote](/images/tutorial/04-03-travels-v1-logs-gettravelquote.png "Travels-v1 Logs GetTravelQuote")

Then, as discussed in the [Travel Demo design]({{< relref "./02-install-travel-demo/#travel-agency-namespace" >}}), an initial query returns all available hotels before letting the user choose one and then get specific quotes for other destination services.

That scenario is shown in the increase of the *hotels* service utilization.

{{% alert title="Step 4" color="success" %}}
Review *Traces* of *workload-v1*
{{% /alert %}}

Now we have identified that the *hotels* service has more use than other *travel-agency* services.

The next step is to get more context to answer if some particular service is acting slower than expected.

The Traces tab allows comparison between traces and metrics histograms, letting the user determine if a particular spike is expected in the context of average values.

![Travels-v1 Traces](/images/tutorial/04-03-travels-v1-tracing-details.png "Travels-v1 Traces")

In the same context, individual *spans* can be compared in more detail, helping to identify a problematic step in the broader scenario.

![Travels-v1 Spans](/images/tutorial/04-03-travels-v1-tracing-spans.png "Travels-v1 Spans")

