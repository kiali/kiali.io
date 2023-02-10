---
title: "Authentication Strategies"
description: "Choosing and configuring the appropriate authentication strategy."
---

Kiali supports five authentication mechanisms.

* The default authentication strategy for OpenShift clusters is `openshift`.
* The default authentication strategy for all other Kubernetes clusters is `token`.

All mechanisms other than `anonymous` support [limiting per-user namespace access control]({{<relref "../rbac" >}}).

Read the dedicated page of each authentication strategy to learn more.
