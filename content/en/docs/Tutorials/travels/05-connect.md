---
title: "Connect"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 5
---

## Request Routing

The Travel Demo application has several portals deployed on the *travel-portal* namespace consuming the *travels* service deployed on the *travel-agency* namespace.

The *travels* service is backed by a single workload called *travels-v1* that receives requests from all portal workloads.

At a moment of the lifecycle the business needs of the portals may differ and new versions of the *travels* service may be necessary.

This step will show how to route requests dynamically to multiple versions of the *travels* service.

{{% alert title="Step 1" color="success" %}}
Deploy *travels-v2* and *travels-v3* workloads
{{% /alert %}}
To deploy the new versions of the *travels* service execute the following commands:

```
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travels-v2.yaml) -n travel-agency
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travels-v3.yaml) -n travel-agency
```
</br>

<a class="image-popup-fit-height" href="/images/tutorial/05-01-travels-v2-v3.png" title="Travels-v2 and travels-v3">
    <img src="/images/tutorial/05-01-travels-v2-v3.png" style="display:block;margin: 0 auto;" />
</a>

</br>

As there is no specific routing defined, when there are multiple workloads for *travels* service the requests are uniformly distributed.

<a class="image-popup-fit-height" href="/images/tutorial/05-01-travels-before-routing.png" title="Travels graph before routing">
    <img src="/images/tutorial/05-01-travels-before-routing.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 2" color="success" %}}
Investigate the http headers used by the Travel Demo application
{{% /alert %}}
The [Traffic Management](https://istio.io/latest/docs/concepts/traffic-management/#routing-rules) features of Istio allow you to define [Matching Conditions](https://istio.io/latest/docs/concepts/traffic-management/#match-condition) for dynamic request routing.

In our scenario we would like to perform the following routing logic:

- All traffic from *travels.uk* routed to *travels-v1*
- All traffic from *viaggi.it* routed to *travels-v2*
- All traffic from *voyages.fr* routed to *travels-v3*

Portal workloads use HTTP/1.1 protocols to call the *travels* service, so one strategy could be to use the HTTP headers to define the matching condition.

But, where to find the HTTP headers ? That information typically belongs to the application domain and we should examine the code, documentation or dynamically trace a request to understand which headers are being used in this context.

There are multiple possibilities. The Travel Demo application uses an [Istio Annotation](https://istio.io/latest/docs/reference/config/annotations/) feature to add an annotation into the Deployment descriptor, which adds additional Istio configuration into the proxy.

<a class="image-popup-fit-height" href="/images/tutorial/05-01-deployment-istio-config.png" title="Istio Config annotations">
    <img src="/images/tutorial/05-01-deployment-istio-config.png" style="display:block;margin: 0 auto;" />
</a>

</br>

In our example the [HTTP Headers](https://github.com/kiali/demos/blob/master/travels/travels-v2.yaml#L15) are added as part of the trace context.

Then tracing will populate custom tags with the *portal*, *device*, *user* and *travel* used.

{{% alert title="Step 3" color="success" %}}
Use the Request Routing Wizard on *travels* service to generate a traffic rule
{{% /alert %}}
<a class="image-popup-fit-height" href="/images/tutorial/05-01-travels-request-routing.png" title="Travels Service Request Routing">
    <img src="/images/tutorial/05-01-travels-request-routing.png" style="display:block;margin: 0 auto;" />
</a>

</br>

We will define three "Request Matching" rules as part of this request routing. Define all three rules before clicking the Create button.

In the first rule, we will add a request match for when the *portal* header has the value of *travels.uk*.

Define the exact match, like below, and click the "Add Match" button to update the "Matching selected" for this rule.

<a class="image-popup-fit-height" href="/images/tutorial/05-01-add-match.png" title="Add Request Matching">
    <img src="/images/tutorial/05-01-add-match.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Move to "Route To" tab and update the destination for this "Request Matching" rule.  Then use the "Add Route Rule" to create the first rule.

<a class="image-popup-fit-height" href="/images/tutorial/05-01-route-to.png" title="Route To">
    <img src="/images/tutorial/05-01-route-to.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Add similar rules to route traffic from *viaggi.it* to *travels-v2* workload and from *voyages.fr* to *travels-v3* workload.

When the three rules are defined you can use "Create" button to generate all Istio configurations needed for this scenario. Note
that the rule ordering does not matter in this scenario.

<a class="image-popup-fit-height" href="/images/tutorial/05-01-rules-defined.png" title="Rules Defined">
    <img src="/images/tutorial/05-01-rules-defined.png" style="display:block;margin: 0 auto;" />
</a>

</br>

The Istio config for a given service is found on the "Istio Config" card, on the Service Details page.

<a class="image-popup-fit-height" href="/images/tutorial/05-01-service-istio-config.png" title="Service Istio Config">
    <img src="/images/tutorial/05-01-service-istio-config.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 4" color="success" %}}
Verify that the Request Routing is working from the *travels-portal* Graph
{{% /alert %}}

Once the Request Routing is working we can verify that outbound traffic from every portal goes to the single *travels* workload.  To
see this clearly use a "Workload Graph" for the "travel-portal" namespace, enable "Traffic Distribution" edge labels and disable the
"Service Nodes" Display option:

<a class="image-popup-fit-height" href="/images/tutorial/05-01-request-routing-graph.png" title="Travels Portal Namespace Graph">
    <img src="/images/tutorial/05-01-request-routing-graph.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Note that no distribution label on an edge implies 100% of traffic.

Examining the "Inbound Traffic" for any of the *travels* workloads will show a similar pattern in the telemetry.

<a class="image-popup-fit-height" href="/images/tutorial/05-01-travels-v1-inbound-traffic.png" title="Travels v1 Inbound Traffic">
    <img src="/images/tutorial/05-01-travels-v1-inbound-traffic.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Using a custom time range to select a large interval, we can see how the workload initially received traffic from all portals but then only a single portal after the Request Routing scenarios were defined.

{{% alert title="Step 5" color="success" %}}
Update or delete Istio Configuration
{{% /alert %}}

Kiali Wizards allow you to define high level Service Mesh scenarios and will generate the Istio Configuration needed for its implementation (VirtualServices, DestinationRules, Gateways and PeerRequests).
These scenarios can be updated or deleted from the "Actions" menu of a given service.

To experiment further you can navigate to the *travels* service and update your configuration by selecting "Request Routing", as shown below.  When you have
finished experimenting with Routing Request scenarios then use the "Actions" menu to delete the generated Istio config.

<a class="image-popup-fit-height" href="/images/tutorial/05-01-update-or-delete.png" title="Update or Delete">
    <img src="/images/tutorial/05-01-update-or-delete.png" style="display:block;margin: 0 auto;" />
</a>

## Fault Injection

The [Observe]({{< relref "./04-observe/#graph-walkthrough" >}}) step has spotted that the *hotels* service has additional traffic compared with other services deployed in the *travel-agency* namespace.

Also, this service becomes critical in the main business logic. It is responsible for querying all available destinations, presenting them to the user, and getting a quote for the selected destination.

This also means that the *hotels* service may be one of the weakest points of the Travel Demo application.

This step will show how to test the resilience of the Travel Demo application by injecting faults into the *hotels* service and then observing how the application reacts to this scenario.

{{% alert title="Step 1" color="success" %}}
Use the Fault Injection Wizard on *hotels* service to inject a delay
{{% /alert %}}
<a class="image-popup-fit-height" href="/images/tutorial/05-02-fault-injection-action.png" title="Fault Injection Action">
    <img src="/images/tutorial/05-02-fault-injection-action.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Select an HTTP Delay and specify the "Delay percentage" and "Fixed Delay" values. The default values will introduce a 5 seconds delay into 100% of received uuests.

<a class="image-popup-fit-height" href="/images/tutorial/05-02-http-delay.png" title="HTTP Delay">
    <img src="/images/tutorial/05-02-http-delay.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 2" color="success" %}}
Understanding *source* and *destination* metrics
{{% /alert %}}

Telemetry is collected from proxies and it is labeled with information about the *source* and *destination* workloads.

In our example, let's say that *travels* service ("Service A" in the Istio diagram below) invokes the *hotels* service ("Service B" in the diagram). *Travels* is the "source" workload and *hotels* is the "destination" workload. The *travels* proxy will report telemetry from the source perspective and *hotels* proxy will report telemetry from the destination perspective. Let's look at the latency reporting from both perspectives.

<a class="image-popup-fit-height" href="/images/tutorial/05-02-istio-architecture.png" title="Istio Architecture">
    <img src="/images/tutorial/05-02-istio-architecture.png" style="display:block;margin: 0 auto;" />
</a>

</br>

The *travels* workload proxy has the Fault Injection configuration so it will perform the call to the *hotels* service and will apply the delay on the *travels* workload side (this is reported as *source* telemetry).

We can see in the *hotels* telemetry reported by the *source* (the *travels* proxy) that there is a visible gap showing 5 second delay in the request duration.

<a class="image-popup-fit-height" href="/images/tutorial/05-02-source-metrics.png" title="Source Metrics">
    <img src="/images/tutorial/05-02-source-metrics.png" style="display:block;margin: 0 auto;" />
</a>

</br>

But as the Fault Injection delay is applied on the source proxy (*travels*), the destination proxy (*hotels*) is unaffected and its destination telemetry show no delay.

<a class="image-popup-fit-height" href="/images/tutorial/05-02-destination-metrics.png" title="Destination Metrics">
    <img src="/images/tutorial/05-02-destination-metrics.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 3" color="success" %}}
Study the impact of the *travels* service delay
{{% /alert %}}

The injected delay is propagated from the *travels* service to the downstream services deployed on *travel-portal* namespace, degrading the overall response time. But the downstream services are unaware, operate normally, and show a green status.

<a class="image-popup-fit-height" href="/images/tutorial/05-02-degraded-response-time.png" title="Degraded Response Time">
    <img src="/images/tutorial/05-02-degraded-response-time.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 4" color="success" %}}
Update or delete Istio Configuration
{{% /alert %}}

As part of this step you can update the Fault Injection scenario to test different delays. When finished, you can delete the generated Istio config for the *hotels* service.

## Traffic Shifting

In the previous [Request Routing]({{< relref "#request-routing" >}}) step we have deployed two new versions of the *travels* service using the *travels-v2* and *travels-v3* workloads.

That scenario showed how Istio can route specific requests to specific workloads. It was configured such that each portal deployed in the *travel-portal* namespace (*travels.uk*, *viaggi.it* and *voyages.fr*) were routed to a specific *travels* workload (*travels-v1*, *travels-v2* and *travels-v3*).

This Traffic Shifting step will simulate a new scenario: the new *travels-v2* and *travels-v3* workloads will represent new improvements for the *travels* service that will be used by all requests.

These new improvements implemented in *travels-v2* and *travels-v3* represent two alternative ways to address a specific problem. Our goal is to test them before deciding which one to use as a next version.

At the beginning we will send 80% of the traffic into the original *travels-v1* workload, and will split 10% of the traffic each on *travels-v2* and *travels-v3*.

{{% alert title="Step 1" color="success" %}}
Use the Traffic Shifting Wizard on *travels* service
{{% /alert %}}

<a class="image-popup-fit-height" href="/images/tutorial/05-03-traffic-shifting-action.png" title="Traffic Shifting Action">
    <img src="/images/tutorial/05-03-traffic-shifting-action.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Create a scenario with 80% of the traffic distributed to *travels-v1* workload and 10% of the traffic distributed each to *travels-v2* and *travels-v3*.

<a class="image-popup-fit-height" href="/images/tutorial/05-03-split-traffic.png" title="Split Traffic">
    <img src="/images/tutorial/05-03-split-traffic.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 2" color="success" %}}
Examine Traffic Shifting distribution from the *travels-agency* Graph
{{% /alert %}}

<a class="image-popup-fit-height" href="/images/tutorial/05-03-travels-graph.png" title="Travels Graph">
    <img src="/images/tutorial/05-03-travels-graph.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 3" color="success" %}}
Compare *travels* workload and assess new changes proposed in *travels-v2* and *travels-v3*
{{% /alert %}}

Istio Telemetry is grouped per logical application. That has the advantage of easily comparing different but related workloads, for one or more services.

In our example, we can use the "Inbound Metrics" and "Outbound Metrics" tabs in the *travels* application details, group by "Local version" and compare how *travels-v2* and *travels-v3* are working.

<a class="image-popup-fit-height" href="/images/tutorial/05-03-compare-local-travels-version.png" title="Compare Travels Workloads">
    <img src="/images/tutorial/05-03-compare-local-travels-version.png" style="display:block;margin: 0 auto;" />
</a>

</br>

<a class="image-popup-fit-height" href="/images/tutorial/05-03-compare-local-travels-version-2.png" title="Compare Travels Workloads">
    <img src="/images/tutorial/05-03-compare-local-travels-version-2.png" style="display:block;margin: 0 auto;" />
</a>

</br>

The charts show that the Traffic distribution is working accordingly and 80% is being distributed to *travels-v1* workload and they also show no big differences between *travels-v2* and *travels-v3* in terms of request duration.

{{% alert title="Step 4" color="success" %}}
Update or delete Istio Configuration
{{% /alert %}}

As part of this step you can update the Traffic Shifting scenario to test different distributions. When finished, you can delete the generated Istio config for the *travels* service.

## TCP Traffic Shifting

The Travel Demo application has a database service used by several services deployed in the *travel-agency* namespace.

At some point in the lifecycle of the application the telemetry shows that the database service degrades and starts to increase the average response time.

This is a common situation. In this case, a database specialist suggests an update of the original indexes due to the data growth.

Our database specialist is suggesting two approaches and proposes to prepare two versions of the database service to test which may work better.

This step will show how the "Traffic Shifting" strategy can be applied to TCP services to test which new database indexing strategy works better.

{{% alert title="Step 1" color="success" %}}
Deploy *mysqldb-v2* and *mysqldb-v3* workloads
{{% /alert %}}

To deploy the new versions of the *mysqldb* service execute the commands:

```
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/mysql-v2.yaml) -n travel-agency
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/mysql-v3.yaml) -n travel-agency
```

{{% alert title="Step 2" color="success" %}}
Use the TCP Traffic Shifting Wizard on *mysqldb* service
{{% /alert %}}

<a class="image-popup-fit-height" href="/images/tutorial/05-04-tcp-traffic-shifting-action.png" title="TCP Traffic Shifting Action">
    <img src="/images/tutorial/05-04-tcp-traffic-shifting-action.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Create a scenario with 80% of the traffic distributed to *mysqldb-v1* workload and 10% of the traffic distributed each to *mysqldb-v2* and *mysqldb-v3*.

<a class="image-popup-fit-height" href="/images/tutorial/05-04-tcp-split-traffic.png" title="TCP Split Traffic">
    <img src="/images/tutorial/05-04-tcp-split-traffic.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 3" color="success" %}}
Examine Traffic Shifting distribution from the *travels-agency* Graph
{{% /alert %}}

<a class="image-popup-fit-height" href="/images/tutorial/05-04-tcp-graph.png" title="MysqlDB Graph">
    <img src="/images/tutorial/05-04-tcp-graph.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Note that TCP telemetry has different types of metrics, as "Traffic Distribution" is only available for HTTP/gRPC services, for this service we need to use "Traffic Rate" to evaluate the distribution of data (bytes-per-second) between *mysqldb* workloads.

{{% alert title="Step 4" color="success" %}}
Compare *mysqldb* workload and study new indexes proposed in *mysqldb-v2* and *mysqldb-v3*
{{% /alert %}}

TCP services have different telemetry but it's still grouped by versions, allowing the user to compare and study pattern differences for *mysqldb-v2* and *mysqldb-v3*.


<a class="image-popup-fit-height" href="/images/tutorial/05-04-tcp-compare-versions.png" title="Compare MysqlDB Workloads">
    <img src="/images/tutorial/05-04-tcp-compare-versions.png" style="display:block;margin: 0 auto;" />
</a>

</br>

The charts show more peaks in *mysqldb-v2* compared to *mysqldb-v3* but overall a similar behavior, so it's probably safe to choose either strategy to shift all traffic.

{{% alert title="Step 5" color="success" %}}
Update or delete Istio Configuration
{{% /alert %}}

As part of this step you can update the TCP Traffic Shifting scenario to test a different distribution. When finished, you can delete the generated Istio config for the *mysqldb* service.

## Request Timeouts

In the [Fault Injection]({{< relref "#fault-injection" >}}) step we showed how we could introduce a delay in the critical *hotels* service and test the resilience of the application.

The delay was propagated across services and Kiali showed how services accepted the delay without creating errors on the system.

But in real scenarios delays may have important consequences. Services may prefer to fail sooner, and recover, rather than propagating a delay across services.

This step will show how to add a request timeout for one of the portals deployed in *travel-portal* namespace. The *travel.uk* and *viaggi.it* portals will accept delays but *voyages.fr* will timeout and fail.

{{% alert title="Step 1" color="success" %}}
Use the Fault Injection Wizard on *hotels* service to inject a delay
{{% /alert %}}

Repeat the [Fault Injection]({{< relref "#fault-injection" >}}) step to add delay on *hotels* service.

{{% alert title="Step 2" color="success" %}}
Use the Request Routing Wizard on *travels* service to add a route rule with delay for *voyages.fr*
{{% /alert %}}

Add a rule to add a request timeout only on requests coming from *voyages.fr* portal:

- Use the Request Matching tab to add a matching condition for the *portal* header with *voyages.fr* value.
- Use the Request Timeouts tab to add an HTTP Timeout for this rule.
- Add the rule to the scenario.

<a class="image-popup-fit-height" href="/images/tutorial/05-05-request-timeout-rule.png" title="Request Timeout Rule">
    <img src="/images/tutorial/05-05-request-timeout-rule.png" style="display:block;margin: 0 auto;" />
</a>

</br>

A first rule should be added to the list like:

<a class="image-popup-fit-height" href="/images/tutorial/05-05-voyages-rule.png" title="Voyages Portal Rule">
    <img src="/images/tutorial/05-05-voyages-rule.png" style="display:block;margin: 0 auto;" />
</a>

</br>

Add a second rule to match any request and create the scenario. With this configuration, requests coming from *voyages.fr* will match the first rule and all others will match the second rule.

<a class="image-popup-fit-height" href="/images/tutorial/05-05-generic-rule.png" title="Any Request Rule">
    <img src="/images/tutorial/05-05-generic-rule.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 3" color="success" %}}
Review the impact of the request timeout in the *travels* service
{{% /alert %}}

Create the rule. The Graph will show how requests coming from *voyages.fr* start to fail, due to the request timeout introduced.

Requests coming from other portals work without failures but are degraded by the *hotels* delay.

<a class="image-popup-fit-height" href="/images/tutorial/05-05-travels-graph-voyages-error.png" title="Travels Graph">
    <img src="/images/tutorial/05-05-travels-graph-voyages-error.png" style="display:block;margin: 0 auto;" />
</a>

</br>

This scenario can be visualized in detail if we examine the "Inbound Metrics" and we group by "Remote app" and "Response code".

<a class="image-popup-fit-height" href="/images/tutorial/05-05-voyages-rule-metrics.png" title="Travels Inbound Metrics">
    <img src="/images/tutorial/05-05-voyages-rule-metrics.png" style="display:block;margin: 0 auto;" />
</a>

</br>

<a class="image-popup-fit-height" href="/images/tutorial/05-05-voyages-rule-metrics-2.png" title="Travels Inbound Metrics">
    <img src="/images/tutorial/05-05-voyages-rule-metrics-2.png" style="display:block;margin: 0 auto;" />
</a>

</br>

As expected, the requests coming from *voyages.fr* don't propagate the delay and they fail in the 2 seconds range, meanwhile requests from other portals don't fail but they propagate the delay introduced in the *hotels* service.

{{% alert title="Step 4" color="success" %}}
Update or delete Istio Configuration
{{% /alert %}}

As part of this step you can update the scenarios defined around *hotels* and *travels* services to experiment with more conditions, or you can delete the generated Istio config in both services.

## Circuit Breaking

Distributed systems will benefit from failing quickly and applying back pressure, as opposed to propagating delays and errors through the system.

Circuit breaking is an important technique used to limit the impact of failures, latency spikes, and other types of network problems.

This step will show how to apply a Circuit Breaker into the *travels* service in order to limit the number of concurrent requests and connections.

{{% alert title="Step 1" color="success" %}}
Deploy a new *loadtester* portal in the *travel-portal* namespace
{{% /alert %}}

In this example we are going to deploy a new workload that will simulate an important increase in the load of the system.

{{% alert title="OpenShift" color="warning" %}}
OpenShift users may need to also add the associated loadtester serviceaccount to the necessary securitycontextcontraints.
{{% /alert %}}

```
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_loadtester.yaml) -n travel-portal
```

The *loadtester* workload will try to create 50 concurrent connections to the *travels* service, adding considerable pressure to the *travels-agency* namespace.

<a class="image-popup-fit-height" href="/images/tutorial/05-06-loadtester-graph.png" title="Loadtester Graph">
    <img src="/images/tutorial/05-06-loadtester-graph.png" style="display:block;margin: 0 auto;" />
</a>

</br>

The Travel Demo application is capable of handling this load and in a first look it doesn't show unhealthy status.

<a class="image-popup-fit-height" href="/images/tutorial/05-06-loadtester-details.png" title="Loadtester Details">
    <img src="/images/tutorial/05-06-loadtester-details.png" style="display:block;margin: 0 auto;" />
</a>

</br>

But in a real scenario an unexpected increase in the load of a service like this may have a significant impact in the overall system status.

{{% alert title="Step 2" color="success" %}}
Use the Traffic Shifting Wizard on *travels* service to generate a traffic rule
{{% /alert %}}

Use the "Traffic Shifting" Wizard to distribute traffic (evenly) to the *travels* workloads and use the "Advanced Options" to add a "Circuit Breaker" to the scenario.

<a class="image-popup-fit-height" href="/images/tutorial/05-06-traffic-shifting-circuit-breaker.png" title="Traffic Shifting with Circuit Breaker">
    <img src="/images/tutorial/05-06-traffic-shifting-circuit-breaker.png" style="display:block;margin: 0 auto;" />
</a>

</br>

The "Connection Pool" settings will indicate that the proxy sidecar will reject requests when the number of concurrent connections and requests exceeds more than one.

</br>

The "Outlier Detection" will eject a host from the connection pool if there is more than one consecutive error.

{{% alert title="Step 3" color="success" %}}
Study the behavior of the Circuit Breaker in the *travels* service
{{% /alert %}}

In the *loadtester* versioned-app Graph we can see that the *travels* service's Circuit Breaker accepts some, but fails most, connections.

Remember, that these connections are stopped by the proxy on the *loadtester* side. That "fail sooner" pattern prevents overloading the network.

Using the Graph we can select the failed edge, check the Flags tab, and see that those requests are closed by the Circuit breaker.

<a class="image-popup-fit-height" href="/images/tutorial/05-06-loadtester-flags-graph.png" title="Loadtester Flags Graph">
    <img src="/images/tutorial/05-06-loadtester-flags-graph.png" style="display:block;margin: 0 auto;" />
</a>

</br>

If we examine the "Request volume" metric from the "Outbound Metrics" tab we can see the evolution of the requests, and how the introduction of the Circuit Breaker made the proxy reduce the request volume.

<a class="image-popup-fit-height" href="/images/tutorial/05-06-loadtester-flags-details.png" title="Loadtester Outbound Metrics">
    <img src="/images/tutorial/05-06-loadtester-flags-details.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 4" color="success" %}}
Update or delete Istio Configuration
{{% /alert %}}

As part of this step you can update the scenarios defined around the *travels* service to experiment with more Circuit Breaker settings, or you can delete the generated Istio config in the service.

</br>

Understanding what happened:

[(i) Circuit Breaking](https://istio.io/latest/docs/tasks/traffic-management/circuit-breaking/)

[(ii) Outlier Detection](https://istio.io/latest/docs/reference/config/networking/destination-rule/#OutlierDetection)

[(iii) Connection Pool Settings](https://istio.io/latest/docs/reference/config/networking/destination-rule/#ConnectionPoolSettings)

[(iv) Envoy's Circuit breaking Architecture](https://www.envoyproxy.io/docs/envoy/latest/intro/arch_overview/upstream/circuit_breaking)

## Mirroring

This tutorial has shown several scenarios where Istio can route traffic to different versions in order to compare versions and evaluate which one works best.

The [Traffic Shifting]({{< relref "#traffic-shifting" >}}) step was focused on *travels* service adding a new *travels-v2* and *travels-v3* workloads
and the [TCP Traffic Shifting]({{< relref "#tcp-traffic-shifting" >}}) showed how this scenario can be used on TCP services like *mysqldb* service.

Mirroring (or shadowing) is a particular case of the Traffic Shifting scenario where the proxy sends a copy of live traffic to a mirrored service.

The mirrored traffic happens out of band of the primary request path. It allows for testing of alternate services, in production environments, with minimal risk.

Istio mirrored traffic is only supported for HTTP/gRPC protocols.

This step will show how to apply mirrored traffic into the *travels* service.

{{% alert title="Step 1" color="success" %}}
Use the Traffic Shifting Wizard on *travels* service
{{% /alert %}}

We will simulate the following:

- *travels-v1* is the original traffic and it will keep 80% of the traffic
- *travels-v2* is the new version to deploy, it's being evaluated and it will get 20% of the traffic to compare against *travels-v1*
- But *travels-v3* will be considered as a new, experimental version for testing outside of the regular request path. It will be defined as a mirrored workload on 50% of the original requests.

<a class="image-popup-fit-height" href="/images/tutorial/05-07-mirrored-traffic.png" title="Mirrored Traffic">
    <img src="/images/tutorial/05-07-mirrored-traffic.png" style="display:block;margin: 0 auto;" />
</a>

{{% alert title="Step 2" color="success" %}}
Examine Traffic Shifting distribution from the *travels-agency* Graph
{{% /alert %}}

Note that Istio does not report mirrored traffic telemetry from the source proxy. It is reported from the destination proxy, 
although it is not flagged as mirrored, and therefore an edge from *travels* to the *travels-v3* workload will appear in the graph.
Note the traffic rates reflect the expected ratio of 80/20 between *travels-v1* and *travels-v2*, with *travels-v3* at about
half of that total.

<a class="image-popup-fit-height" href="/images/tutorial/05-07-mirrored-graph.png" title="Mirrored Graph">
    <img src="/images/tutorial/05-07-mirrored-graph.png" style="display:block;margin: 0 auto;" />
</a>

</br>

This can be examined better using the "Source" and "Destination" metrics from the "Inbound Metrics" tab.

The "Source" proxy, in this case the proxies injected into the workloads of *travel-portal* namespace, won't report telemetry for *travels-v3* mirrored workload.

<a class="image-popup-fit-height" href="/images/tutorial/05-07-mirrored-source-metrics.png" title="Mirrored Source Metrics">
    <img src="/images/tutorial/05-07-mirrored-source-metrics.png" style="display:block;margin: 0 auto;" />
</a>

</br>

But the "Destination" proxy, in this case the proxy injected in the *travels-v3* workload, will collect the telemetry from the mirrored traffic.

<a class="image-popup-fit-height" href="/images/tutorial/05-07-mirrored-destination-metrics.png" title="Mirrored Destination Metrics">
    <img src="/images/tutorial/05-07-mirrored-destination-metrics.png" style="display:block;margin: 0 auto;" />
</a>

</br>

{{% alert title="Step 3" color="success" %}}
Update or delete Istio Configuration
{{% /alert %}}

As part of this step you can update the Mirroring scenario to test different mirrored distributions.

When finished you can delete the generated Istio config for the *travels* service.

