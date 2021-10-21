---
title: "Multi-cluster Deployment"
description: "Advanced Mesh Deployment and Multi-cluster support."
---

A basic Istio mesh deployment has a single control plane with a single data plane, deployed on a single Kubernetes cluster. But Istio supports a variety of advanced 
[deployment models](https://istio.io/latest/docs/ops/deployment/deployment-models/). It allows a mesh to span multiple primary (control plane) and/or remote (data plane only) clusters, and can use a single or
[multi-network](https://istio.io/latest/docs/ops/deployment/deployment-models/#multiple-networks) approach.  The only strict rule is that within a mesh service names are unique. A non-basic mesh deployment generally involves multiple clusters.  See [installation instructions](https://istio.io/docs/setup/install/multicluster/) for more detail on installing advanced mesh deployments.

Kiali v1.29 introduces experimental support for advanced deployment models. The recommended Kiali deployment model is to deploy an instance of Kiali along with each Istio primary control plane.  Each Kiali instance will work as it has in the past, with the configured Kubernetes, Prometheus and Jaeger instances.  It will concern itself with the istio config managed by the local primary.  But, there are two new additions:

## List View: Mesh Discovery
Kiali will attempt to discover the clusters configured in the mesh.  And it will identify the *home* cluster, meaning the cluster on which it is installed and from which it presents its traffic, traces and Istio config.  In the following example there are two clusters defined in the mesh, _Kukulcan_ and _Tzotz_.  Kukulcan is identified as the home cluster in three places: the browser tab (not shown), the masthead, and with a star icon in the clusters list:

![Mesh list view](/images/documentation/features/multi-cluster-mesh-v1.29.png "Mesh list view")

## Graph View: Cluster and Namespace Boxing

Starting in v1.8 Istio provides cluster names in the traffic telemetry for multi-cluster installations.  The Kiali graph can now use this information to better visualize clusters and namespaces.  The Display menu now offers two new options: Cluster Boxes and Namespace Boxes.  When enabled, either separately or together, the graph will generate boxes to help more easily identify the relevant nodes and edges, and to see traffic traveling between them.

Each new box type supports selection and will provide a side-panel summary of traffic.  Below we see a Bookinfo traffic graph for when Bookinfo services are deployed across the Kukulcan and Tzotz clusters. The Kukulcan cluster box is selected. Because Kukulcan is the Kiali home cluster, you see traffic from the perspective of Kukulcan. Note that you do not see the internal traffic on Tzotz (the requests from Reviews to Ratings service).  To see traffic from the Tzotz cluster point of view, you would open a Kiali session on Tzotz, assuming you have privileges.

![Multi-cluster traffic graph](/images/documentation/features/multi-cluster-graph-v1.29.png "Multi-cluster traffic graph")

