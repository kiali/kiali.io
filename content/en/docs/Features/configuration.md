---
title: "Istio Configuration"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 7
---

Kiali is more than observability, it also helps you to configure, update and validate your Istio service mesh.

The Istio configuration view provides advanced filtering and navigation for Istio configuration objects such as Virtual Services and Gateways.
Kiali provides inline config edition and powerful semantic validation for Istio resources.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/config-list-v1.22.0.png" title="Istio Config List">
   <img src="/images/documentation/features/config-list-v1.22.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

## Validations

Kiali performs a set of validations to the most common Istio Objects such as Destination Rules, Service Entries, and Virtual Services. Those validations are done in addition to the existing ones performed by Istio's Galley component. Most validations are done inside a single namespace only, any exceptions, such as gateways, are properly documented.

Galley validations are mostly syntactic validations based on the object syntax analysis of Istio objects while Kiali validations are mostly semantic validations between different Istio objects. Kiali validations are based on the runtime status of your service mesh, Galley validations are static ones and doesn't take into account what is configured in the mesh.

Check the complete [list of validations](#validations) for further information.


<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/config-validation-v1.22.0.png" title="Istio Config Validation">
   <img src="/images/documentation/features/config-validation-v1.22.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>


## Istio Forms

Istio Wizards provide a way to apply a Service Mesh pattern and let Kiali to generate the Istio Configuration.
Kiali also offers actions to create Istio Config for Gateways and Security scenarios.

These actions are located under the Istio Config page.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/create-istio-config-v1.32.0.png" title="Create Istio Config">
   <img src="/images/documentation/features/create-istio-config-v1.32.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

### Istio Security Forms

Kiali allows creation of Istio AuthorizationPolicy resources:

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/form-authorization-policy-v1.32.0.png" title="AuthorizationPolicy">
   <img src="/images/documentation/features/form-authorization-policy-v1.32.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>
</br>

Istio PeerAuthentication resources:

<div style="display: flex;">
    <span style="margin: 0 auto;">
      <a class="image-popup-fit-height" href="/images/documentation/features/form-peer-authentication-v1.32.0.png" title="PeerAuthentication">
          <img src="/images/documentation/features/form-peer-authentication-v1.32.0.png" style="width: 1333px; display:inline;margin: 0 auto;" />
      </a>
    </span>
</div>
</br>

Istio RequestAuthentication resources:

<div style="display: flex;">
    <span style="margin: 0 auto;">
      <a class="image-popup-fit-height" href="/images/documentation/features/form-request-authentication-v1.32.0.png" title="RequestAuthentication">
          <img src="/images/documentation/features/form-request-authentication-v1.32.0.png" style="width: 1333px; display:inline;margin: 0 auto;" />
      </a>
    </span>
</div>

### Istio Traffic Forms

Kiali uses Istio Wizards to generate Istio Traffic config for a specific Service, but Kiali also allows creation of Gateway, ServiceEntry and Sidecar Istio resources for more generic scenarios.

Istio Gateway resources:

<div style="display: flex;">
    <span style="margin: 0 auto;">
      <a class="image-popup-fit-height" href="/images/documentation/features/form-gateway-v1.32.0.png" title="Gateway">
          <img src="/images/documentation/features/form-gateway-v1.32.0.png" style="width: 1333px; display:inline;margin: 0 auto;" />
      </a>
    </span>
</div>
</br>

Istio ServiceEntry resources:

<div style="display: flex;">
    <span style="margin: 0 auto;">
      <a class="image-popup-fit-height" href="/images/documentation/features/form-serviceentry-v1.32.0.png" title="ServiceEntry">
          <img src="/images/documentation/features/form-serviceentry-v1.32.0.png" style="width: 1333px; display:inline;margin: 0 auto;" />
      </a>
    </span>
</div>
</br>

Istio Sidecar resources:

<div style="display: flex;">
    <span style="margin: 0 auto;">
      <a class="image-popup-fit-height" href="/images/documentation/features/form-sidecar-v1.32.0.png" title="Sidecar">
          <img src="/images/documentation/features/form-sidecar-v1.32.0.png" style="width: 1333px; display:inline;margin: 0 auto;" />
      </a>
    </span>
</div>

