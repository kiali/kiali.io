---
title: "Istio Configuration"
description: "Using Kiali to generate Istio mesh-wide configuration."
---

Kiali is more than observability, it also helps you to configure, update and validate your Istio service mesh.

The Istio configuration view provides advanced filtering and navigation for Istio configuration objects, such as Virtual Services and Gateways.
Kiali provides inline config editing and powerful semantic validation for Istio resources.

![Istio Config List](/images/documentation/features/istio-config-list.png "Istio Config List")

## Validations

Kiali performs a set of validations on your Istio Objects, such as Destination Rules, Service Entries, and Virtual Services. Kiali's validations go above and beyond what Istio offers.  Where Istio offers mainly static checks for well-formed definitions, Kiali performs semantic validations to ensure that the definitions make sense, across objects, and in some cases even across namespaces.  Kiali validations are based on the runtime status of your service mesh.

As of Kiali v2.25, validations support **multi-primary Istio deployments**, including cross-cluster MeshConfig validation.

Check the complete [list of validations]({{< relref "validations" >}}) for further information.

![Istio Config Validation](/images/documentation/features/istio-config-validation.png "Istio Config Validation")

## Wizards

Kiali Wizards provide a way to apply an Istio service mesh pattern, letting Kiali generate the Istio Configuration.
Wizards are launched from Kiali's Action menus, located across the UI on relevant pages.  Wizards can create and update
Istio Config for Routing, Gateways, Security scenarios and more.

### Istio Config Page Wizards

These Create Actions are available on the Istio Config page:

![Istio Config Create Actions](/images/documentation/features/istio-config-actions.png "Istio Config Create Actions")

#### Authorization Wizards

Kiali allows creation of Istio AuthorizationPolicy resources:
![AuthorizationPolicy](/images/documentation/features/istio-config-wizard-authpolicy.png "AuthorizationPolicy")

The AuthorizationPolicy wizard configures:
- **Selector** — which workloads this policy targets (by label selector)
- **Action** — ALLOW, DENY, AUDIT, or CUSTOM
- **Rules** — combining source principals, namespaces, IP blocks, HTTP methods, paths, and ports
- **Provider** — name of the external authorization provider (CUSTOM action only)

Istio PeerAuthentication resources:
![PeerAuthentication](/images/documentation/features/istio-config-wizard-peerauth.png "PeerAuthentication")

The PeerAuthentication wizard configures:
- **Selector** — which workloads this policy targets
- **Mutual TLS Mode** — UNSET, DISABLE, PERMISSIVE, or STRICT
- **Port-level mTLS** — override the mTLS mode per specific port

Istio RequestAuthentication resources:
![RequestAuthentication](/images/documentation/features/istio-config-wizard-requestauth.png "RequestAuthentication")

The RequestAuthentication wizard configures:
- **Selector** — which workloads this policy targets
- **JWT Rules** — issuer, JWKS URI, and JWT locations in headers or query params

#### Traffic Wizards

Kiali also allows creation of Istio Gateway resources.

![Gateway](/images/documentation/features/istio-config-wizard-gateway.png "Gateway")

Istio ServiceEntry resources:

![ServiceEntry](/images/documentation/features/istio-config-wizard-serviceentry.png "ServiceEntry")

Istio Sidecar resources:

![Sidecar](/images/documentation/features/istio-config-wizard-sidecar.png "Sidecar")

K8s Gateway resources:
![K8sGateway](/images/documentation/features/istio-config-wizard-k8s-gateway.png "K8sGateway")

Kiali supports the [Kubernetes Gateway API](https://gateway-api.sigs.k8s.io/) (v1.5.0+) as an
alternative to Istio's own Gateway resource. Use K8s Gateway resources when your cluster manages
ingress through the standard Gateway API rather than Istio-specific CRDs. The wizard lets you
configure the GatewayClass, listeners, and allowed routes.

K8s Reference Grants resources:
![K8sReferenceGrant](/images/documentation/features/istio-config-wizard-k8s-referencegrants.png "K8sReferenceGrant")

K8s ReferenceGrants allow cross-namespace routing — they grant permission for a Gateway in one
namespace to reference a Service in another. The wizard configures the `from` and `to` selectors
required by the ReferenceGrant spec.

### Other Kiali Wizards

Kiali also has Wizards available from the Namespaces page (Kiali >= 2.23) and many details pages, such as Service Detail to create routing rules. The Kiali [Travel Tutorial]({{< ref "/docs/tutorials/travels" >}}) goes into several of these wizards.

#### Namespaces Page Wizards

The Namespaces page (Kiali >= 2.23) has namespace-specific actions for creating traffic policies:

![Namespace Actions](/images/documentation/features/overview-actions.png "Namespace Actions")

#### Service Wizards

The Service Detail page offers several wizards to create traffic control config:

![Service Actions](/images/documentation/features/service-actions.png "Service Actions")

## AI-Assisted Configuration

As of Kiali v2.22, Istio configuration can also be created and managed through
Kiali's [AI Assistant](/docs/ai/kiali-chatbot/) (developer preview). The AI assistant
can generate, inspect, and update Istio resources using natural language prompts.

