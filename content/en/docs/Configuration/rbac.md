---
title: "Namespace Authorization"
description: "Configuring per-user authorized namespaces."
---

## Introduction

In authentication strategies other than `anonymous` Kiali supports limiting the
namespaces that are accessible in a per-user basis. The `anonymous`
authentication strategy does not support this, although you can still limit
privileges when using an OpenShift cluster. See the [access control section in
Anonymous strategy]({{< relref "./authentication/anonymous#access-control" >}}).

To authorize namespaces, the standard `Roles` resources (or `ClusterRoles`)
and `RoleBindings` resources (or `ClusterRoleBindings`) are used.

{{% alert color="info" %}}
The [Kubernetes RBAC documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
describe how to use _Roles, ClusterRoles, RoleBindings_ and _ClusterRoleBindings_
resources. If you are using OpenShift, read the
[OpenShift RBAC documentation](https://docs.openshift.com/container-platform/latest/authentication/using-rbac.html).
{{% /alert %}}

Kiali can only restrict or grant _read_ access to namespaces as a whole. So,
keep in mind that while the RBAC capabilities of the cluster are used to give
access, Kiali won't offer the same privilege granularity that the cluster
supports. For example, a user that does not have privileges to get Kubernetes
`Deployments` via typical tools (e.g. `kubectl`) would still be able to get
some details of Deployments through Kiali when [listing Workloads or when
viewing detail pages]({{<relref "../features/details">}}), or in the
[Graph]({{<relref "../features/topology">}}).

Some features allow creating or changing resources in the cluster (for example,
[the Wizards]({{<relref "../features/wizards" >}})). For these _write_
operations which may be sensitive, the users will need to have the required
privileges in the cluster to perform updates - i.e. the cluster RBAC takes
effect.

{{% alert color="warning" %}}
Kiali is going to reject login to users that aren't authorized any namespace.
{{% /alert %}}

## Granting or restricting access to namespaces

In general, Kiali will give _read_ access to namespaces where the logged in
user is granted to _"GET"_ its definition -- i.e. the user is allowed to do a
`GET` call to the `api/v1/namespaces/{namespace-name}` endpoint of the cluster
API. Users granted the _LIST_ verb would get access to all namespaces of the
cluster (that's a `GET` call to the `api/v1/namespaces` endpoint of the cluster
API).

You, probably, will want to have this small `ClusterRole` to help you in
authorizing individual namespaces in Kiali:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kiali-namespace-authorization
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - pods/log
  verbs:
  - get
``` 

This `ClusterRole` can be created with the following command:

```bash
$ kubectl create clusterrole kiali-namespace-authorization --verb=get --resource=namespaces,pods/log
```

{{% alert color="info" %}}
The `pods/log` privilege is needed for the [pods Logs view]({{<relref "../features/details#logs">}}).
Since logs are potentially sensitive, you could remove that privilege if you
don't want users to be able to fetch pod logs.
{{% /alert %}}

Once you have created this `ClusterRole`, you would authorize a namespace
`foobar` to user `john` with the following `RoleBinding`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: authorize-ns-foobar-to-john
  namespace: foobar
subjects:
- kind: User
  name: john
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: kiali-namespace-authorization # The name of the ClusterRole created previously
  apiGroup: rbac.authorization.k8s.io
```

This `RoleBinding` can be created with the following command:

```bash
$ kubectl create rolebinding authorize-ns-foobar-to-john --clusterrole=kiali-namespace-authorization --user=john --namespace=foobar
$ oc adm policy add-role-to-user kiali-namespace-authorization john -n foobar # For OpenShift clusters
```

{{% alert color="info" %}}
Note that in this example, the subject kind is `User`, which is the case when
using `openid` or `openshift` authentication strategies. For other
authentication strategies you would need to adjust the `RoleBinding` to use the
right subject kind.
{{% /alert %}}

If you want to authorize a user to access _all namespaces_ in the cluster, the
most efficient way to do it is by creating a `ClusterRole` with the _list_ verb
for namespaces and bind it to the user using a `ClusterRoleBinding`. The
following commands do this (it is left to the reader to infer the equivalent
YAML):

```bash
# Create the ClusterRole
$ kubectl create clusterrole kiali-all-namespaces-authorization --verb=list --resource=namespaces,pods/log

# Create the ClusterRoleBinding
$ kubectl create clusterrolebinding authorize-all-namespaces-to-john --clusterrole=kiali-all-namespaces-authorization --user=john
$ oc adm policy add-cluster-role-to-user kiali-all-namespaces-authorization john # For OpenShift clusters
```

Alternatively, you could also use the previously mentioned
`kiali-namespace-authorization` rather than creating a new one with the _list_
privilege, and it will work. However, Kiali will perform better if you grant the
_list_ privilege.

{{% alert color="info" %}}
Please read your cluster RBAC documentation to learn more about the
authorization system.
{{% /alert %}}

