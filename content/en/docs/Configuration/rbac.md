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

Kiali uses two Kubernetes RBAC verbs to determine which namespaces a user can
see:

- **GET** -- grants access to individual namespaces. A user who can _GET_ a
  specific namespace (`api/v1/namespaces/{name}`) will see that namespace in
  Kiali. Use per-namespace `RoleBindings` to control this.
- **LIST** -- grants access to all namespaces at once. A user who can _LIST_
  namespaces (`api/v1/namespaces`) will, by default, see every namespace
  returned by the list. This is typically granted via a `ClusterRoleBinding`.

In most setups, granting _LIST_ is the simplest way to give a user access to
all namespaces, while _GET_ via `RoleBindings` provides fine-grained,
per-namespace control.

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

### Multi-tenant environments and `require_namespace_get`

By default, when a user has _LIST_ permission on namespaces, Kiali trusts
the list result and shows all returned namespaces without checking individual
_GET_ permission. This is efficient but can be a problem in multi-tenant
environments where _LIST_ is granted broadly (e.g. via a `ClusterRoleBinding`)
while _GET_ is restricted to specific namespaces per user via `RoleBindings`.

To enforce stricter access control, enable the `require_namespace_get`
feature flag:

```yaml
spec:
  kiali_feature_flags:
    authz:
      require_namespace_get: true
```

When this is enabled, Kiali will verify _GET_ permission for each namespace
individually, even if the user's _LIST_ call succeeds. Only namespaces where
the user has _GET_ permission will be visible. This ensures that _LIST_
permission alone is never sufficient to see a namespace.

{{% alert color="info" %}}
This setting only affects users with cluster-wide _LIST_ permission. Users
who do not have _LIST_ permission already fall back to per-namespace _GET_
checks regardless of this setting.
{{% /alert %}}

{{% alert color="warning" %}}
Enabling `require_namespace_get` adds a _GET_ API call per namespace on
cache misses. In clusters with a very large number of namespaces this may
increase the time to populate the namespace list. Results are cached per
user session, so the overhead applies only on the first request after login
or cache expiry.
{{% /alert %}}

## Granting write privileges to namespaces

Changing resources in the cluster can be a sensitive operation. Because of
this, the logged in user will need to be given the needed privileges to perform
any updates through Kiali. The following `ClusterRole` contains all read and write
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
  - get
  - list
  - watch
  - create
  - delete
  - patch
```

{{% alert color="info" %}}
If needed, you can reduce the set of write privileges to prevent users from changing
unwanted resources. However read privileges are require to read the resources.
{{% /alert %}}

Similarly to giving access to namespaces, you can either use a `RoleBinding` to
give read and write privileges only to specific namespaces, or use a
`ClusterRoleBinding` to give privileges to all namespaces.


