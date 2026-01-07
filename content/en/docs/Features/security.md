---
title: "Security"
description: "How Kiali visualizes mTLS."
---

Kiali gives support to better understand how mTLS is used in Istio meshes. Find those helpers in the graph, the masthead menu, the overview page and specific validations.

## Mesh indicator

At the right panel of the Istio Control Plane from the Mesh page, Kiali shows a lock when the mesh has enabled `mTLS` for the whole service mesh. It means that all the communications in the mesh uses `mTLS`.

![mTLS mesh-wide strict](/images/documentation/features/security-mesh.png "mTLS mesh-wide strict")

Kiali shows a hollow lock when either the mesh is configured in `PERMISSIVE` mode or there is a misconfiguration in the mesh-wide `mTLS` configuration.

![mTLS mesh-wide permissive](/images/documentation/features/security-mesh-hollow.png "mTLS mesh-wide strict")

## Overview locks

The overview page shows all the available namespaces with aggregated data. Besides the health and validations, Kiali shows also the `mTLS` status at namespace-wide. Similar to the Mesh page, it shows a lock when strict `mTLS` is enabled or a hollow lock when permissive.

![Overview: Namespace mTLS](/images/documentation/features/security-overview-mtls.png "Overview: Namespace mTLS")

## Graph

The `mTLS` method is used to establish communication between microservices. In the graph, Kiali has the option to show which edges are using `mTLS` and with what percentage during the selected period. When an edge shows a lock icon it means at least one request with mTLS enabled is present. In case there are both mTLS and non-mTLS requests, the side-panel will show the percentage of requests using `mTLS`.

Enable the option in the `Display` dropdown, select the `security` badge.

![Graph: Edge mTLS](/images/documentation/features/security-graph-mtls.png "Graph: Edge mTLS")

## Validations

Kiali has different validations to help troubleshoot configurations related to `mTLS` such as `DestinationRules` and `PeerAuthentications`.

![Validation supporting mTLS configuration](/images/documentation/features/security-config-validation.png "Validation supporting mTLS configuration")

