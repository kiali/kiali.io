---
title: "Observe"
date: 2018-06-20T19:04:38+02:00
draft: false
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
<a class="image-popup-fit-height" href="/images/tutorial/04-01-missing-sidecars.png" title="Missing Sidecars">
    <img src="/images/tutorial/04-01-missing-sidecars.png" style="display:block;margin: 0 auto;" />
</a>

</br>

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

kubectl delete -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml) -n travel-agency
kubectl delete -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml) -n travel-portal

// Wait until all services, deployments and pods are deleted from the travel-agency and travel-portal namespaces

kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml) -n travel-agency
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml) -n travel-portal
```

</br>

Verify that *travel-control*, *travel-portal* and *travel-agency* workloads have sidecars deployed:

<a class="image-popup-fit-height" href="/images/tutorial/04-01-updated-workloads.png" title="Updated Workloads">
    <img src="/images/tutorial/04-01-updated-workloads.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 3" color="success" %}}
Verify updated telemetry for *travel-portal* and *travel-agency* namespaces
{{% /alert %}}
<a class="image-popup-fit-height" href="/images/tutorial/04-01-updated-telemetry.png" title="Updated Telemetry">
    <img src="/images/tutorial/04-01-updated-telemetry.png" style="display:block;margin: 0 auto;" />
</a>

## Graph walkthrough

The graph provides a powerful set of [Graph Features]({{< ref "/docs/Features/topology" >}}) to visualize the traffic topology of the service mesh.

In this step, we will show how to use the Graph to show relevant information in the context of the Travels Demo application.

Our goal will be to identify the most critical service of the demo application.

{{% alert title="Step 1" color="success" %}}
Select all *travel-* namespaces in the graph and enable *Traffic Distribution* edge labels in the Display Options:
{{% /alert %}}
<a class="image-popup-fit-height" href="/images/tutorial/04-02-graph-request-distribution.png" title="Graph Request Distribution">
    <img src="/images/tutorial/04-02-graph-request-distribution.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Review the status of the mesh, everything seems healthy, but also note that *hotels* service has more load compared to other services inlcuded in the *travel-agency* namespace.

{{% alert title="Step 2" color="success" %}}
Select the *hotels* service, use the graph side-panel to select a trace from the Traces tab:
{{% /alert %}}
<a class="image-popup-fit-height" href="/images/tutorial/04-02-hotels-normal-trace.png" title="Hotels Normal Trace">
    <img src="/images/tutorial/04-02-hotels-normal-trace.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Combining telemetry and tracing information will show that there are traces started from a portal that involve multiple services but also other traces that only consume the *hotels* service.

<a class="image-popup-fit-height" href="/images/tutorial/04-02-hotels-single-trace.png" title="Hotels Single Trace">
    <img src="/images/tutorial/04-02-hotels-single-trace.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 3" color="success" %}}
Select the main *travels* application and double-click to zoom in
{{% /alert %}}
<a class="image-popup-fit-height" href="/images/tutorial/04-02-travels-zoom.png" title="Travels Zoom">
    <img src="/images/tutorial/04-02-travels-zoom.png" style="display:block;margin: 0 auto;" />
</a>

</br>

The graph can focus on an element to study a particular context in detail. Note that a contextual menu is available using
right-click, to easily shortcut the navigation to other sections.

## Application details

Kiali provides [Detail Views]({{< ref "/docs/Features/details" >}}) to navigate into applications, workloads and services.

These views provide information about the structure, health, metrics, logs, traces and Istio configuration for any application component.

In this tutorial we are going to learn how to use them to examine the main *travels* application of our example.

{{% alert title="Step 1" color="success" %}}
Navigate to the *travels* application
{{% /alert %}}
<a class="image-popup-fit-height" href="/images/tutorial/04-03-travels-application.png" title="Travels Application">
    <img src="/images/tutorial/04-03-travels-application.png" style="display:block;margin: 0 auto;" />
</a>

</br>

An *application* is an abstract group of workloads and services labeled with the same "application" name.

From Service Mesh perspective this concept is significant as telemetry and tracing signals are mainly grouped by "application" even if multiple workloads are involved.

At this point of the tutorial, the *travels* application is quite simple, just a *travels-v1* workload exposed through the *travels* service. Navigate to the
*travels-v1* workload detail by clicking the link in the *travels* application overview.

<a class="image-popup-fit-height" href="/images/tutorial/04-03-travels-v1-workload.png" title="Travels-v1 Workload">
    <img src="/images/tutorial/04-03-travels-v1-workload.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 2" color="success" %}}
Examine *Outbound Metrics* of *travels-v1* workload
{{% /alert %}}
<a class="image-popup-fit-height" href="/images/tutorial/04-03-travels-v1-metrics.png" title="Travels-v1 Metrics">
    <img src="/images/tutorial/04-03-travels-v1-metrics.png" style="display:block;margin: 0 auto;" />
</a>

</br>

The Metrics tab provides a powerful visualization of telemetry collected by the Istio proxy sidecar. It presents a dashboard of charts, each of which can be
expanded for closer inspection. Expand the *Request volume* chart:

<a class="image-popup-fit-height" href="/images/tutorial/04-03-travels-v1-metrics-request-volume.png" title="Travels-v1 Request Volume Chart">
    <img src="/images/tutorial/04-03-travels-v1-metrics-request-volume.png" style="display:block;margin: 0 auto;" />
</a>

</br>

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

<a class="image-popup-fit-height" href="/images/tutorial/04-03-travels-v1-logs-getdestinations.png" title="Travels-v1 Logs GetDestinations">
    <img src="/images/tutorial/04-03-travels-v1-logs-getdestinations.png" style="display:block;margin: 0 auto;" />
</a>

</br>

However, *GetTravelQuote* invokes multiple requests to other services using a specific city as a parameter.

<a class="image-popup-fit-height" href="/images/tutorial/04-03-travels-v1-logs-gettravelquote.png" title="Travels-v1 Logs GetTravelQuote">
    <img src="/images/tutorial/04-03-travels-v1-logs-gettravelquote.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Then, as discussed in the [Travel Demo design]({{< relref "./02-install-travel-demo/#travel-agency-namespace" >}}), an initial query returns all available hotels before letting the user choose one and then get specific quotes for other destination services.

That scenario is shown in the increase of the *hotels* service utilization.

{{% alert title="Step 4" color="success" %}}
Review *Traces* of *workload-v1*
{{% /alert %}}

Now we have identified that the *hotels* service has more use than other *travel-agency* services.

The next step is to get more context to answer if some particular service is acting slower than expected.

The Traces tab allows comparison between traces and metrics histograms, letting the user determine if a particular spike is expected in the context of average values.

<a class="image-popup-fit-height" href="/images/tutorial/04-03-travels-v1-tracing-details.png" title="Travels-v1 Traces">
    <img src="/images/tutorial/04-03-travels-v1-tracing-details.png" style="display:block;margin: 0 auto;" />
</a>

</br>

In the same context, individual *spans* can be compared in more detail, helping to identify a problematic step in the broader scenario.

<a class="image-popup-fit-height" href="/images/tutorial/04-03-travels-v1-tracing-spans.png" title="Travels-v1 Spans">
    <img src="/images/tutorial/04-03-travels-v1-tracing-spans.png" style="display:block;margin: 0 auto;" />
</a>

