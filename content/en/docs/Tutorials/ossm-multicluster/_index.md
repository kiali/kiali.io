---
title: "MultiCluster on OpenShift"
description: "End-to-end guides for setting up Istio multi-cluster meshes on OpenShift with ACM and Kiali."
weight: 7
type: tutorial
---

These tutorials walk through setting up Istio multi-cluster meshes on OpenShift using Red Hat Advanced Cluster Management (ACM), the Cluster Observability Operator (COO), and Kiali. ACM provides fleet management and centralized metrics aggregation via Thanos. COO provides Perses metrics dashboards and the distributed tracing console plugin for Tempo, both integrated into the OpenShift console.

The finished environment has three OpenShift clusters: an ACM hub (`ossm-kiali-hub`) for fleet management and central Thanos metrics, and two Istio primary spokes (`ossm-kiali-spoke` and `ossm-kiali-spoke-two`) that share one multi-primary mesh. Kiali runs on the first spoke and reaches the second via a multi-cluster secret; Perses and Tempo add multi-cluster dashboards and tracing; health-status alerts can fire on each cluster or on the hub. Click the diagram to open a full-size SVG in a new tab.

<a href="/images/ossm-multicluster/00-overview-finished.svg" target="_blank" rel="noopener noreferrer">
<img src="/images/ossm-multicluster/00-overview-finished.png" alt="Finished multi-cluster environment" title="Finished MultiCluster on OpenShift environment — click for full-size SVG">
</a>

Badges such as `G2:P5` mean Guide 2, Phase 5. Read Guides 1 → 2 → 3 in order; each guide page includes a progressive diagram of the environment as it exists when that guide finishes. Guide 4 (health status alerts) can also be followed standalone on any OpenShift cluster with Kiali.

Start with the hub/spoke guide; the multi-primary and dashboards/tracing guides build on it in sequence. Finish up with the health status alerts guide.
