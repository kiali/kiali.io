---
title: "Application Wizards"
description: "Using Kiali wizards to generate application and request routing configuration."
---

## Istio Application Wizards {#wizards}

Kiali provides _Actions_ to create, update and delete Istio configuration, driven by wizards.

Actions can be applied to a *Service*

![Service Detail Actions](/images/documentation/features/actions-service.png "Service Detail Actions")

Actions can also be applied to a *Workload*

![Workload Detail Actions](/images/documentation/features/actions-workload.png "Workload Detail Actions")

And, actions are available for an entire *Namespace*

![Namespace Actions](/images/documentation/features/actions-namespace.png "Namespace Actions")


## Service Actions

Kiali offers a robust set of service actions, with accompanying wizards.

### Traffic Management: Request Routing

The Request Routing Wizard allows creating multiple routing rules.

* Every rule is composed of a _Request Matching_ and a _Routes To_ section.
* The Request Matching section can add multiple filters using HEADERS, URI, SCHEME, METHOD or AUTHORITY HTTP parameters.
* The Request Matching section can be empty, in this case any HTTP request received is matched against this rule.
* The Routes To section can specify the percentage of traffic that is routed to a specific workload.

![Request Routing](/images/documentation/features/actions-service-request-routing.png "Request Routing")

Istio applies routing rules in order, meaning that the first rule matching an HTTP request (top-down) performs the routing. The Matching Routing Wizard allows changing the rule order.

### Traffic Management: Fault Injection

The Fault Injection Wizard allows injecting faults to test the resiliency of a Service.

* HTTP Delay specification is used to inject latency into the request forwarding path.
* HTTP Abort specification is used to immediately abort a request and return a pre-specified status code.

![Fault Injection](/images/documentation/features/actions-service-fault-injection.png "Fault Injection")

### Traffic Management: Traffic Shifting

The Traffic Shifting Wizard allows selecting the percentage of traffic that is routed to a specific workload.

![Traffic Shifting](/images/documentation/features/actions-service-traffic-shifting.png "Traffic Shifting")

{{% alert color="success" %}}
Kiali also provides an analogous action for TCP traffic shifting.
{{% /alert %}}

### Traffic Management: Request Timeouts

The Request Timeouts Wizard sets up request timeouts in Envoy, using Istio.

* HTTP Timeout defines the timeout for a request.
* HTTP Retry describes the retry policy to use when an HTTP request fails.

![Request Timeouts](/images/documentation/features/actions-service-request-timeout.png "Request Timeouts")

### Traffic Management: Gateways

Traffic Management Wizards have an Advanced Options section that can be used to extend the scenario.

One available Advanced Option is to expose a Service to external traffic through an existing Gateway or to create a new Gateway for this Service.

![Gateway](/images/documentation/features/actions-service-advanced-gateway.png "Gateway")

### Traffic Management: Circuit Breaker

Traffic Management Wizards allows defining Circuit Breakers on Services as part of the available Advanced Options.

* Connection Pool defines the connection limits for an upstream host.
* Outlier Detection implements the Circuit Breaker based on the consecutive errors reported.

![Circuit Breaker](/images/documentation/features/actions-service-advanced-circuit-breaker.png "Circuit Breaker")

### Security: Traffic Policy

Traffic Management Advanced Options allows defining Security and Load Balancing settings.

* TLS related settings for connections to the upstream service.
* Automatically generate a PeerAuthentication resource for this Service.
* Load balancing policies to apply for a specific destination.

![Traffic Policy](/images/documentation/features/actions-service-advanced-traffic-policy.png "Traffic Policy")

## Workload Actions

### Automatic Sidecar Injection

A *Workload* can be individually managed to control the Sidecar Injection.

A default scenario is to indicate this at *Namespace* level but there can be cases where a *Workload* shouldn't be part of the Mesh or vice versa.

Kiali allows users to alter the Deployment template and propagate this configuration into the Pods.

![Workload-specific Disable Sidecar Injection](/images/documentation/features/actions-workload-disable-injection.png "Workload-specific Disable Sidecar Injection")


## Namespace Actions

The Kiali Overview page offers several *Namespace* actions, in any of its views: Expanded, Compacted or Table.

![Namespace Actions](/images/documentation/features/actions-namespace.png "Namespace Actions")

### Show

Show actions navigate from a *Namespace* to its specific Graph, Applications, Workloads, Services or Istio Config pages.

### Automatic Sidecar Injection

When [Automatic Sidecar Injection](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection) is enabled in the cluster, a *Namespace* can be labeled to enable/disable the injection webhook, controlling whether new deployments will automatically have a sidecar.

### Canary Istio upgrade

When [Istio Canary revision](https://istio.io/latest/docs/setup/upgrade/canary) is installed, a *Namespace* can be labeled to that canary revision, so the sidecar of canary revision will be injected into workloads of the namespace.

### Security: Traffic Policies

Kiali can generate Traffic Policies based on the traffic for a namespace.

For example, at some point a namespace presents a traffic graph like this:

![Traffic Policies: Graph](/images/documentation/features/actions-namespace-trafficpolicies-graph.png "Traffic Policies: Graph")

And a user may want to add Traffic Policies to secure that communication. In other words, to prevent traffic other than that currently reflected in the Graph's Services and Workloads.

Using the *Create Traffic Policies* action on a namespace, Kiali will generate AuthorizationPolicy resources per every *Workload* in the *Namespace*.

![Traffic Policies: Sidecars and Authorization Policies](/images/documentation/features/actions-namespace-trafficpolicies-config.png "Traffic Policies: Sidecars and Authorization Policies")

