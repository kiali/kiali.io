---
title: "Multi-cluster"
description: "Configuring Kiali for a multi-cluster mesh."
---

Kiali has [support for Istio multi-cluster installations]({{< relref "../../Features/multi-cluster" >}}).

![Kiali multi-cluster](/images/documentation/configuration/multi-cluster.png)

Before proceeding with the setup, ensure you meet the requirements.

### Requirements

1. **Aggregated metrics and traces.** Kiali needs a single endpoint for metrics and a single endpoint for traces where it can consume aggregated metrics/traces across all clusters. There are many ways to aggregate metrics/traces such as Prometheus federation or using OTEL collector pipelines but setting these up are outside of the scope of Kiali.

2. **Anonymous, OpenID or OpenShift authentication strategy.** The unified multi-cluster configuration currently only supports anonymous, OpenID and OpenShift [authentication strategies]({{< relref "../../Configuration/authentication" >}}). In addition, current support varies by provider for OpenID across clusters.

### Setup

The unified Kiali multi-cluster setup requires the Kiali Service Account (SA) to have read access to each Kubernetes cluster in the mesh. This is separate from the user credentials that are required when a user logs into Kiali. The user credentials are used to check user access to a namespace and to perform write operations. In anonymous mode, the Kiali SA is used for all operations. Write access need not be required if you only want to give Kiali "view-only" capabilities. To give the Kiali SA access to each remote cluster, a kubeconfig with credentials needs to be created and mounted into the Kiali pod. While the location of Kiali in relation to the controlplane and dataplane may change depending on your Istio deployment model, the requirements will remain the same.

{{% alert color="info" %}}
If you would like to keep a separate Kiali per cluster and do not want to give Kiali access to remote clusters, you can still manually specify the remote cluster and remote Kiali URLs in the Kiali configuration and the UI will try to provide links to the external Kiali where appropriate. See [below](#adding-an-inaccessible-cluster) for more details.
{{% /alert %}}

1. **Create a SA and its associated resources on the remote cluster.** In order for Kiali to access a remote cluster, you first must create a SA and its role/role binding with the proper permissions. The Kiali Operator can create these resources for you; simply deploy the Kiali Operator on the remote cluster and then create a Kiali CR on that remote cluster making sure to set the Kiali CR setting `spec.deployment.remote_cluster_resources_only` to `true`. The Kiali Operator will manage those remote cluster resources for you; deleting the Kiali CR will instruct the Kiali Operator to remove the resources. If you elect not to use the Kiali Operator, you can use the Kiali Server helm chart (with the `--set deployment.remote_cluster_resources_only=true` option) or the [kiali-prepare-remote-cluster.sh script](https://github.com/kiali/kiali/blob/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh) (with the `--process-remote-resources true` option) to create these remote cluster resources.

2. **Create a remote cluster secret.** In order for Kiali to access a remote cluster, you must provide a kubeconfig to Kiali via a Kubernetes secret. This requires you to obtain a token for the remote cluster's SA created in step 1. A remote cluster secret will look something like this:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-cluster-name
  labels:
    kiali.io/multiCluster: "true"
stringData:
  my-cluster-name: |
    apiVersion: v1
    kind: Config
    preferences: {}
    current-context: my-cluster-name
    contexts:
    - name: my-cluster-name
      context:
        cluster: my-cluster-name
        user: my-cluster-name
    users:
    - name: my-cluster-name
      user:
        token: <...the long remote cluster SA token string goes here...>
    clusters:
    - name: my-cluster-name
      cluster:
        server: <...the URL to your remote cluster goes here...>
        certificate-authority-data: <...the long CA data goes here...>
```
You can place multiple kubeconfigs in a single secret. A Kiali multi-cluster secret will look similar to a single cluster secret, but with multiple kubeconfigs each with a key that is the name of the remote cluster (in the example below, there are two keys: `my-cluster-name` and `my-other-cluster`). Name the secret `kiali-multi-cluster-secret` for the added benefit of having the operator automatically detect this secret without having to configure anything within the Kiali CR. If you do name the secret `kiali-multi-cluster-secret` you also can add to it the label `kiali.io/kiali-multi-cluster-secret="true"` which will tell the operator to restart the Kiali Server pod automatically when the secret changes thus allowing the server to pick up the changes immediately.
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: kiali-multi-cluster-secret
  labels:
    kiali.io/kiali-multi-cluster-secret: "true"
stringData:
  my-cluster-name: |
    apiVersion: v1
    kind: Config
    preferences: {}
    current-context: my-cluster-name
    contexts:
    - name: my-cluster-name
      context:
        cluster: my-cluster-name
        user: my-cluster-name
    users:
    - name: my-cluster-name
      user:
        token: <...the long remote cluster SA token string goes here...>
    clusters:
    - name: my-cluster-name
      cluster:
        server: <...the URL to your remote cluster goes here...>
        certificate-authority-data: <...the long CA data goes here...>
  my-other-cluster: |
    apiVersion: v1
    kind: Config
    preferences: {}
    current-context: my-other-cluster
    contexts:
    - name: my-other-cluster
      context:
        cluster: my-other-cluster
        user: my-other-cluster
    users:
    - name: my-other-cluster
      user:
        token: <...the long remote cluster SA token string goes here...>
    clusters:
    - name: my-other-cluster
      cluster:
        server: <...the URL to your remote cluster goes here...>
        certificate-authority-data: <...the long CA data goes here...>
```

The [verify-kiali-permissions.sh script](https://github.com/kiali/kiali/blob/master/hack/istio/multicluster/verify-kiali-permissions.sh) can be used to check that your remote cluster secret provides the necessary permissions that Kiali needs to access the remote cluster. See the comments at the top of the script and its `--help` output for details on how to run it, but here's an example:
   ```sh
   curl -L -o verify-kiali-permissions.sh https://raw.githubusercontent.com/kiali/kiali/master/hack/istio/multicluster/verify-kiali-permissions.sh
   chmod +x verify-kiali-permissions.sh
   ./verify-kiali-permissions.sh --kubeconfig-secret istio-system:kiali-multi-cluster-secret:my-cluster-name --kiali-version v2.10.0
   ```

It is up to you how you want to create and manage the token and secret, however, you can use the [kiali-prepare-remote-cluster.sh script](https://github.com/kiali/kiali/blob/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh) (with the `--process-kiali-secret true` option) to simplify this process for you.

{{% alert color="info" %}}
The `kiali-prepare-remote-cluster.sh` script can be used to:
   - Create a Kiali SA and its role/role-binding in the remote cluster

   and/or,

   - Create a kubeconfig file and store it in a Kubernetes secret that is created in the namespace where Kiali is deployed.

In order to run this script you will need adequate permissions configured in your local kubeconfig for both the cluster on which Kiali is deployed and the remote cluster.

For example:
   ```sh
   curl -L -o kiali-prepare-remote-cluster.sh https://raw.githubusercontent.com/kiali/kiali/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh
   chmod +x kiali-prepare-remote-cluster.sh
   ./kiali-prepare-remote-cluster.sh --kiali-cluster-context east --remote-cluster-context west --view-only false --process-kiali-secret true --process-remote-resources true
   ```
Use the option `--help` for additional details on using the script to create and delete the remote cluster resources and secrets.
{{% /alert %}}

3. **Configure Kiali.** The Kiali CR provides configuration settings that enable the Kiali Server to use remote cluster secrets in order to access remote clusters. By default, the Kiali Operator will [auto-detect](/docs/configuration/kialis.kiali.io/#.spec.clustering.autodetect_secrets) any remote cluster secret that has a label `kiali.io/multiCluster="true"` and is found in the Kiali deployment namespace. The secrets created by the `kiali-prepare-remote-cluster.sh` script will be created that way and thus can be auto-detected. Alternatively, in the Kiali CR you can [explicitly specify each remote cluster secret](/docs/configuration/kialis.kiali.io/#.spec.clustering.clusters) rather than rely on auto-discovery. As a final alternative, you can create a single secret named `kiali-multi-cluster-secret` within the Kiali deployment namespace. Within that single secret you put the kubeconfigs for all of your remote clusters, each kubeconfig within its own top-level key under the secret's `stringData`, where the key name is the name of the cluster. As an added feature, if you label that `kiali-multi-cluster-secret` with the label `kiali.io/kiali-multi-cluster-secret="true"` then the Kiali Operator will be able to auto-detect changes to that secret and rollout a new Kiali Server pod so it can automatically update the remote cluster information.
{{% alert color="info" %}}
Do **not** use the label `kiali.io/kiali-multi-cluster-secret="true"` on any other secret not specifically named `kiali-multi-cluster-secret`. The operator will not have permission to see that secret and errors will occur if you attempt this.
{{% /alert %}}
{{% alert color="info" %}}
If you have multiple Kial Servers deployed in the same namespace, and you want to use that single secret named `kiali-multi-cluster-secret`, all Kiali Servers in that namespace are required to use that secret. If you want each Kiali Server to talk to a different set of clusters, you must not use the `kiali-multi-cluster-secret` secret.
{{% /alert %}}
Given the remote cluster secrets it knows about (either through auto-discovery or through explicit configuration) the Kiali Operator will mount the remote cluster secrets into the Kiali Server pod effectively putting Kiali in "multi-cluster" mode. Kiali will begin using those credentials to communicate with the other clusters in the mesh.

4. Optional - **Configure user access in your OIDC provider.** When using anonymous mode, the Kiali SA credentials will be used to display mesh info to the user. When not using anonymous mode, Kiali will check the user's access to each configured cluster's namespace before showing the user any resources from that namespace. Please refer to your OIDC provider's instructions for configuring user access to a kube cluster for this.

5. Optional - **Narrow metrics to mesh.** If your unified metrics store also contains data outside of your mesh, you can limit which metrics Kiali will query for by setting the [query_scope](/docs/configuration/kialis.kiali.io#.spec.external_services.prometheus.query_scope) configuration.

That's it! From here you can login to Kiali and manage your mesh across both clusters from a single Kiali instance.

### Removing a Cluster

To remove a cluster from Kiali, you must delete the associated remote cluster secret. If you originally created the remote cluster secret via the [kiali-prepare-remote-cluster.sh script](https://github.com/kiali/kiali/blob/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh), run that script again with the same command line options as before but also pass in the command line option `--delete true`.

{{% alert color="info" %}}
Don't forget to remove the resources (such as the SA and its role/role binding) from the remote cluster. If you created these resources with the Kiali Operator, simply delete the Kiali CR from the remote cluster and these resources will be removed. If you used the `kiali-prepare-remote-cluster.sh` script to create these resources, use it to remove these resources.
{{% /alert %}}

After the remote cluster secret has been removed, you must then tell the Kiali Operator to re-deploy the Kiali Server so the Kiali Server no longer attempts to access the now-deleted remote cluster secret. If you are using [auto-discovery](/docs/configuration/kialis.kiali.io/#.spec.clustering.autodetect_secrets), you can tell the Kiali Operator to do this by touching the Kiali CR. The easiest way to do this is to simply add or modify any annotation on the Kiali CR. It is recommended that you use the `kiali.io/reconcile` annotation as described [here](/docs/installation/installation-guide/creating-updating-kiali-cr). If you did not rely on auto-discovery but instead [explicitly specified each remote cluster secret](/docs/configuration/kialis.kiali.io/#.spec.clustering.clusters) in the Kiali CR, then you simply have to remove the now-deleted remote cluster secret's information from the Kiali CR's `clustering.clusters` section. Finally, if you are using the single `kiali-multi-cluster-secret` to define all of your remote clusters (and you labeled that secret with `kiali.io/kiali-multi-cluster-secret="true"`), then you do not have to do anything other than delete that one secret. The Kiali Operator will detect that the secret has been removed and will re-deploy the Kiali Server automatically.

### Adding an Inaccessible Cluster

In situations where Kiali does not have access to remote clusters, you can manually specify the remote cluster info along with any external Kialis running on the remote clusters and Kiali will try to provide links to these in the UI. For example, if there is a Kiali on the `east` cluster that does not have access to the `west` cluster and a Kiali on the `west` cluster that does not have access to the `east` cluster, you can add the following to your Kiali configurations to have each Kiali generate links to the external Kiali for that cluster.

East Kiali configuration

```
clustering:
  clusters:
    name: west
  kiali_urls:
    cluster_name: west
    instance_name: kiali
    namespace: istio-system
    url: https://kiali-external.west.example.com
```

West Kiali configuration

```
clustering:
  clusters:
    name: east
  kiali_urls:
    cluster_name: east
    instance_name: kiali
    namespace: istio-system
    url: https://kiali-external.east.example.com
```
