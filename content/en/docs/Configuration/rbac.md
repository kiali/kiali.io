---
title: "Namespace access control"
description: "Configuring per-user authorized namespaces."
---

## Introduction

In authentication strategies other than `anonymous` Kiali supports limiting the
namespaces that are accessible on a per-user basis. The `anonymous`
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
Kiali is going to reject login to users that aren't authorized to see any namespace.
{{% /alert %}}

## Granting access to namespaces

In general, Kiali will give _read_ access to namespaces where the logged in
user is allowed to _"GET"_ its definition -- i.e. the user is allowed to do a
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
- apiGroups: ["project.openshift.io"] # Only if you are using OpenShift
  resources:
  - projects
  verbs:
  - get
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

{{% alert color="info" %}}
Note that in this example, the subject kind is `User`, which is the case when
using `openid` or `openshift` authentication strategies. For other
authentication strategies you would need to adjust the `RoleBinding` to use the
right subject kind.
{{% /alert %}}

If you want to authorize a user to access _all namespaces_ in the cluster, the
most efficient way to do it is by creating a `ClusterRole` with the _list_ verb
for namespaces and bind it to the user using a `ClusterRoleBinding`:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kiali-all-namespaces-authorization
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - pods/log
  verbs:
  - get
  - list
- apiGroups: ["project.openshift.io"] # Only if you are using OpenShift
  resources:
  - projects
  verbs:
  - get
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: authorize-all-namespaces-to-john
subjects:
- kind: User
  name: john
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: kiali-all-namespaces-authorization
  apiGroup: rbac.authorization.k8s.io
``` 

{{% alert color="info" %}}
Note that the only addition to the `ClusterRole` is the `list` verb in the first rule.
{{% /alert %}}

Alternatively, you could also use the previously mentioned
`kiali-namespace-authorization` rather than creating a new one with the _list_
privilege, and it will work. However, Kiali will perform better if you grant the
_list_ privilege.

{{% alert color="info" %}}
Please read your cluster RBAC documentation to learn more about the
authorization system.
{{% /alert %}}

## Granting write privileges to namespaces

Changing resources in the cluster can be a sensitive operation. Because of
this, the logged in user will need to be given the needed privileges to perform
any updates through Kiali. The following `ClusterRole` contains all write
privileges that may be used in Kiali:

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: kiali-write-privileges
rules:
- apiGroups: [""]
  resources:
  - namespaces
  - pods
  - replicationcontrollers
  - services
  verbs:
  - patch
- apiGroups: ["extensions", "apps"]
  resources:
  - daemonsets
  - deployments
  - replicasets
  - statefulsets
  verbs:
  - patch
- apiGroups: ["batch"]
  resources:
  - cronjobs
  - jobs
  verbs:
  - patch
- apiGroups:
  - networking.istio.io
  - security.istio.io
  - extensions.istio.io
  - telemetry.istio.io
  - gateway.networking.k8s.io
  resources: ["*"]
  verbs:
  - create
  - delete
  - patch
```

{{% alert color="info" %}}
If needed, you can reduce the set of write privileges to prevent users from changing
unwanted resources.
{{% /alert %}}

Similarly to giving access to namespaces, you can either use a `RoleBinding` to
give write privileges only to specific namespaces, or use a
`ClusterRoleBinding` to give privileges to all namespaces.


