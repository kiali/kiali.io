---
title: "Authentication"
date: 2020-08-25T00:00:00+02:00
draft: false
weight: 10
hideIndex: true
---

Kiali supports five authentication mechanisms:

* [anonymous]({{< relref "anonymous" >}}): gives free access to Kiali.
* [header]({{< relref "header" >}}): requires Kiali to run behind a reverse proxy that is responsible for injecting the user's token or a token with impersonation.
* [openid]({{< relref "openid" >}}): requires authentication through a third-party service to access Kiali.
* [openshift]({{< relref "openshift" >}}): requires authentication through the OpenShift authentication to access Kiali.
* [token]({{< relref "token" >}}): requires user to provide a Kubernetes ServiceAccount token to access Kiali.

The default authentication mechanism for OpenShift clusters is `openshift`. For
all other Kubernetes clusters, the default mechanism is `token`.

Read the dedicated page of each authentication mechanism (by clicking on the
bullets) to learn more. All mechanisms other than `anonymous` support [Role-based access control]({{<relref "../rbac" >}}).
