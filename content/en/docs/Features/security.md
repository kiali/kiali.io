---
title: "Security"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 8
---

Kiali gives support to better understand how mTLS is used in Istio meshes. Find those helpers in the graph, the masthead menu, the overview page and specific validations.

## Masthead indicator

At the right side of the Masthead, Kiali shows a lock when the mesh has strictly enabled `mTLS` for the whole service mesh. It means that all the communications in the mesh uses `mTLS`.

<div style="display: flex;">
 <span style="margin: 0 auto">
  <a class="image-popup-fit-height" href="/images/documentation/features/masthead-mtls-v1.22.0.png" title="mTLS mesh-wide enabled strictly">
   <img src="/images/documentation/features/masthead-mtls-v1.22.0.png" style="width: 660px;display:inline;margin: 0 auto;" />
  </a>
  <a class="image-popup-fit-height" href="/images/documentation/features/masthead-mtls-hollow-v1.22.0.png" title="Custom Vertx Metrics">
   <img src="/images/documentation/features/masthead-mtls-hollow-v1.22.0.png" style="width: 660px; display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

Kiali shows a hollow lock when either the mesh is configured in `PERMISSIVE` mode or there is a misconfiguration in the mesh-wide `mTLS` configuration.

## Overview locks

The overview page shows all the available namespaces with aggregated data. Besides the health and validations, Kiali shows also the `mTLS` status at namespace-wide. Similar to the masthead, it shows a lock when strict `mTLS` is enabled or a hollow lock when permissive.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/overview-mtls-v1.22.0.png" title="Overview page: showing mTLS at namespace-wide">
   <img src="/images/documentation/features/overview-mtls-v1.22.0.png" style="width: 660px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

## Graph

The `mTLS` method is used to establish communication between microservices. In the graph, Kiali has the option to show which edges are using `mTLS` and with what percentatge during the selected period. When an edge shows a lock icon it means at least one request with mTLS enabled is present. In case there are both mTLS and non-mTLS requests, the side-panel will show the percentage of requests using `mTLS`.

Enable the option in the `Display` dropdown, select the `security` badge.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/graph-mtls-v1.22.0.png" title="Graph shows edges which uses mTLS">
   <img src="/images/documentation/features/graph-mtls-v1.22.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

## Validations

Kiali has different validations to help troubleshoot configurations related to `mTLS` such as `DestinationRules` and `PeerAuthentications`.

<div style="display: flex;">
 <span style="margin: 0 auto;">
  <a class="image-popup-fit-height" href="/images/documentation/features/validations-mtls-v1.22.0.png" title="Validation supporting mTLS configuration">
   <img src="/images/documentation/features/validations-mtls-v1.22.0.png" style="width: 1333px;display:inline;margin: 0 auto;" />
  </a>
 </span>
</div>

