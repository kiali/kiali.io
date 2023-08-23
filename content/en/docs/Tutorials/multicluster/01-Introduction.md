---
title: "Introduction"
description: "Observe the Travels application deployed in multiple clusters with the new capabilities of Kiali."
weight: 1
---

So far, we know how good Kiali can be to understand applications, their relationships with each other and with external applications.

In the previous tutorial, Kiali was setup to observe just a single cluster. Now, we will expand its capabilities to observe more than one cluster. The extra clusters are remotes, meaning that there is not a control plane on them, they only have user applications.

This topology is called [primary-remote](https://istio.io/latest/docs/setup/install/multicluster/primary-remote/) and it is very useful to spread applications into different clusters having just one primary cluster, which is where Istio and Kiali are installed.

This scenario is a good choice when as an application administrator or architect, you want to give a different set of clusters to different sets of developers and you also want all these applications to belong to the same mesh. This scenario is also very helpful to give applications high availability capabilities while keeping the observability together (we are referring to just applications in terms of high availability, for Istio, we might want to install a multi-primary deployment model, which is on the [roadmap](https://github.com/kiali/kiali/issues/5618) for the multicluster journey for Kiali).

In this tutorial we will be deploying Istio in a primary-remote deployment. At first, we will install the "east" cluster with Istio, then we will add the "west" remote cluster and join it to the mesh. Then we will see how Kiali allows us to observe and manage both clusters and their applications. Metrics will be aggregated into the "east" cluster using Prometheus federation and a single Kiali will be deployed on the "east" cluster.

If you already have a primary-remote deployment, you can skip to [instaliing Kiali]({{< relref "./05-Install-Kiali.md" >}}).
