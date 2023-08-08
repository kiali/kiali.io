---
title: "Introduction"
description: "Observe the Travels application deployed in multiple clusters with the new capabilities of Kiali."
weight: 1
---

So far, we know how good Kiali can be to understand applications, their relationships with itself and also with external applications.
 
In the past, Kiali was installed just to observe one cluster with all the applications that conforms to it. Today, we are expanding its capabilities to also observe more than one cluster. The extra clusters are remotes, meaning that there is not a control plane on them, they only have user applications.

This topology is called [primary-remote](https://istio.io/latest/docs/setup/install/multicluster/primary-remote/) and it is very useful to spread applications into different clusters having just one primary cluster, which is where Istio and Kiali are installed. 

This scenario is a good choice when as an application administrator or architect, you want to give a different set of clusters to different sets of developers and you also want that all these applications belong to the same mesh. This scenario is also very helpful to give applications high availability capabilities while keeping the observability together (we are referring to just applications in terms of high availability, for Istio, we might want to install a multi-primary deployment model, which is on the [roadmap](https://github.com/kiali/kiali/issues/5618) for the multicluster journey for Kiali).

At first, we will install one cluster with Istio, then we will add a new cluster, the remote, and we will join it to the mesh and we will see how Kiali allows us to observe and manage both of them and their applications.
