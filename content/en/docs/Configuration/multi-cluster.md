---
title: "Multi-cluster"
description: "Configuring Kiali for a multi-cluster mesh."
---

Kiali has [experimental support for Istio multi-cluster installations]({{< relref "../Features/multi-cluster" >}}).

Before proceeding with the setup, ensure your deployment meets the following requirements.

## Deployment models

Kiali has two different multi-cluster deployment models. A unified view and a single cluster view. Choosing the right one for you will depend on your environment and requirements.

### Unified

The unified kiali deployment provides a cross-cluster view into your mesh from a single endpoint.

![Kiali multi-cluster](/images/documentation/configuration/multi-cluster.png)

#### Requirements

1. **Primary-remote deployment.** Only the primary-remote deployment is currently supported.

2. **Aggregated metrics and traces.** Kiali needs a single endpoint where it can consume aggregated metrics/traces across all clusters. There are many ways to aggregate metrics/traces such as prometheus federation or using OTEL collector pipelines but setting these up are outside of the scope of Kiali.

3. **Anonymous or OpenID authentciation strategy.** The unified multi-cluster deployment currently only supports anonymous or OpenID [authentication strategies]({{< relref "../Configuration/authentication" >}}).

#### Setup

The unified Kiali multi-cluster setup requires the Kiali Service Account (SA) to have read access to each Kubernetes cluster in the mesh. This is separate from the user credentials that are required when a user logins to Kiali. The user credentials are used to check user access and to perform write operations. In anonymous mode, the Kiali SA is used for all operations and write access is also required. To give the Kiali SA access to each remote cluster, a kubeconfig with credentials needs to be created and mounted into the Kiali pod. While the location of Kiali in relation to the controlplane and dataplane may change depending on your istio deployment model, the requirements will remain the same.

1. **Create a remote kubeconfig secret.** You can use [this script](https://github.com/kiali/kiali/blob/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh) to simplify this process for you. Running this script will:

   - Create a Kiali Service Account in the remote cluster.
   - Create a role/role-binding for this service account in the remote cluster.
   - Create a kubeconfig file and save this as a secret in the namespace where Kiali is deployed. The Kiali operator will auto-detect the secret and mount it into the Kiali pod.

   In order to run this script you will need adaquete permissions configured in your local kubeconfig for both the cluster Kiali is deployed in and the remote cluster. You will need to repeat this step for each remote cluster.

   ```
   curl -L -o kiali-prepare-remote-cluster.sh https://raw.githubusercontent.com/kiali/kiali/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh
   chmod +x kiali-prepare-remote-cluster.sh
   ./kiali-prepare-remote-cluster.sh --kiali-cluster-context east --remote-cluster-context west --view-only false
   ```

2. Optional - **Configure tracing with cluster ID.** By default, traces do not include their cluster name in the trace attributes however this can be added using the istio telemetry API.

```
kubectl apply -f - <<EOF
apiVersion: telemetry.istio.io/v1alpha1
kind: Telemetry
metadata:
  name: mesh-default
  namespace: istio-system
spec:
  # no selector specified, applies to all workloads
  tracing:
  -  customTags:
      cluster:
        environment:
          name: "ISTIO_META_CLUSTER_ID"
EOF
```

3. Optional - **Configure user access in your OIDC provider.** When using anonymous mode, the Kiali SA credentials will be used to display mesh info to the user. When not using anonymous mode, Kiali will check the user's access to each configured cluster's namespace before showing the user any resources from that namespace. Please refer to your OIDC provider's instructions for configuring user access to a kube cluster for this.

4. Optional - **Narrow metrics to mesh clusters.** If your unified metrics store also contains data for clusters outside of your mesh, you can limit which clusters Kiali will query for by setting the [query_scope](/docs/configuration/kialis.kiali.io#.spec.external_services.custom_dashboards.prometheus.query_scope) configuration.

That's it! From here you can login to Kiali and manage your mesh across both clusters from a single Kiali instance.

### Single cluster

The single cluster kiali deployment provides a shallow cross-cluster view into your mesh with links to Kialis deployed in other clusters. This is the same as the typical deployment except that by adding the istio secrets, Kiali will autodiscover other Kialis across clusters and will generate links to these on the graph and other pages. This deployment is for users who do not meet the requirements of the unified view or would like a separate Kiali per cluster. It provides only a shallow graph view into other clusters and the list pages are scoped to a single cluster.

![Kiali multi-cluster-single](/images/documentation/configuration/multi-cluster-single.png)

#### Requirements

1. **Kiali deployed in each controlplane cluster.** Kiali offers a cluster scoped view of the mesh and requires a Kiali deployed per controlplane cluster. Deploying Kiali in a dataplane (remote) cluster is not supported.

2. **Grant Kiali access to remote istio secrets.** In order for Kiali to discover other Kialis and generate links to them, Kiali needs access to the Istio multi-cluster secrets.

#### Setup

Kiali can either autodiscover istio multi-cluster secret or you can manually mount the secret into the Kiali pod.

**Autodiscovery**

1. Create istio remote secrets in each cluster.
2. Enable the [autodetect_secrets](/docs/configuration/kialis.kiali.io#.spec.kiali_feature_flags.clustering.autodetect_secrets.enabled) setting on the Kiali server.

**Manually add secrets**

1. Create the istio remote secret or a separate secret for kiali to connect to the remote kube API server. This is just a kube config file with connection info to the remote cluster.
2. Update the Kiali server settings pointing to the remote secret. Set the [cluster name](https://kiali.io/docs/configuration/kialis.kiali.io/#.spec.kiali_feature_flags.clustering.clusters[*].name) and the [secret_name](https://kiali.io/docs/configuration/kialis.kiali.io/#.spec.kiali_feature_flags.clustering.clusters[*].secret_name).
