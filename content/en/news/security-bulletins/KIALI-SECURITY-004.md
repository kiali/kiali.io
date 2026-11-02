---
title: "KIALI-SECURITY-004 - Missing namespace authorization checks in Kiali Server API endpoints"
date: 2026-11-02T11:00:00-06:00
type: docs
weight: -4
---

## Description

* **Disclosure date**: November 2, 2026
* **Affected Releases**: Kiali Server 2.x releases prior to 2.34.1 (see per-finding details below)
* **Impact Score**: [4.3 - AV:N/AC:L/PR:L/UI:N/S:U/C:L/I:N/A:N](https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator?vector=AV:N/AC:L/PR:L/UI:N/S:U/C:L/I:N/A:N&version=3.1)

Several Kiali Server API endpoints returned data about namespaces the caller
had no RBAC access to (CWE-862, missing authorization). The impact is
confidentiality only: no secrets or traffic content were exposed and nothing
could be modified. The issues were reported to the Kiali security team by a
member of the community and were verified on Kiali Server 2.34.0.

Kiali users are exposed to these findings depending on the endpoint:

* **Cluster health cache** — `GET /api/clusters/health?namespaces=` served
  cached health data for any namespace. The internal health cache is populated
  by a background monitor running with Kiali's ServiceAccount, and the handler
  only RBAC-filtered the response when the namespaces parameter was empty.
  This exposes application, service and workload names, replica counts, health
  statuses and traffic rates. Affected releases: v2.22.0 and later (the health
  cache is enabled by default since v2.22.0).
* **ztunnel logs** — `GET /api/namespaces/{namespace}/pods/{pod}/logs?logType=ztunnel`
  streamed ztunnel access-log lines for any namespace. The ztunnel log path
  fetches logs with Kiali's ServiceAccount rather than the caller's
  credentials, so the API server never enforced RBAC. Additionally, the log
  filter regexes were not anchored, so a pod name in the URL acted as a prefix
  that could match workloads other than the one requested. This exposes pod,
  workload and namespace names, SPIFFE identities, IP addresses and byte
  counts. Requires an ambient mesh. Affected releases: v2.11.0 and later.
* **ztunnel config dump** —
  `GET /api/namespaces/{namespace}/pods/{pod}/config_dump_ztunnel` returned
  the full mesh-wide configuration dump — every workload, service and policy
  in the mesh with pod IPs, service accounts and node information. The ztunnel
  pod was located by name across the cluster, so the namespace in the URL was
  irrelevant and no authorization check was performed. Requires an ambient
  mesh. Affected releases: all 2.x releases.
* **Cluster-wide Istio config validations** —
  `GET /api/istio/config?validate=true` correctly filtered the returned Istio
  config objects to the caller's accessible namespaces, but the validation
  entries attached to the response were not filtered. Any authenticated user
  received validation entries (object kind, name, namespace, misconfiguration
  messages and references to related objects) for Istio objects in every
  namespace of the cluster. The namespace-scoped variant
  (`GET /api/namespaces/{namespace}/istio?validate=true`) is not affected.

In addition, the `openshift` authentication strategy accepted any token for
which user-info lookup succeeded, without checking that the user can view any
namespace — unlike the `openid` strategy, which rejects such users. This
widened the audience of the findings above to any valid OpenShift token,
including ServiceAccounts that cannot see any namespace.

## Mitigation

If you can update:

* Update to Kiali Server v2.34.1 or later. In addition to fixing the findings
  above, this release makes namespace accessibility checks consistent across
  all namespace-scoped API endpoints (including tracing endpoints, which
  previously queried the tracing backend without a namespace check), and the
  `openshift` authentication strategy now rejects tokens that cannot view any
  namespace.

If you cannot update:

* Disable the internal health cache by setting
  `kiali_internal.health_cache.enabled: false` in the Kiali CR to close the
  cluster health exposure.
* Use the namespace-scoped Istio config validations endpoint
  (`GET /api/namespaces/{namespace}/istio?validate=true`) instead of the
  cluster-wide one.
* There is no configuration-level mitigation for the ztunnel log and ztunnel
  config dump endpoints. If you run an ambient mesh, restrict access to the
  Kiali Server API (for example, via network policy) so that only trusted
  users and workloads can reach it.
