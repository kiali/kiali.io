---
title: "Token strategy"
linktitle: "Token"
description: "Access Kiali requiring a Kubernetes ServiceAccount token."
weight: 50
---

## Introduction

The `token` authentication strategy allows a user to login to Kiali using the
token of a Kubernetes ServiceAccount. This is similar to the
[login view of Kubernetes Dashboard](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/README.md#login-view).

The `token` strategy takes advantage of the cluster's RBAC. See the [Role-based access control documentation]({{< relref "../rbac" >}})
for more details.

## Set-up

Since `token` is the default strategy when deploying Kiali in Kubernetes, you
shouldn't need to configure anything, unless your cluster is OpenShift. If you
want to be verbose or if you need to enable the `token` strategy in OpenShift,
use the following configuration in the Kiali CR:

```yaml
spec:
  auth:
    strategy: token
```

The `token` strategy doesn't have any additional configuration other than the
[session expiration time]({{< relref "session-configs" >}}).
