---
title: "Istio Configuration"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 7
---

Kiali is more than observability, it also helps you to configure, update and validate your Istio service mesh.

The Istio configuration view provides advanced filtering and navigation for Istio configuration objects such as Virtual Services and Gateways.
Kiali provides inline config edition and powerful semantic validation for Istio resources.

![Istio Config List](/images/documentation/features/config-list-v1.22.0.png "Istio Config List")

## Validations

Kiali performs a set of validations to the most common Istio Objects such as Destination Rules, Service Entries, and Virtual Services. Those validations are done in addition to the existing ones performed by Istio's Galley component. Most validations are done inside a single namespace only, any exceptions, such as gateways, are properly documented.

Galley validations are mostly syntactic validations based on the object syntax analysis of Istio objects while Kiali validations are mostly semantic validations between different Istio objects. Kiali validations are based on the runtime status of your service mesh, Galley validations are static ones and doesn't take into account what is configured in the mesh.

Check the complete [list of validations](#validations) for further information.

![Istio Config Validation](/images/documentation/features/config-validation-v1.22.0.png "Istio Config Validation")

## Istio Forms

Istio Wizards provide a way to apply a Service Mesh pattern and let Kiali to generate the Istio Configuration.
Kiali also offers actions to create Istio Config for Gateways and Security scenarios.

These actions are located under the Istio Config page.

![Create Istio Config](/images/documentation/features/create-istio-config-v1.32.0.png "Create Istio Config")

### Istio Security Forms

Kiali allows creation of Istio AuthorizationPolicy resources:

![AuthorizationPolicy](/images/documentation/features/form-authorization-policy-v1.32.0.png "AuthorizationPolicy")

Istio PeerAuthentication resources:

![PeerAuthentication](/images/documentation/features/form-peer-authentication-v1.32.0.png "PeerAuthentication")

Istio RequestAuthentication resources:

![RequestAuthentication](/images/documentation/features/form-request-authentication-v1.32.0.png "RequestAuthentication")

### Istio Traffic Forms

Kiali uses Istio Wizards to generate Istio Traffic config for a specific Service, but Kiali also allows creation of Gateway, ServiceEntry and Sidecar Istio resources for more generic scenarios.

Istio Gateway resources:

![Gateway](/images/documentation/features/form-gateway-v1.32.0.png "Gateway")

Istio ServiceEntry resources:

![ServiceEntry](/images/documentation/features/form-serviceentry-v1.32.0.png "ServiceEntry")

Istio Sidecar resources:

![Sidecar](/images/documentation/features/form-sidecar-v1.32.0.png "Sidecar")

