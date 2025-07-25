---
title: "External Kiali"
description: "Deploy Kiali on a Management Cluster."
---

Larger mesh deployments may desire to separate mesh operation from mesh observability. By deploying Kiali on a cluster away from the mesh, it allows for dedicated management and resource consumption.

### Deployment Model

This deployment model requires a minimum of two clusters. The Kiali "home" cluster (where Kiali is deployed) will serve as the "management" cluster. The "mesh" cluster(s) will be where your service mesh is deployed. The mesh deployment will still conform to any of the Istio deployment models that Kiali already supports. The fundamental difference is that Kiali will not be co-located with an Istio control plane, but instead will reside away from the mesh. For multi-cluster mesh deployments, all of the same requirements apply, such as unified metrics and traces, etc.

It is recommended, but not required, that joining Kiali on the "management" cluster, you also place your other observability tooling, like the metrics store. This will further reduce observability resources on the mesh cluster(s), and will likely reduce latency between Kiali and those data stores.

The high-level deployment model looks like this:
![Kiali multi-cluster](/images/documentation/configuration/external-kiali.png)

### Configuration

Configuring Kiali for the external deployment model has the same requirements needed for a co-located Kiali in a [multi-cluster installation]({{< relref "../Multi-cluster" >}}). Kiali still needs the necessary secrets for accessing the remote clusters. 

Additionally, the configuration needs to indicate that Kiali will not be managing its home cluster. This is done in the Kiali CR by setting:

```
clustering:
  ignore_home_cluster: true
```

Kiali typically sets its home cluster name to the same cluster name set by the co-located Istio control plane. In an external deployment there is no co-located Istio control plane, and therefore the cluster name must also be set in the configuration. This should be the same name as reflected in the .kube config.

```
kubernetes_config:
  cluster_name: <KialiHomeClusterName>
```
