---
title: "Anonymous strategy"
linktitle: "Anonymous"
description: "Access Kiali with no authentication."
weight: 10
---

## Introduction

The `anonymous` strategy removes any authentication requirement. Users will
have access to Kiali without providing any credentials.

Although the `anonymous` strategy doesn't provide any access protection, it's
valid for some use-cases. Some examples known from the community:

* Exposing Kiali through a reverse proxy, where the reverse proxy is providing a custom authentication mechanism.
* Exposing Kiali on an already limited network of trusted users.
* When Kiali is accessed through `kubectl port-forward` or alike commands that allow usage of the cluster's RBAC capabilities to limit access.
* When developing Kiali, where a developer has a private instance on his own machine.


{{% alert color="warning" %}}
It's worth to emphasize that the `anonymous`
strategy will leave Kiali unsecured. If you are using this option, make sure
that Kiali is available only to trusted users, or access is protected by other
means.
{{% /alert %}}

## Set-up

To use the `anonymous` strategy, use the following configuration in the Kiali CR:

```yaml
spec:
  auth:
    strategy: anonymous
```

The `anonymous` strategy doesn't have any additional configuration.

## Access control

When using the `anonymous` strategy, the content displayed in Kiali is based on
the permissions of the Kiali service account. By default, the Kiali service
account has cluster wide access and will be able to display everything in the
cluster.

### OpenShift

If you are running Kiali in OpenShift, access can be customized by changing
privileges to the Kiali ServiceAccount. For example, to reduce permissions to
individual namespaces, first, remove the cluster-wide permissions granted by
default:

```
  oc delete clusterrolebindings kiali
```

Then grant the `kiali` role only in needed namespaces. For example:

```
  oc adm policy add-role-to-user kiali system:serviceaccount:istio-system:kiali-service-account -n ${NAMESPACE}
```

### View only

You can tell the Kiali Operator to install Kiali in "view only"
mode (this does work for either OpenShift or Kubernetes). You do this by
setting the `view_only_mode` to `true` in the Kiali CR, which
allows Kiali to read service mesh resources found in the cluster, but it does
not allow any change:

```yaml
spec:
  deployment:
    view_only_mode: true
```
