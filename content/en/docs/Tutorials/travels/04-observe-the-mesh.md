---
title: "Observe the Mesh"
description: "Observability with Kiali: graphs, metrics, logs, tracing..."
weight: 4
---

## Enable Sidecars in All Workloads

An Istio sidecar proxy connects a workload to the control plane and enables [service mesh functionality](https://istio.io/latest/about/service-mesh/#what-is-istio).

Sidecars automatically collect metrics, access logs, and distributed traces — a major observability benefit of the mesh.

In [Join the Mesh]({{< relref "./03-join-the-mesh" >}}) we injected a sidecar only into the *control* workload. The rest of the Travel Demo still lacks full mesh visibility.

{{% alert title="Step 1" color="success" %}}
Use the Traffic Graph to identify missing sidecars in the Travel Demo
{{% /alert %}}

1. Open **Traffic Graph**.
2. Select all three Travel Demo namespaces (`travel-control`, `travel-portal`, and `travel-agency`).
3. Note the **Graph Type** menu → if necessary, set to the default: **Versioned App graph**.
4. Note the **Display** menu → if necessary, enable **Missing Sidecars** (under Show Badges).

![Missing Sidecars](/images/tutorial/04-01-missing-sidecars.png "Missing Sidecars")

The *control* workload reports telemetry for its traffic, but visibility is incomplete because *travel-portal* and *travel-agency* workloads still lack sidecar proxies.

{{% alert title="Step 2" color="success" %}}
Enable proxy injection in *travel-portal* and *travel-agency*
{{% /alert %}}

In [Join the Mesh]({{< relref "./03-join-the-mesh" >}}) we enabled injection for a single workload on purpose. For the remaining namespaces, a common pattern is to label namespaces before rollout so Istio injects sidecars automatically.

Label the namespaces and restart the deployments:

```
kubectl label namespace travel-agency istio-injection=enabled
kubectl label namespace travel-portal istio-injection=enabled

kubectl rollout restart deploy -n travel-portal
kubectl rollout restart deploy -n travel-agency
```

{{% alert title="Kind" color="warning" %}}
You can also enable injection from Kiali on each namespace (**Namespaces** → namespace detail → **Actions** → **Enable Auto Injection**), then restart workloads the same way.
{{% /alert %}}

Verify that workloads in all three demo namespaces have sidecars. Pods should show **2/2** ready (application + `istio-proxy`):

```
kubectl get pods -n travel-portal
kubectl get pods -n travel-agency
```

On the **Workloads** page, missing-sidecar badges should be gone for the restarted pods.

![Updated Workloads](/images/tutorial/04-01-updated-workloads.png "Updated Workloads")

{{% alert title="Step 3" color="success" %}}
Verify updated telemetry for *travel-portal* and *travel-agency*
{{% /alert %}}

Return to **Traffic Graph**, keep all three Travel Demo namespaces selected, and refresh if needed. You should now see traffic across the full demo topology.

![Updated Telemetry](/images/tutorial/04-01-updated-telemetry.png "Updated Telemetry")

## Graph Walkthrough

The graph provides a powerful set of [graph features]({{< ref "/docs/Features/topology" >}}) to visualize service mesh traffic.

In this section we use the graph to explore the Travel Demo and identify the busiest services.

{{% alert color="info" %}}
New to the Kiali graph? On the **Traffic Graph** page, click the **Help** icon in the toolbar to start the built-in graph tour. The tour introduces namespaces, display options, the summary panel, and other graph features.
{{% /alert %}}

{{% alert title="Step 1" color="success" %}}
Select all *travel-* namespaces and enable **Traffic Distribution** edge labels
{{% /alert %}}

1. Open **Traffic Graph**.
2. Select `travel-control`, `travel-portal`, and `travel-agency`.
3. Open **Display** → under **Show Edge Labels**, enable **Traffic Distribution**.

![Graph Request Distribution](/images/tutorial/04-02-graph-request-distribution.png "Graph Request Distribution")

The mesh looks healthy, but note that the *hotels* service carries more load than other services in *travel-agency*.

{{% alert title="Step 2" color="success" %}}
Select the *hotels* service and inspect a trace in the summary panel
{{% /alert %}}

1. Click the *hotels* service node.
2. In the summary panel on the right, open the **Traces** tab.
3. Select a trace to inspect.

![Hotels Normal Trace](/images/tutorial/04-02-hotels-normal-trace.png "Hotels Normal Trace")

Combining telemetry and tracing shows traces that start from a portal and involve multiple services, and others that call only the *hotels* service.

![Hotels Single Trace](/images/tutorial/04-02-hotels-single-trace.png "Hotels Single Trace")

{{% alert title="Step 3" color="success" %}}
Drill into the main *travels* application graph
{{% /alert %}}

1. Right-click the *travels* application node. Right-click provides shortcuts to other Kiali pages.
2. Select **Node Graph**.

The graph focuses on the selected element so you can study one part of the topology in detail.

![Travels Zoom](/images/tutorial/04-02-travels-zoom.png "Travels Zoom")

## Application Details

Kiali provides [detail views]({{< ref "/docs/Features/details" >}}) for applications, workloads, and services.

These views show structure, health, metrics, logs, traces, and Istio configuration for each component.

In this section we examine the main *travels* application in *travel-agency*.

{{% alert title="Step 1" color="success" %}}
Navigate to the *travels* application
{{% /alert %}}

1. Open **Applications**.
2. Select the **travel-agency** namespace.
3. Click the **travels** application.

![Travels Application](/images/tutorial/04-03-travels-application.png "Travels Application")

An *application* groups workloads and services that share the same application label. Telemetry and tracing signals are grouped by application even when multiple workloads are involved.

At this point the *travels* application consists of a *travels-v1* workload exposed through the *travels* service. Click the *travels-v1* workload link in the application overview.

![Travels-v1 Workload](/images/tutorial/04-03-travels-v1-workload.png "Travels-v1 Workload")

{{% alert title="Step 2" color="success" %}}
Examine **Outbound Metrics** for *travels-v1*
{{% /alert %}}

Open the **Outbound Metrics** tab on the *travels-v1* workload.

![Travels-v1 Metrics](/images/tutorial/04-03-travels-v1-metrics.png "Travels-v1 Metrics")

The metrics tab shows charts built from Istio proxy telemetry. Expand the **Request volume** chart for a closer look:

Use **Metrics Settings** to change grouping and aggregation. Enable the **spans** checkbox to correlate metrics with tracing spans in the same chart.

![Travels-v1 Request Volume Chart](/images/tutorial/04-03-travels-v1-metrics-request-volume.png "Travels-v1 Request Volume Chart")

In the context of the *travels* application, *hotels* request volume is higher than the other *travel-agency* services. Request duration looks normal, so the asymmetry is likely part of the application business logic rather than a performance problem.

{{% alert title="Step 3" color="success" %}}
Review **Logs** for *travels-v1*
{{% /alert %}}

The **Logs** tab combines application container logs with Istio sidecar proxy logs. Enable **spans** for a correlated view of logs and traces.

Two main business methods appear in the application logs: *GetDestinations* and *GetTravelQuote*.

*GetDestinations* issues a `GET /hotels` request without parameters (visible in the sidecar proxy log):

![Travels-v1 Logs GetDestinations](/images/tutorial/04-03-travels-v1-logs-getdestinations.png "Travels-v1 Logs GetDestinations")

*GetTravelQuote* calls multiple downstream services with a specific city parameter:

![Travels-v1 Logs GetTravelQuote](/images/tutorial/04-03-travels-v1-logs-gettravelquote.png "Travels-v1 Logs GetTravelQuote")

As described in the [Travel Demo design]({{< relref "./02-install-travel-demo/#travel-agency-namespace" >}}), an initial query returns available hotels before the user selects a destination and requests quotes from the other services — which explains the higher *hotels* utilization.

{{% alert title="Step 4" color="success" %}}
Review **Traces** for *travels-v1*
{{% /alert %}}

The *hotels* service handles more traffic than other *travel-agency* services. Next, use traces to see whether any step is slower than expected.

Open the **Traces** tab on *travels-v1*. Compare individual traces with the metrics histogram to judge whether a spike is unusual relative to average latency.

![Travels-v1 Traces](/images/tutorial/04-03-travels-v1-tracing-details.png "Travels-v1 Traces")

Click an interesting trace to see the trace details. Individual spans can be compared in more detail to pinpoint a slow step in a larger request flow.

![Travels-v1 Spans](/images/tutorial/04-03-travels-v1-tracing-spans.png "Travels-v1 Spans")

## Explore Further

This chapter focused on the graph and on the *travels-v1* workload detail. The same observability tools are available throughout Kiali — browse the list pages and open any component to explore its detail view.

- **Namespaces** — open *travel-portal* or *travel-agency* for namespace health and shortcuts to filtered list views.
- **Applications** — compare *travels* in *travel-agency* with portal apps such as *viaggi* or *voyages*.
- **Services** — inspect *hotels*, which carried more load in the graph walkthrough.
- **Workloads** — open *hotels-v1* or a portal workload and review the same tabs used here.
- **Istio Config** — browse VirtualServices, DestinationRules, and other Istio objects with validation and YAML.

Each detail page starts with an **Overview** tab (mini-graph, health, and links to related objects). Applications, services, and workloads also provide **Traffic**, **Metrics**, and **Traces** tabs. Workloads add **Logs** and **Envoy**, as you saw on *travels-v1*.

See [Detail Views]({{< ref "/docs/Features/details" >}}) for a full description of each tab.

When you are ready to change mesh behavior — not only observe it — continue to [Control the Mesh]({{< relref "./05-control-the-mesh" >}}), where Kiali wizards help configure request routing and other traffic management scenarios.
