---
title: "Role-based access control"
date: 2020-08-25T00:00:00+02:00
draft: false
weight: 40
---

## Introduction

Kiali supports role-based access control (RBAC) when you are using either the
`openid`, `openshift` or `token` authentication strategies.

If you are using the `anonymous` strategy, RBAC isn't supported, but you still
can limit privileges if your cluster is OpenShift. See the
[access control section in Anonymous strategy ]({{< relref "./authentication/anonymous#access-control" >}}).

Kiali uses the RBAC capabilities of the underlying cluster. Thus, RBAC is
accomplished by using the standard RBAC features of the cluster, which is
through ClusterRoles, ClusterRoleBindings, Roles and RoleBindings resources.
Read the [Kubernetes RBAC documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
for details. If you are using OpenShift, read the
[OpenShift RBAC documentation](https://docs.openshift.com/container-platform/4.5/authentication/using-rbac.html).

In general, Kiali will give access to the resources granted to the account used
to login. Specifically, depending on the authentication strategy, this
translates to:

|Authentication Strategy|Access To|
|------------|------------------|
|`openid`    |resources granted to the user of the third-party authentication system|
|`openshift` |resources granted to the OpenShift user|
|`token`     |resources granted to the ServiceAccount whose token was used to login|

For example, if you are using the `token` strategy, you would grant
cluster-wide privileges to a ServiceAccount with this command:

```
$ kubectl create clusterrolebinding john-binding --clusterrole=kiali --serviceaccount=mynamespace:john
```

and if you are using `openshift` or `openid` strategies, you could assign
privileges with any of these commands:

```
$ kubectl create rolebinding john-openid-binding --clusterrole=kiali --user="john@example.com" --namespace=mynamespace
$ oc adm policy add-role-to-user kiali john -n mynamespace # For OpenShift clusters
```

Please read your cluster RBAC documentation to learn how to assign privileges.

## Minimum required privileges to login

The `get namespace` privilege in some namespace is the minimum privilege needed
in order to be able to login to Kiali. This means you need the following
minimal `Role` bound to the user that wants to login:

```
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
rules:
- apiGroups: [""]
  resources:
  - namespaces
  verbs:
  - get
```

This minimal `Role` will allow a user to login. Kiali may work partially, but
some pages may be blank or show erroneous information, and errors will be
logged constantly. You will need a broader set of privileges so that Kiali
works fine.

## Privileges required for Kiali to work correctly

The default installation of Kiali creates a `ClusterRole` with the needed
privileges to take the most advantage of all Kiali features. Inspect the
privileges with

```
kubectl describe clusterrole kiali
```

{{% alert color="warning" %}}
If you installed Kiali with `view_only_mode: true`
option, the `ClusterRole` will be named `kiali-viewer` instead of `kiali`.
{{% /alert %}}

Alternatively, check in the Kiali Operator source code. See either the
[Kubernetes role.yaml template file](https://github.com/kiali/kiali-operator/blob/master/roles/default/kiali-deploy/templates/kubernetes/role.yaml), or the
[OpenShift role.yaml template file](https://github.com/kiali/kiali-operator/blob/master/roles/default/kiali-deploy/templates/openshift/role.yaml).

You can use this `ClusterRole` to assign privileges to users requiring access
to Kiali. You can assign privileges either in one namespace, which will result in
users being able to see only resources in that namespace; or assign
cluster-wide privileges.

For example, to assign privileges to the `john` user and limiting access to the
`myApp` namespace, you could run either:

```
$ kubectl create rolebinding john-binding --clusterrole=kiali --user="john" --namespace=myApp
$ oc adm policy add-role-to-user kiali john -n myApp # For OpenShift clusters
```

But if you need to assign cluster-wide privileges, you could run either:

```
$ kubectl create clusterrolebinding john-admin-binding --clusterrole=kiali --user="john"
$ oc adm policy add-cluster-role-to-user kiali john # For OpenShift clusters
```

In case you need to assign a more limited set of privileges than the ones
present in the Kiali `ClusterRole`, create your own `ClusterRole` or `Role`
based off the privileges in Kiali's `ClusterRole` and remove the privileges you
want to ban. You must understand that some Kiali features may not work properly
because of the reduced privilege set.

{{% alert color="warning" %}}
Do not edit the `kiali` or the `kiali-viewer`
`ClusterRoles` because they are bound to the Kiali ServiceAccount and editing
them may lead to Kiali not working properly.
{{% /alert %}}

