---
title: "Health Status Alerts"
description: "Export Kiali health status as Prometheus metrics, scrape them with User Workload Monitoring, and define recording rules and alerts for OpenShift Observability."
weight: 40
---

## Overview

This guide shows how to export Kiali's mesh health (Healthy / Not Ready / Degraded / Failure) as the Prometheus gauge `kiali_health_status`, scrape it with OpenShift User Workload Monitoring (UWM), and define useful recording rules and alerts that appear in the OpenShift console under **Observe > Alerting**.

It applies to:

- **Single-cluster OpenShift** — follow Phases 1–5
- **Multi-cluster with ACM Observability** — complete Phases 1–3 on each cluster that runs Kiali, then Phase 6 on the hub to allowlist `kiali_health_status` into hub Thanos and optionally add fleet-wide hub alerts via ACM Thanos Ruler. Add Phases 4–5 on managed clusters if you also want local alerts.

Kiali does **not** deploy Prometheus or act as Alertmanager. It only exports a gauge that your existing OpenShift monitoring stack scrapes and evaluates.

{{% alert color="info" %}}
**Single-cluster readers:** You do not need ACM or the earlier multi-cluster tutorials. Commands below use `--context=ossm-kiali-spoke` (same name as the hub/spoke tutorial); substitute your cluster's context if needed, and skip [Phase 6](#phase-6-multi-cluster-with-acm-observability).
{{% /alert %}}

{{% alert color="info" %}}
**Multi-cluster readers:** This guide builds on the same UWM and metrics-allowlist concepts as the [MultiCluster on OpenShift]({{< relref "./ossm-acm-hub-spoke" >}}) tutorial. You do not need to re-install ACM. Completing the hub/spoke guide (at minimum) is recommended so Istio metrics, Kiali, and the Bookinfo demo are already in place.
{{% /alert %}}

Kiali computes traffic health (and workload readiness) for apps, services, workloads, and namespaces (see [Traffic Health]({{< relref "../../Configuration/health" >}})). When health-status metrics are enabled, each entity's status is exported as the gauge `kiali_health_status` with these values:

- **`0`**: Healthy
- **`1`**: Not Ready
- **`2`**: Degraded
- **`3`**: Failure

Those series can drive OpenShift Observability alerts on each cluster, and after allowlisting they are available on ACM's central Thanos for fleet-wide queries and hub alerts.

With ACM, you can alert on the **managed cluster**, on the **hub**, or both:

- **Managed cluster (Phases 1–5)** — alerts fire under that cluster's **Observe > Alerting**.
  - *Pros:* low latency (UWM scrape + local `for`); per-cluster ownership and routing
  - *Cons:* you must install and maintain a `PrometheusRule` on every cluster that runs Kiali
- **Hub (Phase 6 Thanos Ruler)** — alerts fire in ACM Observability (Grafana / Alertmanager on the hub).
  - *Pros:* one place for fleet-wide rules; see health across managed clusters
  - *Cons:* extra delay from ACM metric collection (often about five minutes) before the hub can evaluate

---

## Prerequisites

- A supported OpenShift version with cluster monitoring (`openshift-monitoring`)
- Kiali installed with access to mesh namespaces
- A mesh with workloads Kiali can score (Bookinfo or another demo app helps for the trigger steps in Phase 5)
- `oc` CLI and kubeconfig contexts matching the other MultiCluster tutorials:
  - `ossm-kiali-spoke` — cluster where Kiali runs (Phases 1–5)
  - `ossm-kiali-hub` — ACM hub (Phase 6 and the optional routing section)

Optional (Phase 6 only):

- ACM Observability (`MultiClusterObservability`) ready on the hub

Set namespace variables for the cluster that runs Kiali:

- `KIALI_NS` — namespace of the Kiali server (Service / Deployment). Put the ServiceMonitor here too.
- `KIALI_CR_NS` — namespace of the Kiali CR. Often the same as `KIALI_NS`.

If unsure, run `oc --context=ossm-kiali-spoke get kiali -A` to discover where the Kiali CR is and what its `spec.deployment.namespace` setting is.

```bash
export KIALI_NS=istio-system
export KIALI_CR_NS=istio-system
```

{{% alert color="info" %}}
Examples in this guide assume the default instance name `kiali`. If your Kiali CR sets `spec.deployment.instance_name` to something else, the operator names Kiali-related resources based on that value (not `kiali`). Substitute your instance name wherever this guide refers to the Service, ServiceMonitor `serverName`, and related TLS secret names. Your Kiali CR name may also differ from `kiali` — list CRs with `oc get kiali -A` and use that name in `oc patch` / `oc wait`.
{{% /alert %}}

---

## Phase 1: Enable User Workload Monitoring

{{% alert color="info" %}}
**Already have UWM enabled?** If you completed the hub/spoke guide or already have User Workload Monitoring running, step 1.1 will confirm it. Skip ahead to [Phase 2](#phase-2-enable-kiali-health-status-metrics).
{{% /alert %}}

Enable UWM on each cluster where Kiali runs. UWM's Prometheus scrapes targets selected by user-namespace `ServiceMonitor` / `PodMonitor` resources (including Kiali's metrics endpoint) and evaluates user `PrometheusRule` objects. You do not need UWM on an ACM hub unless Kiali also runs there.

### 1.1 Check whether UWM is enabled

```bash
oc --context=ossm-kiali-spoke get configmap cluster-monitoring-config \
  -n openshift-monitoring \
  -o jsonpath='{.data.config\.yaml}' 2>/dev/null | \
  grep -q "enableUserWorkload: true" && \
  echo "Already enabled" || echo "Not enabled"
```

### 1.2 Enable UWM

If not enabled, ensure `enableUserWorkload: true` is set under `data.config.yaml` in `cluster-monitoring-config`. Do **not** replace the whole ConfigMap if it already has other settings — merge this key into the existing `config.yaml`.

If the ConfigMap does not exist yet:

```bash
oc --context=ossm-kiali-spoke create configmap cluster-monitoring-config \
  -n openshift-monitoring \
  --from-literal=config.yaml="enableUserWorkload: true"
```

If it already exists, patch it to add the flag without removing other keys:

```bash
oc --context=ossm-kiali-spoke get configmap cluster-monitoring-config \
  -n openshift-monitoring -o json \
  | jq '.data["config.yaml"] as $cfg
        | if ($cfg | test("enableUserWorkload:\\s*true"))
          then .
          else .data["config.yaml"] = ($cfg + "\nenableUserWorkload: true\n")
          end' \
  | oc --context=ossm-kiali-spoke apply -f -
```

### 1.3 Wait for UWM Prometheus

Wait for the user-workload Prometheus to become ready:

```bash
until oc --context=ossm-kiali-spoke get pods \
  -l app.kubernetes.io/name=prometheus \
  -n openshift-user-workload-monitoring \
  --no-headers 2>/dev/null | grep -q .; do
  echo "Waiting for UWM Prometheus pods..."
  sleep 5
done

oc --context=ossm-kiali-spoke wait pod \
  --for=condition=Ready \
  -l app.kubernetes.io/name=prometheus \
  -n openshift-user-workload-monitoring \
  --timeout=300s
```

### 1.4 Verify UWM

Confirm User Workload Monitoring is enabled and its Prometheus pods are Ready:

```bash
oc --context=ossm-kiali-spoke get configmap cluster-monitoring-config \
  -n openshift-monitoring \
  -o jsonpath='{.data.config\.yaml}'
echo

oc --context=ossm-kiali-spoke get pods \
  -l app.kubernetes.io/name=prometheus \
  -n openshift-user-workload-monitoring
```

You should see `enableUserWorkload: true` and at least one Ready Prometheus pod in `openshift-user-workload-monitoring`.

---

## Phase 2: Enable Kiali health-status metrics

Export of `kiali_health_status` is controlled by `server.observability.metrics.health_status.enabled` (default: `false`). The health cache that feeds the gauge is on by default; you only need to change it if you previously disabled it via `kiali_internal.health_cache.enabled: false`.

On OpenShift, both flags are required: `server.observability.metrics.enabled: true` makes the Kiali installer (operator or server Helm chart) expose the metrics Service port (`tcp-metrics`) and pod scrape annotations, and `server.observability.metrics.health_status.enabled: true` activates the health gauge on that endpoint.

### 2.1 Patch the Kiali CR

Patch the Kiali CR (merge with your existing `spec`):

```bash
oc --context=ossm-kiali-spoke patch kiali kiali -n "${KIALI_CR_NS}" --type=merge -p '
spec:
  server:
    observability:
      metrics:
        enabled: true
        health_status:
          enabled: true
'
```

### 2.2 Wait for reconciliation

```bash
oc --context=ossm-kiali-spoke wait kiali kiali \
  -n "${KIALI_CR_NS}" \
  --for=condition=Successful \
  --timeout=300s
```

### 2.3 Verify health-status metrics are enabled

Confirm the CR settings and that the Service exposes the metrics port:

```bash
oc --context=ossm-kiali-spoke get kiali kiali -n "${KIALI_CR_NS}" \
  -o jsonpath='{.spec.server.observability.metrics}' ; echo

oc --context=ossm-kiali-spoke get svc kiali -n "${KIALI_NS}" \
  -o jsonpath='{range .spec.ports[*]}{.name}{" "}{.port}{"\n"}{end}'
```

You should see `metrics.enabled` and `health_status.enabled` both true, and a `tcp-metrics` (or `http-metrics`) port on `9090`.

{{% alert color="info" %}}
**`kiali_health_status` semantics:** Each time series represents one mesh entity with these labels:

- **`cluster`** — cluster name as known to Kiali
- **`health_type`** — `app`, `service`, `workload`, or `namespace`
- **`namespace`** — entity namespace
- **`name`** — entity name (for `health_type="namespace"`, this is the namespace name)

Gauge values are `0`–`3` as listed in [Overview](#overview). `NA` is not written as a gauge value — after `max_consecutive_na` consecutive refresh cycles (default: `3`) when an entity is unavailable or missing, its series is removed from scrapes.
{{% /alert %}}

---

## Phase 3: Scrape Kiali with a ServiceMonitor

Create a `ServiceMonitor` in the Kiali server namespace so User Workload Monitoring scrapes Kiali's HTTPS metrics endpoint (`tcp-metrics` / port `9090`) and ingests `kiali_health_status` into UWM Prometheus. Without this scrape, the gauge stays local to Kiali and never appears under **Observe** or in alert evaluation.

UWM sets `arbitraryFSAccessThroughSMs.deny: true`, so the `ServiceMonitor` **must not** use `tlsConfig.caFile` (that path works for platform Prometheus in some docs, but UWM rejects it). Instead, reference the OpenShift service CA ConfigMap that the Kiali installation already creates in the Kiali namespace. The ConfigMap is named `<instance-name>-cabundle-openshift` (default instance name is `kiali`, so the default ConfigMap name is `kiali-cabundle-openshift`). OpenShift automatically injects `service-ca.crt` into that ConfigMap via `service.beta.openshift.io/inject-cabundle`.

### 3.1 Confirm the CA ConfigMap

Confirm the CA ConfigMap has the injected cert before creating the ServiceMonitor that references it. It is normally already present after install; wait if OpenShift has not filled it yet:

```bash
until oc --context=ossm-kiali-spoke get configmap kiali-cabundle-openshift \
  -n "${KIALI_NS}" \
  -o jsonpath='{.data.service-ca\.crt}' 2>/dev/null | grep -q .; do
  echo "Waiting for service-ca.crt in kiali-cabundle-openshift..."
  sleep 2
done
echo "CA bundle ready"
```

### 3.2 Apply the ServiceMonitor

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: kiali
  namespace: ${KIALI_NS}
spec:
  endpoints:
  - interval: 30s
    port: tcp-metrics
    scheme: https
    tlsConfig:
      ca:
        configMap:
          key: service-ca.crt
          name: kiali-cabundle-openshift
      serverName: kiali.${KIALI_NS}.svc
  namespaceSelector:
    matchNames:
    - ${KIALI_NS}
  selector:
    matchLabels:
      app.kubernetes.io/name: kiali
EOF
```

{{% alert color="info" %}}
**Port name:** On OpenShift with service-serving certificates, the metrics port is named `tcp-metrics`. If your Service uses a different name, adjust `spec.endpoints[].port`.
{{% /alert %}}

{{% alert color="warning" %}}
**UWM namespace label rewrite:** User Workload Monitoring overwrites the Prometheus `namespace` label with the namespace of the `ServiceMonitor` / `PrometheusRule` (usually `istio-system`). Kiali's original mesh namespace is preserved as **`exported_namespace`**. Use `exported_namespace` in PromQL, recording rules, and alert annotations — do not try to put the mesh namespace back into `namespace` (UWM will overwrite it again on rule results).
{{% /alert %}}

### 3.3 Verify the scrape

Kiali's health cache refreshes every 3 minutes by default. After the first refresh cycle completes and a UWM scrape picks it up (another 30 seconds), `kiali_health_status` series will appear. Allow up to 5 minutes after applying the ServiceMonitor before checking.

In the OpenShift console, go to **Observe > Metrics** and add the query:

```promql
kiali_health_status
```

Or query UWM Prometheus with `oc`:

```bash
PROM_POD=$(oc --context=ossm-kiali-spoke -n openshift-user-workload-monitoring \
  get pods -l app.kubernetes.io/name=prometheus \
  -o jsonpath='{.items[0].metadata.name}')

oc --context=ossm-kiali-spoke -n openshift-user-workload-monitoring \
  exec -c prometheus "${PROM_POD}" -- \
  wget -qO- 'http://localhost:9090/api/v1/query?query=kiali_health_status' | jq .
```

Either way, you should see series with `health_type`, `name`, and `exported_namespace` labels. If the result is empty:

1. Confirm Kiali shows health for the demo namespace in the UI
2. Confirm `metrics.enabled` and `health_status.enabled` are both true
3. Confirm UWM picked up the ServiceMonitor and its scrape target is up (in the Prometheus UI or targets API, look for job `kiali` / scrapePool `serviceMonitor/<namespace>/kiali/0`). If the operator event says the ServiceMonitor was rejected for accessing the filesystem via TLS config, you still have a `caFile` — switch to the ConfigMap `ca` form above.
4. TLS mismatches usually mean a wrong `serverName` (must be `<instance-name>.<namespace>.svc`), a wrong CA ConfigMap name (must match your instance: `<instance-name>-cabundle-openshift`), or a ConfigMap that does not yet have the injected `service-ca.crt` key

---

## Phase 4: Recording rules and starter alerts

Create a `PrometheusRule` in the Kiali server namespace so UWM evaluates recording rules and starter alerts on `kiali_health_status`. Those alerts surface under **Observe > Alerting**; the Kiali installer (operator or Helm chart) does not install this rule for you.

### 4.1 Aggregate across replicas

If you run Kiali with more than one replica (high availability), each pod exports its own `kiali_health_status` series for the same mesh entity (they differ by `instance` / `pod`). Alerting on the raw gauge would either duplicate alerts or depend on which replica you happened to scrape.

Aggregate with `max by (...)` so each logical entity appears once and the **worst** health wins (Failure `3` beats Degraded `2`, and so on). That pattern stays correct for a single replica too.

On OpenShift UWM, keep the mesh namespace as **`exported_namespace`**:

```promql
max by (cluster, exported_namespace, health_type, name) (kiali_health_status)
```

Always keep `cluster` in the aggregation set in multi-cluster environments.

### 4.2 Apply the starter PrometheusRule

Apply this `PrometheusRule` in **`${KIALI_NS}`** — the same namespace as the ServiceMonitor.

UWM only lets a rule query metrics whose Prometheus `namespace` label matches the rule's own namespace. After Phase 3, that label on `kiali_health_status` is the ServiceMonitor namespace (`${KIALI_NS}`), not the mesh namespace (`exported_namespace`). Put the rule anywhere else and the expressions see no series.

Also set the label `openshift.io/prometheus-rule-evaluation-scope: leaf-prometheus` so UWM's Prometheus evaluates the rules locally (faster than Thanos Ruler for user-workload alerts).

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kiali-health-status
  namespace: ${KIALI_NS}
  labels:
    openshift.io/prometheus-rule-evaluation-scope: leaf-prometheus
spec:
  groups:
  - name: kiali.health.recording
    rules:
    - record: kiali:health_status:max
      expr: |
        max by (cluster, exported_namespace, health_type, name) (kiali_health_status)
    - record: kiali:health_status:namespace_max
      expr: |
        max by (cluster, exported_namespace, name) (
          kiali_health_status{health_type="namespace"}
        )
  - name: kiali.health.alerts
    rules:
    - alert: KialiHealthFailure
      expr: |
        kiali:health_status:max{health_type=~"app|service|workload"} == 3
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: >-
          {{ \$labels.health_type }} {{ \$labels.name }} in {{ \$labels.exported_namespace }}
          (cluster {{ \$labels.cluster }}) is in Failure
        description: >-
          Kiali reported Failure (kiali_health_status == 3) for at least 5 minutes.
    - alert: KialiHealthDegraded
      expr: |
        kiali:health_status:max{health_type=~"app|service|workload"} == 2
      for: 10m
      labels:
        severity: warning
      annotations:
        summary: >-
          {{ \$labels.health_type }} {{ \$labels.name }} in {{ \$labels.exported_namespace }}
          (cluster {{ \$labels.cluster }}) is Degraded
        description: >-
          Kiali reported Degraded (kiali_health_status == 2) for at least 10 minutes.
    - alert: KialiNamespaceHealthFailure
      expr: |
        kiali:health_status:namespace_max == 3
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: >-
          Namespace {{ \$labels.exported_namespace }} (cluster {{ \$labels.cluster }})
          is in Failure
        description: >-
          Kiali namespace aggregate health status is Failure (kiali_health_status == 3)
          for at least 5 minutes.
EOF
```

{{% alert color="info" %}}
**Shell note:** The summaries use `\$labels...` so your shell does not expand `$labels` before `oc apply`. Prometheus still receives normal `{{ $labels... }}` templates. If you put the same YAML in a file and apply with `oc apply -f`, use `$labels` without the backslash.
{{% /alert %}}

That manifest creates two rule groups:

- **`kiali.health.recording`** — recording rules `kiali:health_status:max` and `kiali:health_status:namespace_max` (per-entity aggregates used by the alerts below)
- **`kiali.health.alerts`** — three starter alerts:
  - **`KialiHealthFailure`** — fires when an app, service, or workload has Failure health status (`== 3`), severity `critical`, `for: 5m`
  - **`KialiHealthDegraded`** — fires when an app, service, or workload has Degraded health status (`== 2`), severity `warning`, `for: 10m`
  - **`KialiNamespaceHealthFailure`** — fires when a namespace aggregate has Failure health status (`== 3`), severity `critical`, `for: 5m`

**Not Ready (`== 1`) is omitted** from these starters. It is often transient during rollouts; add a custom alert if you need it (see [Phase 5](#phase-5-custom-alerts-and-a-hands-on-trigger-demo)).

{{% alert color="info" %}}
**What UWM does to your rule:** The user-workload Prometheus operator rewrites `PrometheusRule` objects for multi-tenancy. It adds a `namespace="<rule-namespace>"` matcher on the input series and a forced `namespace` label on the output. That is why this rule must live in `${KIALI_NS}` with the ServiceMonitor. Labels you keep in `max by (...)` that are **not** `namespace` (such as `exported_namespace`) are preserved — that is why this guide aggregates by `exported_namespace`.
{{% /alert %}}

### 4.3 Verify the rules

Confirm the `PrometheusRule` is present, then check that the recording rule produces series (console **Observe > Metrics**, or `oc`):

```promql
kiali:health_status:max
```

```bash
oc --context=ossm-kiali-spoke get prometheusrule kiali-health-status -n "${KIALI_NS}"

PROM_POD=$(oc --context=ossm-kiali-spoke -n openshift-user-workload-monitoring \
  get pods -l app.kubernetes.io/name=prometheus \
  -o jsonpath='{.items[0].metadata.name}')

oc --context=ossm-kiali-spoke -n openshift-user-workload-monitoring \
  exec -c prometheus "${PROM_POD}" -- \
  wget -qO- 'http://localhost:9090/api/v1/query?query=kiali:health_status:max' | jq .
```

You should see aggregated series with `cluster`, `exported_namespace`, `health_type`, and `name`. Alerts stay pending until health is Degraded/Failure long enough to satisfy `for` (see Phase 5 to trigger one).

---

## Phase 5: Custom alerts and a hands-on trigger demo

Customize the Phase 4 rules (or add more) for your namespaces and severities, then optionally run a short demo that forces Failure health so you can see `KialiHealthFailure` under **Observe > Alerting**.

### 5.1 Add custom alerts (optional)

1. Edit the `kiali-health-status` `PrometheusRule` (or create a new one in `${KIALI_NS}` with the same `leaf-prometheus` label).
2. Add another `- alert:` entry under `kiali.health.alerts` (or a new group).
3. `oc apply` the manifest.

Useful knobs:

- **Filter by label** — e.g. `exported_namespace="bookinfo"`, `name="reviews"`, `cluster="spoke"` (under UWM, mesh namespace is `exported_namespace`)
- **`for`** — how long the alert expression must stay true before the alert **fires**. While it is true but that duration has not elapsed, the alert is only **pending**. If the expression becomes false before `for` completes, the pending alert is cleared and the clock resets. Longer `for` values ignore brief blips; shorter values (as in the demo below) surface problems faster.
- **`severity`** — a label on the alert (`critical`, `warning`, or `info`). The OpenShift console uses it to filter and prioritize alerts under **Observe > Alerting** (for example, show only critical). It does not change when the alert fires; that is controlled by `expr` and `for`.

Alert expressions operate on the **gauge value** (`0`–`3`), not on raw HTTP error percentages. To change when Kiali marks Degraded/Failure, adjust [`health_config.rate`]({{< relref "../../Configuration/health" >}}) tolerances; to change when OpenShift pages you, adjust the alert `expr` / `for`.

Copy-paste examples below apply a **separate** `PrometheusRule` so you do not have to hand-edit the Phase 4 manifest. Both examples use the same resource name (`kiali-health-status-custom`), so the second replaces the first — use different names if you want to keep both. Use `\$labels` in the heredoc (same shell note as Phase 4).

**Example — Failure only in `bookinfo`:**

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kiali-health-status-custom
  namespace: ${KIALI_NS}
  labels:
    openshift.io/prometheus-rule-evaluation-scope: leaf-prometheus
spec:
  groups:
  - name: kiali.health.custom
    rules:
    - alert: KialiBookinfoHealthFailure
      expr: |
        kiali:health_status:max{
          health_type=~"app|service|workload",
          exported_namespace="bookinfo"
        } == 3
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "Bookinfo {{ \$labels.health_type }} {{ \$labels.name }} is in Failure"
EOF
```

**Example — sustained Not Ready for workloads:**

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kiali-health-status-custom
  namespace: ${KIALI_NS}
  labels:
    openshift.io/prometheus-rule-evaluation-scope: leaf-prometheus
spec:
  groups:
  - name: kiali.health.custom
    rules:
    - alert: KialiWorkloadNotReady
      expr: |
        kiali:health_status:max{health_type="workload"} == 1
      for: 15m
      labels:
        severity: warning
      annotations:
        summary: "Workload {{ \$labels.name }} in {{ \$labels.exported_namespace }} is Not Ready"
EOF
```

The following steps force a Failure, shorten `for` on `KialiHealthFailure` so you are not waiting five minutes, show the alert in the OpenShift console, then clean up.

### 5.2 Confirm baseline

- Starter `PrometheusRule` from Phase 4 is applied
- A demo namespace with traffic exists (examples use `bookinfo`)
- `kiali_health_status` returns series (Phase 3)

### 5.3 Shorten the Failure alert for the demo

Phase 4 sets `for: 5m` on `KialiHealthFailure`, so the Failure expression must hold for five minutes before the alert leaves **pending** state and fires. For the demo, temporarily set `for: 1m` (looks up the rule by name so group order does not matter):

```bash
oc --context=ossm-kiali-spoke get prometheusrule kiali-health-status -n "${KIALI_NS}" -o json \
  | jq 'del(.status)
        | (.spec.groups[] | select(.name == "kiali.health.alerts").rules[]
           | select(.alert == "KialiHealthFailure").for) = "1m"' \
  | oc --context=ossm-kiali-spoke apply -f -
```

Production recommendations remain `for: 5m` (Failure) and `for: 10m` (Degraded).

### 5.4 Force Failure health

Tighten traffic-health tolerances for the demo namespace so even a small 5xx rate becomes Failure, then generate errors.

**Warning:** The patch below replaces `spec.health_config` on the Kiali CR (including any existing `rate` list). Back up first, then wait for reconciliation:

```bash
oc --context=ossm-kiali-spoke get kiali kiali -n "${KIALI_CR_NS}" -o json \
  | jq '.spec.health_config // {}' > /tmp/kiali-health-config-backup.json

oc --context=ossm-kiali-spoke patch kiali kiali -n "${KIALI_CR_NS}" --type=merge -p '
spec:
  health_config:
    compute:
      duration: 10m
    rate:
    - namespace: "bookinfo"
      kind: ".*"
      name: ".*"
      tolerance:
      - code: "^5\\d\\d$"
        direction: ".*"
        protocol: "http"
        degraded: 0
        failure: 1
'

oc --context=ossm-kiali-spoke wait kiali kiali \
  -n "${KIALI_CR_NS}" \
  --for=condition=Successful \
  --timeout=300s
```

{{% alert color="info" %}}
**Threshold semantics:** In `health_config.rate` tolerances, a `failure` value of `0` with a `degraded` value of `0` does not trigger Failure — instead, matching traffic is marked Degraded. Use `failure: 1` as the lowest effective Failure threshold (triggers Failure for any 5xx error rate at or above 1%). See [Traffic Health]({{< relref "../../Configuration/health" >}}) for the full priority table.
{{% /alert %}}

{{% alert color="info" %}}
**`compute.duration` and hub Thanos:** If Kiali queries metrics from ACM's hub Thanos (as configured in the hub/spoke tutorial), the default `compute.duration: 5m` may not produce meaningful `rate()` results because ACM collects metrics every 5 minutes — leaving only one data point in the window. Setting `duration: 10m` ensures at least two data points, the same reason the Perses dashboards in the dashboards/tracing tutorial use `[10m]` rate windows. Single-cluster setups with local Prometheus can use the default `5m`.
{{% /alert %}}

Inject abort faults on Bookinfo `ratings` (or another service you care about):

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
apiVersion: networking.istio.io/v1
kind: VirtualService
metadata:
  name: kiali-health-alert-demo
  namespace: bookinfo
spec:
  hosts:
  - ratings
  http:
  - fault:
      abort:
        httpStatus: 500
        percentage:
          value: 100
    route:
    - destination:
        host: ratings
EOF
```

Send traffic through the productpage > reviews > ratings path. Only some Bookinfo reviews versions call ratings, so not every request produces a ratings 5xx — that is enough for the demo.

If you already have a traffic generator running (such as the `traffic-gen` deployment from the hub/spoke tutorial), it is already driving requests through this path — skip the command below. Otherwise, generate traffic from inside the cluster:

```bash
oc --context=ossm-kiali-spoke -n bookinfo exec deploy/ratings-v1 -c ratings -- \
  sh -c 'for i in $(seq 1 60); do curl -s -o /dev/null -w "%{http_code}\n" http://productpage:9080/productpage; sleep 2; done'
```

Kiali's health cache defaults to a **3m** refresh and a **5m** traffic window. After generating errors, wait for a refresh (or watch the Kiali UI) until the ratings (or related) entity shows **Failure**, then confirm:

```promql
kiali:health_status:max{exported_namespace="bookinfo", health_type=~"app|service|workload"} == 3
```

returns series in **Observe > Metrics**. Because step 5.3 set `for: 1m` on the alert rule, the Failure condition must stay true for one full minute before `KialiHealthFailure` fires (until then it stays pending).

### 5.5 View the alert in the OpenShift console

1. Log in to the OpenShift web console with a user that can view alerting (kubeadmin or a monitoring-capable role).
2. Go to **Observe > Alerting > Alerts**.
3. Filter or search for `KialiHealthFailure`. With the zero-tolerance `health_config` from step 5.4, any 5xx traffic goes straight to Failure — `KialiHealthDegraded` should not appear for the affected entities.
4. Open the alert and confirm `exported_namespace` (mesh namespace), `name`, `health_type`, `cluster`, and the annotation summary. The Prometheus `namespace` label will be the rule namespace (for example `istio-system`).

You can also confirm under **Observe > Metrics** with:

```promql
ALERTS{alertname=~"KialiHealthFailure|KialiHealthDegraded"}
```

### 5.6 Cleanup the demo

```bash
oc --context=ossm-kiali-spoke delete virtualservice kiali-health-alert-demo \
  -n bookinfo --ignore-not-found

# Restore health_config from the backup taken in 5.4 (empty {} removes the demo override
# when you had no prior health_config; otherwise your previous settings return).
oc --context=ossm-kiali-spoke patch kiali kiali -n "${KIALI_CR_NS}" --type=merge -p \
  "{\"spec\":{\"health_config\":$(cat /tmp/kiali-health-config-backup.json)}}"

oc --context=ossm-kiali-spoke wait kiali kiali \
  -n "${KIALI_CR_NS}" \
  --for=condition=Successful \
  --timeout=300s

# Restore production "for" on KialiHealthFailure
oc --context=ossm-kiali-spoke get prometheusrule kiali-health-status -n "${KIALI_NS}" -o json \
  | jq 'del(.status)
        | (.spec.groups[] | select(.name == "kiali.health.alerts").rules[]
           | select(.alert == "KialiHealthFailure").for) = "5m"' \
  | oc --context=ossm-kiali-spoke apply -f -
```

If you had no `health_config` before the demo, the restore above leaves an empty `health_config: {}` on the CR. To remove that field entirely instead:

```bash
oc --context=ossm-kiali-spoke patch kiali kiali -n "${KIALI_CR_NS}" --type=json -p='[
  {"op": "remove", "path": "/spec/health_config"}
]'
```

Wait until Kiali health returns to Healthy/Degraded as appropriate and `KialiHealthFailure` clears in **Observe > Alerting**.

Single-cluster readers can stop here. Multi-cluster readers who want hub Thanos queries and/or hub alerts can continue to [Phase 6](#phase-6-multi-cluster-with-acm-observability).

---

## Phase 6: Multi-cluster with ACM Observability

Complete Phases 1–3 on **each managed cluster** that should export `kiali_health_status` (UWM, metric export, ServiceMonitor). Phases 4–5 are optional if you only want hub alerts and do not need per-cluster **Observe > Alerting**.

ACM Observability does **not** forward every series from UWM. Phase 6 on the **hub**:

1. Adds `kiali_health_status` to ACM's custom metrics allowlist (same mechanism as Istio metrics in the hub/spoke tutorial) so collectors push the gauge to hub Thanos
2. Adds ACM Thanos Ruler alert rules so the hub can fire fleet-wide alerts on that gauge

If you already applied Phase 4 on the managed clusters, you can keep those local alerts, replace them with hub-only rules, or run both — see the trade-offs in [Overview](#overview). Hub evaluation waits for ACM's collection interval (often about five minutes) before new samples are visible to Thanos Ruler.

### 6.1 Add `kiali_health_status` to the allowlist

On the **hub**, add `kiali_health_status` to the existing `observability-metrics-custom-allowlist` ConfigMap (or create it if it does not exist). If you followed the hub/spoke tutorial, the ConfigMap already has Istio metric names — the command below appends `kiali_health_status` only if it is not already listed:

```bash
oc --context=ossm-kiali-hub -n open-cluster-management-observability \
  get configmap observability-metrics-custom-allowlist -o json \
  | jq '.data["uwl_metrics_list.yaml"] as $cfg
        | if ($cfg | test("kiali_health_status"))
          then .
          else .data["uwl_metrics_list.yaml"] = ($cfg + "    - kiali_health_status\n")
          end' \
  | oc --context=ossm-kiali-hub apply -f -
```

If the ConfigMap does not exist yet, create it first with whatever metrics your environment needs (see the [hub/spoke tutorial]({{< relref "./ossm-acm-hub-spoke" >}}) for the full Istio metrics list), then re-run the command above to append `kiali_health_status`.

ACM distributes the allowlist to managed clusters. Collectors then push matching series to hub Thanos (default interval is about five minutes — expect that latency before hub queries show data).

### 6.2 Verify on the hub

After applying the allowlist, wait at least **10 minutes** for ACM to distribute it to managed clusters and for two collection cycles to complete (each cycle is about 5 minutes). Then query hub Thanos the same way as the [hub/spoke guide]({{< relref "./ossm-acm-hub-spoke" >}}) — by proxying to the ACM `observability-thanos-query-frontend` service on the hub:

```bash
oc --context=ossm-kiali-hub -n open-cluster-management-observability \
  get --raw \
  "/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/api/v1/query?query=kiali_health_status" \
  | jq .
```

Confirm series appear and include cluster identity labels so you can filter by managed cluster. Recording rules from Phase 4 (`kiali:health_status:max` and friends) stay on each cluster's UWM Prometheus — they are not pushed to the hub unless you also allowlist those metric names. The hub alerts below therefore use inline `max by (...)` on the raw gauge.

### 6.3 Apply hub alert rules

Create ACM Thanos Ruler custom rules on the **hub**. ACM loads the ConfigMap named `thanos-ruler-custom-rules` in `open-cluster-management-observability` (data key must be `custom_rules.yaml`). These alerts parallel the Phase 4 starters but use distinct names so you can tell hub alerts from managed-cluster alerts:

```bash
oc --context=ossm-kiali-hub apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: thanos-ruler-custom-rules
  namespace: open-cluster-management-observability
data:
  custom_rules.yaml: |
    groups:
    - name: kiali.health.hub.alerts
      rules:
      - alert: KialiHubHealthFailure
        expr: |
          max by (cluster, exported_namespace, health_type, name) (
            kiali_health_status{health_type=~"app|service|workload"}
          ) == 3
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: >-
            {{ \$labels.health_type }} {{ \$labels.name }} in {{ \$labels.exported_namespace }}
            (cluster {{ \$labels.cluster }}) has Failure health status
          description: >-
            Hub Thanos Ruler: Kiali reported Failure (kiali_health_status == 3)
            for at least 5 minutes.
      - alert: KialiHubHealthDegraded
        expr: |
          max by (cluster, exported_namespace, health_type, name) (
            kiali_health_status{health_type=~"app|service|workload"}
          ) == 2
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: >-
            {{ \$labels.health_type }} {{ \$labels.name }} in {{ \$labels.exported_namespace }}
            (cluster {{ \$labels.cluster }}) has Degraded health status
          description: >-
            Hub Thanos Ruler: Kiali reported Degraded (kiali_health_status == 2)
            for at least 10 minutes.
      - alert: KialiHubNamespaceHealthFailure
        expr: |
          max by (cluster, exported_namespace, name) (
            kiali_health_status{health_type="namespace"}
          ) == 3
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: >-
            Namespace {{ \$labels.exported_namespace }} (cluster {{ \$labels.cluster }})
            has Failure health status
          description: >-
            Hub Thanos Ruler: Kiali namespace aggregate health status is Failure
            (kiali_health_status == 3) for at least 5 minutes.
EOF
```

{{% alert color="info" %}}
**Shell note:** Same as Phase 4 — use `\$labels` in the heredoc so the shell does not expand `$labels` before `oc apply`.
{{% /alert %}}

{{% alert color="warning" %}}
**Do not drop existing hub rules.** If `thanos-ruler-custom-rules` already exists, **merge** the `kiali.health.hub.alerts` group into the existing `custom_rules.yaml` instead of replacing the ConfigMap with a shorter file that only contains the Kiali group.
{{% /alert %}}

That ConfigMap creates one rule group, **`kiali.health.hub.alerts`**, with three starter alerts:

- **`KialiHubHealthFailure`** — app, service, or workload Failure (`== 3`), severity `critical`, `for: 5m`
- **`KialiHubHealthDegraded`** — app, service, or workload Degraded (`== 2`), severity `warning`, `for: 10m`
- **`KialiHubNamespaceHealthFailure`** — namespace aggregate Failure (`== 3`), severity `critical`, `for: 5m`

### 6.4 Verify hub alerts

Confirm the ConfigMap is present:

```bash
oc --context=ossm-kiali-hub -n open-cluster-management-observability \
  get configmap thanos-ruler-custom-rules -o yaml
```

After ACM has collected Failure/Degraded samples and the alert `for` duration has elapsed, check for firing alerts on the **hub** (not the managed cluster's **Observe > Alerting**):

- ACM Observability Grafana Explore — query `ALERTS{alertname=~"KialiHub.*"}`
- Or proxy Thanos the same way as in 6.2:

```bash
oc --context=ossm-kiali-hub -n open-cluster-management-observability \
  get --raw \
  "/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/api/v1/query?query=ALERTS%7Balertname%3D~%22KialiHub.%2A%22%7D" \
  | jq .
```

---

## Routing alerts to Slack, email, or PagerDuty

This section is optional. It shows how to send notifications to a third-party system; you do not need to complete it for the rest of the guide.

- **Hub alerts (Phase 6)** — configure ACM's Alertmanager by overriding the `alertmanager-config` secret in `open-cluster-management-observability` (steps below)
- **Managed-cluster / single-cluster alerts (Phases 1–5)** — configure OpenShift Alertmanager instead (typically the `alertmanager-main` secret in `openshift-monitoring`, or the console under **Observe > Alerting**)

### Extract the ACM Alertmanager config

On the **hub**, back up the current secret contents:

```bash
oc --context=ossm-kiali-hub -n open-cluster-management-observability \
  get secret alertmanager-config \
  -o jsonpath='{.data.alertmanager\.yaml}' | base64 -d > /tmp/alertmanager.yaml

cp /tmp/alertmanager.yaml /tmp/alertmanager.yaml.bak
```

Edit `/tmp/alertmanager.yaml` (or write a new file from one of the examples below) to define `route` and `receivers`. Replace the secret when finished:

```bash
oc --context=ossm-kiali-hub -n open-cluster-management-observability \
  create secret generic alertmanager-config \
  --from-file=alertmanager.yaml=/tmp/alertmanager.yaml \
  --dry-run=client -o yaml \
  | oc --context=ossm-kiali-hub -n open-cluster-management-observability replace -f -
```

ACM reloads Alertmanager from that secret. Keep `/tmp/alertmanager.yaml.bak` so you can restore the previous config the same way.

### Example: Slack

Create an Incoming Webhook in Slack, then use a config like this (substitute your webhook URL and channel). The nested route sends only the Phase 6 `KialiHub*` alerts to Slack:

```yaml
global:
  resolve_timeout: 5m
  slack_api_url: 'https://hooks.slack.com/services/REPLACE/WITH/WEBHOOK'

route:
  group_by: ['alertname', 'cluster']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  receiver: 'default'
  routes:
  - matchers:
    - alertname =~ "KialiHub.*"
    receiver: 'kiali-slack'

receivers:
- name: 'default'
- name: 'kiali-slack'
  slack_configs:
  - channel: '#alerts'
    send_resolved: true
```

### Example: email

```yaml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.example.com:587'
  smtp_from: 'alertmanager@example.com'
  smtp_auth_username: 'alertmanager'
  smtp_auth_password: 'REPLACE_ME'

route:
  group_by: ['alertname', 'cluster']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 3h
  receiver: 'kiali-email'

receivers:
- name: 'kiali-email'
  email_configs:
  - to: 'oncall@example.com'
    send_resolved: true
```

### Example: PagerDuty

```yaml
route:
  group_by: ['alertname', 'cluster']
  receiver: 'kiali-pagerduty'

receivers:
- name: 'kiali-pagerduty'
  pagerduty_configs:
  - routing_key: 'REPLACE_WITH_PAGERDUTY_ROUTING_KEY'
```

You can combine receivers (Slack + email, multiple routes, `matchers` on `severity`, and so on). Alertmanager also supports Go templates in fields such as Slack `title` / `text` if you want richer messages — see [Configuring Alertmanager for external notification systems](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.17/html/observability/observing-environments-intro#configure-obs-alerts) in the Red Hat ACM docs and the upstream [Alertmanager configuration](https://prometheus.io/docs/alerting/latest/configuration/) docs.

---

## Cleanup

Remove the resources this guide created. Re-export `${KIALI_NS}` and `${KIALI_CR_NS}` if you are in a new shell. If you still have leftovers from the Phase 5 trigger demo (fault VirtualService, temporary `health_config`, shortened `for`), run [5.6 Cleanup the demo](#56-cleanup-the-demo) first.

On each cluster where you completed Phases 1–5:

```bash
# PrometheusRules (starter + optional custom rule from Phase 5)
oc --context=ossm-kiali-spoke delete prometheusrule \
  kiali-health-status \
  kiali-health-status-custom \
  -n "${KIALI_NS}" --ignore-not-found

# ServiceMonitor from Phase 3
oc --context=ossm-kiali-spoke delete servicemonitor kiali \
  -n "${KIALI_NS}" --ignore-not-found

# Turn off health-status metric export (leave other observability settings alone)
oc --context=ossm-kiali-spoke patch kiali kiali -n "${KIALI_CR_NS}" --type=merge -p '
spec:
  server:
    observability:
      metrics:
        health_status:
          enabled: false
'

oc --context=ossm-kiali-spoke wait kiali kiali \
  -n "${KIALI_CR_NS}" \
  --for=condition=Successful \
  --timeout=300s
```

Do **not** delete `kiali-cabundle-openshift` — the Kiali operator or Helm chart owns that ConfigMap.

This guide may have enabled User Workload Monitoring via `cluster-monitoring-config`. Leave that ConfigMap in place if you still need UWM (for example after the hub/spoke tutorial). Remove it only if you enabled UWM solely for this guide and want monitoring for user projects turned off:

```bash
# Optional — disables UWM cluster-wide
# oc --context=ossm-kiali-spoke delete configmap cluster-monitoring-config \
#   -n openshift-monitoring --ignore-not-found
```

### Multi-cluster (Phase 6)

If you added `kiali_health_status` to the hub allowlist, remove only that name without affecting other metrics:

```bash
oc --context=ossm-kiali-hub -n open-cluster-management-observability \
  get configmap observability-metrics-custom-allowlist -o json \
  | jq '.data["uwl_metrics_list.yaml"] |= gsub("    - kiali_health_status\n"; "")' \
  | oc --context=ossm-kiali-hub apply -f -
```

If you added hub Thanos Ruler rules, delete the ConfigMap if this guide created it and you have no other custom hub rules:

```bash
oc --context=ossm-kiali-hub -n open-cluster-management-observability \
  delete configmap thanos-ruler-custom-rules --ignore-not-found
```

If `thanos-ruler-custom-rules` has other groups you want to keep, edit the ConfigMap and remove only the `kiali.health.hub.alerts` group from `custom_rules.yaml`, leaving other groups intact:

```bash
oc --context=ossm-kiali-hub -n open-cluster-management-observability \
  edit configmap thanos-ruler-custom-rules
```

If you changed ACM Alertmanager routing in [Routing alerts to Slack, email, or PagerDuty](#routing-alerts-to-slack-email-or-pagerduty), restore from your backup (`/tmp/alertmanager.yaml.bak`) with the same `create secret … | replace` command, or leave the receivers in place if you still want third-party notifications.
