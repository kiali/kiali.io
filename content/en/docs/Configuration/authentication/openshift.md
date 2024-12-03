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

The `openshift` strategy is only supported for single cluster.

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

### Multi-Cluster - Using an internal or self-signed certificate

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

After restarting the Kiali pod, Kiali will trust this root certificate for all HTTPS requests related to OAuth authentication. If you have multiple different CAs, for different clusters, include each as a separate block in the bundle.

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
