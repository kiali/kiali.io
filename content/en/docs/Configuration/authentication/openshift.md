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

The `openshift` strategy takes advantage of the cluster's RBAC. See the
[Role-based access control documentation]({{< relref "../rbac" >}}) for more
details.

## Set-up

Since `openshift` is the default strategy when deploying Kiali in OpenShift,
you shouldn't need to configure anything. If you want to be verbose, use the
following configuration in the Kiali CR:

```yaml
spec:
  auth:
    strategy: openshift
```

The `openshift` strategy doesn't have any additional configuration. The Kiali
operator will make sure to setup the needed OpenShift OAuth resources to register
Kiali as a client.
