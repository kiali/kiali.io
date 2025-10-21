---
title: "OpenShift"
description: "Deploying External Kiali on OpenShift"
weight: 10
---

These are specific notes for the External Kiali deployment model on OpenShift.

## Installation

It is highly recommended that the Kiali Operator be deployed on all clusters, even if Kiali itself is not deployed. This will ensure that the proper directory and remote cluster resources are provided. Clusters without Kiali require only the remote cluster resources (for auth), configure the CR with:

- `spec.deployment.remote_cluster_resources_only: true`

Running the Kiali Operator in this more requires very limited resources.

## Authorization Strategy

The openshift authentication strategy is required for production Kiali deployments on OpenShift. Make sure to read and apply any guidance found in the notes for [multi-cluster]({{< relref "../../authentication/openshift#multi-cluster" >}}).
