---
title: "Multi-cluster"
description: "Advanced Mesh Deployment and Multi-cluster support."
---

{{% alert color="warning" %}}
Support for multi-cluster deployments is currently **experimental** and subject to change.
{{% /alert %}}

A basic Istio mesh deployment has a single control plane with a single data plane, deployed on a single Kubernetes cluster. But Istio supports a variety of advanced
[deployment models](https://istio.io/latest/docs/ops/deployment/deployment-models/). It allows a mesh to span multiple primary (control plane) and/or remote (data plane only) clusters, and can use a single or
[multi-network](https://istio.io/latest/docs/ops/deployment/deployment-models/#multiple-networks) approach. The only strict rule is that within a mesh service names are unique. A non-basic mesh deployment generally involves multiple clusters. See [installation instructions](https://istio.io/docs/setup/install/multicluster/) for more detail on installing advanced mesh deployments.

A single Kiali install can currently work with at most one mesh, one metric store and one trace store but it can be configured for "single cluster" or "multi-cluster". All clusters must be part of the same mesh and report to the same metric and trace store, whether directly or via some sort of aggregator. See the [multi-cluster configuration page]({{< relref "../Configuration/multi-cluster" >}}) for more information on requirements.

For multi-cluster configurations, Kiali provides a unified view and management of your mesh across clusters.

## Graph View: Cluster and Namespace Boxing

Istio provides cluster names in the traffic telemetry for multi-cluster installations. The Kiali graph can use this information to better visualize clusters and namespaces. The Display menu offers two multi-cluster related options: Cluster Boxes and Namespace Boxes. When enabled, either separately or together, the graph will generate boxes to help identify the relevant nodes and edges, and to see traffic traveling between them.

Each box type supports selection and provides a side-panel summary of traffic. Below we see a Bookinfo traffic graph for when Bookinfo services are deployed across the East and West clusters. The West cluster box is selected. You see traffic for all services and workloads across both clusters. Single cluster configurations will show some traffic across clusters but not all.

![Multi-cluster traffic graph](/images/documentation/features/multi-cluster-traffic-graph.png "Multi-cluster traffic graph")

## List View: Mesh Discovery

Kiali will show cluster information for all clusters in the mesh. It will identify the home cluster, meaning the cluster on which it is installed and from which it presents its traffic, traces and Istio config. In the following example there are two clusters defined in the mesh, East and West. East is identified as the home cluster in three places: the browser tab (not shown), the masthead, and with a star icon in the clusters list:

![Multi-cluster mesh discovery](/images/documentation/features/multi-cluster-mesh-view.png "Multi-cluster mesh discovery")

## Unified Multi-cluster configuration

Unlike single-cluster configurations, multi-cluster configurations show list/details pages across all clusters.

### List Views: Aggregated mesh view

With a multi-cluster Kiali configuration, you can view all apps, workloads, services, and Istio config in your mesh from a single place.

![Multi-cluster list pages](/images/documentation/features/multi-cluster-list.png "Multi-cluster list pages")

### Detail Views: Dig into details across clusters

The detail pages provide the same functionality across all clusters that you have access to for a single cluster, including viewing logs, metrics, traces, envoy details, and more.

![Multi-cluster detail pages](/images/documentation/features/multi-cluster-details.png "Multi-cluster detail pages")

### Overview: Cross cluster namespace info

The overview page shows namespace information across all configured clusters.

![Multi-cluster overview](/images/documentation/features/multi-cluster-overview.png "Multi-cluster overview")

## Roadmap

See [this issue](https://github.com/kiali/kiali/issues/5618) to see the multi-cluster roadmap for Kiali.
