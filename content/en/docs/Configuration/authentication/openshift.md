---
title: "OpenShift strategy"
linktitle: "OpenShift"
description: "Access Kiali requiring OpenShift authentication."
weight: 40
---

## Introduction

The `openshift` authentication strategy is the preferred and default strategy
when Kiali is deployed on an OpenShift cluster.

When using the `openshift` strategy, a user logging into Kiali will be
redirected to the login page of the OpenShift console. Once the user provides
his OpenShift credentials, he will be redireted back to Kiali and will be
logged in if the user has enough privileges.

The `openshift` strategy supports [namespace access control]({{< relref "../rbac" >}}).

The `openshift` strategy is supported for single and multi-cluster deployments.

## Set-up

Since `openshift` is the default strategy when deploying Kiali in OpenShift,
you shouldn't need to configure anything. If you want to be verbose, use the
following configuration in the Kiali CR:

```yaml
spec:
  auth:
    strategy: openshift
```

The Kiali operator will make sure to setup the needed OpenShift OAuth resources to register
Kiali as a client for the most common use-cases. The `openshift` strategy does have a few
configuration settings that most people will never need but are available in case you have
a situation where the customization is needed. See the Kiali CR Reference page for the
documentation on those settings.

### Multi-Cluster

There are some things to know when using the `openshift` strategy with Kiali in a multi-cluster environment.

#### Consistent Kiali Namespace and Instance-Name

The default namespace for Kiali is `istio-system`. But many users prefer to use a dedicated namespace for Kiali, such as `kiali`, `kiali-server`, etc. In a multi-cluster environment Kiali must be deployed in the same namespace on each cluster. Clusters that don't have a Kiali deployment must still provide the namespace, to hold the remote cluster resources.

The default instance-name for kiali is `kiali`. Any change to the default must also be made consistently across all clusters.

Assuming Kiali is installed via the Kiali Operator. Any customization would be done via the following CR settings:

- `spec.deployment.namespace`
- `spec.deployment.instance_name`

{{% alert color="info" %}}
It is recommended that the Kiali Operator be deployed on all clusters, even if Kiali itself is not deployed. This will ensure that the proper namespace and remote cluster resources are created. For clusters without Kiali, requiring only the remote cluster resources (for auth), configure the CR with:

- `spec.deployment.remote_cluster_resources_only: true`
  {{% /alert %}}

#### OpenShift OAuthClient Naming

OpenShift OAuth requires an `OAuthClient` resource on each cluster to be named `<instance-name>-<namespace>`. For example, if Kiali is installed with the default instance name `kiali` in namespace `istio-system`, the OAuthClient on every cluster must be named `kiali-istio-system`.

Both the Kiali Operator and the Kiali Server helm chart automatically create the `OAuthClient` with the correct name when they create the remote cluster resources. The `kiali-prepare-remote-cluster.sh` script also delegates to the Kiali Server helm chart for resource creation and will produce a correctly-named `OAuthClient`, provided you pass `--kiali-resource-name` and `--remote-cluster-namespace` values that match the Kiali instance name and namespace on the cluster where Kiali is deployed. If you are managing resources entirely manually, ensure the `OAuthClient` on the remote cluster is named consistently with the Kiali instance name and namespace.

If the `OAuthClient` names do not match across clusters, OAuth authentication will fail.

#### OAuthClient Redirect URIs for Remote Cluster Resources

When using `remote_cluster_resources_only: true` on a remote cluster with the `openshift` auth strategy, the Kiali Operator must create an `OAuthClient` resource but cannot automatically determine the redirect URI (since there is no Kiali server or route on the remote cluster). You must explicitly specify the redirect URI in the Kiali CR on the remote cluster via `spec.auth.openshift.redirect_uris`. Without this, the Kiali Operator will fail to reconcile with the error:

```
Redirect URIs for the Kiali Server OAuthClient are not specified via auth.openshift.redirect_uris;
this is required when creating remote cluster resources with auth.strategy of openshift.
```

The redirect URI must point back to the Kiali server on the cluster where Kiali is deployed. Critically, the URI must include the remote cluster's name as a path suffix in the form `https://<kiali-route-host>/api/auth/callback/<remote-cluster-name>`. This is required so that the OAuth callback can correctly identify which cluster the login is for. Using the base `/api/auth/callback` path (without the cluster name) will result in the login failing with a `http: named cookie not present` error.

To determine the correct URI:

- If Kiali is already deployed, run this on the cluster where Kiali is deployed: `oc get route -l app.kubernetes.io/name=kiali -n <kiali-namespace> -o jsonpath='{..spec.host}'`
- If Kiali is not yet deployed, you can predict the route hostname from the cluster's app domain by running this on the cluster where Kiali will be deployed: `oc get ingresses.config.openshift.io cluster -o jsonpath='{.spec.domain}'`

The Kiali route hostname will be something like `kiali-<namespace>.<app-domain>`, so the full redirect URI will be something like `https://kiali-<namespace>.<app-domain>/api/auth/callback/<remote-cluster-name>`, where `<remote-cluster-name>` is the Istio cluster name of the remote cluster.

For example, if Kiali is deployed in namespace `istio-system` with instance_name `kiali`, the app domain is `apps.east.example.com`, and the remote cluster's Istio cluster name is `west`, the Kiali CR on the remote cluster should include:

```yaml
spec:
  auth:
    openshift:
      redirect_uris:
        - https://kiali-istio-system.apps.east.example.com/api/auth/callback/west
  deployment:
    remote_cluster_resources_only: true
```

#### User Login Flow for Multi-Cluster

When using the `openshift` strategy with multiple clusters, users must be logged into each cluster in order to access resources on that cluster. The Kiali UI provides a mechanism to log into remote clusters:

1. In your browser, navigate to the Kiali UI and log in using your credentials for the cluster where Kiali is deployed.
2. Once logged in, use the user profile dropdown in the Kiali UI to initiate login to each remote cluster. Kiali will redirect you to the remote cluster's OpenShift login page.
3. Log in with your credentials for that remote cluster. You will be redirected back to the Kiali UI. Repeat step 2 for each additional remote cluster until you are logged into all clusters.

{{% alert color="info" %}}
Currently, OpenShift OAuth does not provide SSO across clusters. Each cluster requires its own login. If you are having trouble logging into a remote cluster from within Kiali, try starting a fresh private/incognito browser tab to ensure there are no stale OAuth cookies from prior logins to the remote cluster's OpenShift console.
{{% /alert %}}

#### Using an internal or self-signed certificate

If you have a multi-cluster Kiali deployment and the OAuth server is configured with an external IdP that uses an internal or self-signed certificate, you can configure Kiali to trust the server's certificate by creating a ConfigMap named `kiali-oauth-cabundle` containing the CA certificate bundle for the server under the `oauth-server-ca.crt` key:

{{% alert color="info" %}}
Note that if you are deploying Kiali with `spec.deployment.instance_name` set to a value that is different than the default of `kiali`, your ConfigMap name needs to be that instance name appended with "-oauth-bundle". For example, if your instance name is "myserver" then the name of the ConfigMap must be `myserver-oauth-cabundle`.
{{% /alert %}}

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kiali-oauth-cabundle
  namespace: istio-system # This is Kiali's install namespace
data:
  oauth-server-ca.crt: <PEM encoded CA root certificate>
```

Kiali will automatically trust this root certificate for all HTTPS requests (not just OAuth). The certificate is loaded into Kiali's global certificate pool. Kiali watches for changes to the CA bundle and automatically refreshes without requiring a pod restart. If you have multiple different CAs, for different clusters, include each as a separate block in the bundle.

{{% alert color="info" %}}
For most use cases, you can simply add your CA to the `kiali-cabundle` ConfigMap under the `additional-ca-bundle.pem` key instead of creating a separate `kiali-oauth-cabundle` ConfigMap. Both approaches result in the CA being trusted globally.
{{% /alert %}}

#### Insecure setting

{{% alert color="warning" %}}
You should only use this setting for testing and not in a production environment.
{{% /alert %}}

You can disable certificate validation between Kiali and the remote OAuth server(s) by setting `insecure_skip_verify_tls` to `true` in
the Kiali CR:

```yaml
spec:
  auth:
    openshift:
      insecure_skip_verify_tls: true
```
