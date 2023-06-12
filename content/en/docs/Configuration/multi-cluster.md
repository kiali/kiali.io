---
title: "Multi-cluster"
description: "Configuring Kiali for a multi-cluster mesh."
---

Kiali has [experimental support for Istio multi-cluster installations]({{< relref "../Features/multi-cluster" >}}).

![Kiali multi-cluster](/images/documentation/configuration/multi-cluster.png)

Before proceeding with the setup, ensure you meet the requirements.

#### Requirements

1. **Primary-remote istio deployment.** Only the primary-remote istio deployment is currently supported.

2. **Aggregated metrics and traces.** Kiali needs a single endpoint for metrics and a single endpoint for traces where it can consume aggregated metrics/traces across all clusters. There are many ways to aggregate metrics/traces such as prometheus federation or using OTEL collector pipelines but setting these up are outside of the scope of Kiali.

3. **Anonymous or OpenID authentication strategy.** The unified multi-cluster configuration currently only supports anonymous or OpenID [authentication strategies]({{< relref "../Configuration/authentication" >}}). In addition, current support varies by provider for OpenID across clusters.

#### Setup

The unified Kiali multi-cluster setup requires the Kiali Service Account (SA) to have read access to each Kubernetes cluster in the mesh. This is separate from the user credentials that are required when a user logs into Kiali. The user credentials are used to check user access to a namespace and to perform write operations. In anonymous mode, the Kiali SA is used for all operations and write access is also required. To give the Kiali SA access to each remote cluster, a kubeconfig with credentials needs to be created and mounted into the Kiali pod. While the location of Kiali in relation to the controlplane and dataplane may change depending on your istio deployment model, the requirements will remain the same.

1. **Create a remote kubeconfig secret.** You can use [this script](https://github.com/kiali/kiali/blob/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh) to simplify this process for you. Running this script will:

   - Create a Kiali Service Account in the remote cluster.
   - Create a role/role-binding for this service account in the remote cluster.
   - Create a kubeconfig file and save this as a secret in the namespace where Kiali is deployed. The Kiali operator will auto-detect the secret and mount it into the Kiali pod.

   In order to run this script you will need adequate permissions configured in your local kubeconfig, for both the cluster on which Kiali is deployed and the remote cluster. You will need to repeat this step for each remote cluster.

   ```
   curl -L -o kiali-prepare-remote-cluster.sh https://raw.githubusercontent.com/kiali/kiali/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh
   chmod +x kiali-prepare-remote-cluster.sh
   ./kiali-prepare-remote-cluster.sh --kiali-cluster-context east --remote-cluster-context west --view-only false
   ```

Adding remote kubeconfig secrets to Kiali effectively puts Kiali in "multi-cluster" mode and Kiali will begin using those credentials to communicate with the other clusters in the mesh.

2. Optional - **Configure tracing with cluster ID.** By default, traces do not include their cluster name in the trace tags however this can be added using the istio telemetry API.

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

4. Optional - **Narrow metrics to mesh.** If your unified metrics store also contains data outside of your mesh, you can limit which metrics Kiali will query for by setting the [query_scope](/docs/configuration/kialis.kiali.io#.spec.external_services.custom_dashboards.prometheus.query_scope) configuration.

That's it! From here you can login to Kiali and manage your mesh across both clusters from a single Kiali instance.
