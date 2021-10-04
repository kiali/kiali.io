---
title: "Wizards"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 6
---

Kiali is more than observability, it also helps you to configure, update and validate your Istio service mesh.

## Istio Wizards
Kiali provides actions to create, update and delete Istio configuration, driven by wizards.

Actions can be applied to a *Service*

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/service-actions-v1.24.0.png" title="Service Details Actions">
   <img src="/images/documentation/features/service-actions-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>
</br>

Actions can also be applied to a *Workload*

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/workload-actions-v1.24.0.png" title="Workload Details Actions">
   <img src="/images/documentation/features/workload-actions-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>
</br>

Also, actions are available for an entire *Namespace*

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/overview-actions-v1.24.0.png" title="Namespace Actions">
   <img src="/images/documentation/features/overview-actions-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

## Service Actions

### Traffic Management: Request Routing

The Request Routing Wizard allows creating multiple routing rules.

* Every rule is composed of a Request Matching and a Routes To section.
* The Request Matching section can add multiple filters using HEADERS, URI, SCHEME, METHOD or AUTHORITY Http parameters.
* The Request Matching section can be empty, in this case any http request received is matched against this rule.
* The Routes To section can specify the percentage of traffic that is routed to a specific workload.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/wizard-request-routing-v1.24.0.png" title="Request Routing">
   <img src="/images/documentation/features/wizard-request-routing-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>
</br>

Istio applies routing rules in order, meaning that the first rule matching an HTTP request performs the routing. The Matching Routing Wizard allows changing the rule order.

### Traffic Management: Fault Injection

The Fault Injection Wizard allows injecting faults to test the resiliency of a Service.

* HTTP Delay specification is used to inject latency into the request forwarding path.
* HTTP Abort specification is used to prematurely abort a request with a pre-specified error code.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/wizard-fault-injection-v1.24.0.png" title="Fault Injection">
   <img src="/images/documentation/features/wizard-fault-injection-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

### Traffic Management: Traffic Shifting

The Traffic Shifting Wizard allows selecting the percentage of traffic that is routed to a specific workload.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/wizard-traffic-shifting-v1.24.0.png" title="Traffic Shifting">
   <img src="/images/documentation/features/wizard-traffic-shifting-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

### Traffic Management: Request Timeouts

The Request Timeouts Wizard sets up request timeouts in Envoy, using Istio.

* HTTP Timeout defines the timeout for a request.
* HTTP Retry describes the retry policy to use when an HTTP request fails.


<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/wizard-request-timeouts-v1.24.0.png" title="Request Timeouts">
   <img src="/images/documentation/features/wizard-request-timeouts-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

### Traffic Management: Gateways

Traffic Management Wizards have an Advanced Options section that can be used to extend the scenario.

One available Advanced Option is to expose a Service to external traffic through an existing Gateway or to create a new Gateway for this Service.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/wizard-advanced-options-gateways-v1.24.0.png" title="Request Timeouts">
   <img src="/images/documentation/features/wizard-advanced-options-gateways-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

### Traffic Management: Circuit Breaker

Traffic Management Wizards allows defining Circuit Breakers on Services as part of the available Advanced Options.

* Connection Pool defines the connection limits for an upstream host.
* Outlier Detection implements the Circuit Breaker based on the consecutive errors reported.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/wizard-advanced-options-gateways-v1.24.0.png" title="Circuit Breakers">
   <img src="/images/documentation/features/wizard-advanced-options-gateways-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

### Security: Traffic Policy

Traffic Management Advanced Options allows defining Security and Load Balancing settings.

* TLS related settings for connections to the upstream service.
* Automatically generate a PeerAuthentication resource for this Service.
* Load balancing policies to apply for a specific destination.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/wizard-advanced-options-traffic-policy-v1.24.0.png" title="Traffic Policy">
   <img src="/images/documentation/features/wizard-advanced-options-traffic-policy-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

## Workload Actions

### Automatic Sidecar Injection

A *Workload* can be individually annotated to control the Sidecar Injection.

A default scenario is to indicate this at *Namespace* level but there can be cases where a *Workload* shouldn't be part of the Mesh or vice versa.

Kiali allows users to annotate the Deployment template and propagate this configuration into the Pods.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/workload-actions-sidecar-injection-v1.24.0.png" title="Automatic Sidecar Injection">
   <img src="/images/documentation/features/workload-actions-sidecar-injection-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>


## Namespace Actions

The Kiali Overview page offers several *Namespace* actions, in any of its views: Expanded, Compacted or Table.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/overview-table-actions-v1.24.0.png" title="Namespace Actions">
   <img src="/images/documentation/features/overview-table-actions-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

### Show

Show actions navigate from a *Namespace* to its specific Graph, Applications, Workloads, Services or Istio Config pages.

### Automatic Sidecar Injection

When [Automatic Sidecar Injection](https://istio.io/latest/docs/setup/additional-setup/sidecar-injection) is enabled in the cluster, a *Namespace* can be labeled to enable/disable the injection webhook, controlling whether new deployments will automatically have a sidecar.

### Canary Istio upgrade

When [Istio Canary revision](https://istio.io/latest/docs/setup/upgrade/canary) is installed, a *Namespace* can be labeled to that canary revision, so the sidecar of canary revision will be injected into workloads of the namespace.

### Security: Traffic Policies

Kiali can generate Traffic Policies based on the traffic for a namespace.

For example, at some point a namespace presents a traffic graph like this:

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/overview-actions-trafficpolicies-graph-v1.24.0.png" title="Traffic Policies: Graph">
   <img src="/images/documentation/features/overview-actions-trafficpolicies-graph-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>
</br>

And a user may want to add Traffic Policies to secure that communication. In other words, to prevent traffic other than that currently reflected in the Graph's Services and Workloads.

Using the *Create Traffic Policies* action on a namespace, Kiali will generate AuthorizationPolicy resources per every *Workload* in the *Namespace*.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/overview-actions-trafficpolicies-authorizationpolicies-v1.24.0.png" title="Traffic Policies: Graph">
   <img src="/images/documentation/features/overview-actions-trafficpolicies-authorizationpolicies-v1.24.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>


