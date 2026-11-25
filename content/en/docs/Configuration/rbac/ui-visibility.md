---
title: "UI visibility by page"
description: "The permissions a user needs to see each part of the Kiali console."
---

Every page answers to the [namespace access model]({{< relref "./_index" >}}): a user's
visible namespaces are the ones they can _GET_ (or _LIST_), intersected with the
namespaces Kiali itself is allowed to serve (the discovery selectors when
`cluster_wide_access` is `false`). That visibility is the baseline for everything. A few
elements ask for more — a specific verb such as `pods/log`, write privileges for actions,
or access to the control plane namespace for infrastructure views — and one category,
traffic telemetry, is served from Kiali's own telemetry store and is therefore not
governed by the user's Kubernetes permissions at all. This page states, for each page of
the console, which permission unlocks which element.

{{% alert color="info" %}}
In the examples below, imagine a user who can see `bookinfo` on the home cluster but only
`team-a` on a remote cluster — and cannot see the remote's `istio-system` where its istiod
runs.
{{% /alert %}}

## Overview

The Overview is a row of summary cards — Clusters, Control Planes, Data Planes, Istio
Configs, Applications and Service Insights — each rolling up the whole mesh from the
user's point of view:

- **Clusters** — requires: the user to be logged in to the cluster. For a cluster the
  user has a session on, its infrastructure health is reported whether or not the user
  can access any namespace on it; a cluster the user is not logged in to does not appear.
- **Control Planes and Data Planes** — requires: _GET_ on the namespace where that
  cluster's istiod runs (commonly `istio-system`); see the [Mesh page](#mesh). A
  control plane whose istiod namespace the user cannot access is absent from both
  counts: in the example, only the home cluster's control plane and data plane are
  counted.
- **Istio Configs** — requires: the namespaces holding the objects to be visible. The
  count is the Istio configuration objects in the user's visible namespaces, across all
  clusters, so a user without access to a namespace sees its objects excluded. In the
  example, an administrator who can also see the remote's `bookinfo` and `istio-system`
  counts their objects while this user does not — the same mesh can legitimately show
  different totals to different users.
- **Applications and Service Insights** — requires: the namespace to be visible (_GET_
  the namespace, or _LIST_ namespaces). Both summarize the workloads and services of the
  user's visible namespaces, on every cluster.

## Traffic Graph

- **Nodes and edges** — requires: the selected namespaces to be visible. The traffic
  itself comes from telemetry.
- **Nodes in namespaces or clusters the user cannot see** — requires: nothing; the
  telemetry reports the traffic, so a node may appear for an invisible remote namespace.
  Its Istio configuration details (sidecar and waypoint badges, config drill-downs) are
  withheld, because Kiali will not serve configuration for a namespace the user cannot
  access.
- **Sidebar configuration and validation summaries for a node** — requires: the node's
  namespace to be visible.

## Mesh

- **Control plane node, and its data plane and namespace boxes** — requires: _GET_ on the
  namespace that cluster's istiod runs in (commonly `istio-system`). Clusters the user
  has this access for are shown normally; clusters without it simply do not appear on
  the page, which loads as usual with everything the user can access. In the example,
  the user sees only the home cluster's control plane.
- **Add-on nodes (for example Prometheus) and cluster boxes** — requires: no namespace
  permission; they describe Kiali's own connections.
- **Side panel details** (Istio version, mTLS, configuration table) — requires: the same
  as the node they belong to.

## Namespaces

- **List rows** — requires: the namespace to be visible. The list is exactly the user's
  visible namespaces.
- **Health, mTLS and Istio Config columns** — requires: no permission of the user's;
  Kiali's service account computes them for the namespaces it serves. (In
  non-cluster-wide-access mode the two sets are aligned by the discovery selectors.)
- **Type column** (ambient mode, injection labels) — requires: nothing beyond seeing the
  row; the labels are part of the namespace the user can already read.

## Applications, Services and Workloads

- **List rows** — requires: the namespace to be visible. Entries appear only from
  visible namespaces.
- **Details pages** — requires: the object's namespace to be visible. A user who cannot
  see the namespace gets a "Cannot access namespace data" error rather than an empty
  page.
- **Logs tab (Workloads details)** — requires: the `pods/log` verb on pods in that
  namespace. Logs are fetched with the user's own credentials, so a user with only
  namespace _read_ access may see the workload but not its logs.
- **Actions (scaling, deleting, editing labels and annotations, the wizards)** —
  requires: the corresponding write privileges in the cluster; Kiali does not simulate
  them.

## Istio Config

- **List rows** — requires: the namespace to be visible.
- **Details page** — requires: the object's namespace to be visible.
- **Editing or deleting an object** — requires: write privileges on that object.

{{% alert color="info" %}}
Kiali rejects the login of a user who cannot see any namespace at all, and requests
naming a namespace the user cannot access fail with "Cannot access namespace data"
without distinguishing it from a namespace that does not exist. Both behaviors are
described in the [namespace access model]({{< relref "./_index" >}}).
{{% /alert %}}
