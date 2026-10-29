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
[OpenShift RBAC documentation](https://docs.redhat.com/en/documentation/openshift_container_platform/4.22/html/rbac_apis/rbac-apis).
{{% /alert %}}

Kiali can only restrict or grant _read_ access to namespaces as a whole. So,
keep in mind that while the RBAC capabilities of the cluster are used to give
access, Kiali won't offer the same privilege granularity that the cluster
supports. For example, a user that does not have privileges to get Kubernetes
`Deployments` via typical tools (e.g. `kubectl`) would still be able to get
some details of Deployments through Kiali when [listing Workloads or when
viewing detail pages]({{< relref "../Features/details" >}}), or in the
[Graph]({{< relref "../Features/topology" >}}).

Some features allow creating or changing resources in the cluster (for example,
[the Wizards]({{< relref "../Features/wizards" >}})). For these _write_
operations which may be sensitive, the users will need to have the required
privileges in the cluster to perform updates - i.e. the cluster RBAC takes
effect.

{{% alert color="warning" %}}
Kiali is going to reject login to users that aren't authorized to see any namespace.
{{% /alert %}}

{{% alert color="info" %}}
Requests for a namespace the user cannot access fail with a
"Cannot access namespace data" error. Kiali does not distinguish between a
namespace that does not exist and one the user is not allowed to see.
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

Whichever verb a user has, Kiali applies the result consistently to the data it serves itself: graphs, detail pages, metrics, dashboards, traces and validations use the same namespace access rules. Application, proxy and waypoint logs are fetched with the user's own credentials, so Kubernetes additionally requires pods/log permission in the namespace containing the pod. Correlated ztunnel logs are fetched with Kiali's service account; Kiali checks the user's access to the application's namespace before returning those logs.

{{% alert color="warning" %}}
In the default configuration, a user who can _LIST_ namespaces can see all
of them in Kiali — on every view, reliably. If your cluster grants _LIST_
broadly (for example, a cluster-wide `ClusterRoleBinding` shared by all
tenants) but restricts per-namespace _GET_, users will see every namespace
unless you enable `require_namespace_get` (see below).
{{% /alert %}}

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
The `pods/log` privilege is needed for the [pods Logs view]({{< relref "../Features/details#logs" >}}).
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

Kiali supports two modes for deciding which namespaces a user can see when
they hold cluster-wide _LIST_ permission:

- **Default mode** trusts the _LIST_ result: a user who can list namespaces
  sees everything the list returns, on every view.
- **Strict mode** additionally requires per-namespace _GET_ permission, and
  is enabled with the `require_namespace_get` feature flag:

```yaml
spec:
  kiali_feature_flags:
    authz:
      require_namespace_get: true
```

In strict mode, Kiali verifies _GET_ permission for each namespace
individually, even if the user's _LIST_ call succeeds. Only namespaces where
the user has _GET_ permission are visible — _LIST_ permission alone is never
sufficient to see a namespace.

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

## Tracing

Kiali's [tracing views]({{< relref "../Features/tracing" >}}) follow the
same namespace permissions as the rest of Kiali. This is worth knowing
because the tracing backends Kiali integrates with (Jaeger, Grafana Tempo)
do not have their own access control — Kiali enforces the logged-in user's
namespace access before returning trace data to the user. A user must have
access to a namespace to see its traces, spans and error-trace counts. To
open a trace by its ID, the user must have access to at least one namespace
the trace passes through; a trace that crosses several namespaces is visible
to any user who can access one of them. Authorization is per trace, not per
span:
once a trace is accessible, all of its spans are shown, including the spans
of services in namespaces the user cannot access.

In a multicluster setup, when the tracing telemetry identifies the cluster
a trace belongs to, the user must have access to the namespace in that
cluster — access to a same-named namespace in a different cluster does not
authorize opening the trace. Traces whose telemetry does not identify a
cluster are checked against the namespace name in any cluster. The cluster
match uses Kiali's cluster names, which must match the Istio cluster IDs —
they do by default, but explicitly configured names that diverge make the
mismatched clusters' namespaces unmatchable, so traces whose recognizable
namespaces are all attributed to those clusters are denied (see the
[multi-cluster configuration]({{< relref "multi-cluster" >}}) page).

A trace must carry namespace information in its telemetry for Kiali to
show it: Kiali reads the `istio.namespace`, `istio.source_namespace`,
`istio.destination_namespace` and `k8s.namespace.name` span attributes
(and the `node_id` of sidecar spans). Traces whose spans carry none of
these cannot be authorized for any user and are excluded from the tracing
views. The `service.namespace` attribute is not read for authorization:
it is a logical service grouping controlled by the application, not the
Kubernetes namespace the span was produced in. Istio mesh telemetry
carries the namespace attributes; spans emitted directly by applications
through an OpenTelemetry collector may not — configure the collector's
`k8sattributes` processor to set `k8s.namespace.name` on those spans so
their traces remain visible.
