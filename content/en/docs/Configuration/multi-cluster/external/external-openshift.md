---
title: "OpenShift"
description: "Deploying External Kiali on OpenShift"
weight: 10
---

These are specific notes for the External Kiali deployment model on OpenShift.

## Installation

It is highly recommended that the Kiali Operator be deployed on all clusters, even if the Kiali Server itself is not deployed on some clusters. This will ensure that the proper namespace and remote cluster resources can be created. Clusters without a Kiali Server will require only the remote cluster resources necessary for remote Kiali Server authentication. To install these resources, configure the Kiali CR with:

- `spec.deployment.remote_cluster_resources_only: true`

This Kiali CR will result in an installation requiring very limited resources.

## Authorization Strategy

When using the `openshift` authentication strategy on OpenShift, make sure to read and apply any guidance found in the notes for [multi-cluster]({{< relref "../../authentication/openshift#multi-cluster" >}}).
