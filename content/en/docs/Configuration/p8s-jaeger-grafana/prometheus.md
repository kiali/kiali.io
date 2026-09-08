---
title: "Prometheus"
description: >
  This page describes how to configure Prometheus for Kiali.
---


## Prometheus configuration

Kiali uses Prometheus to generate the
[topology graph]({{< relref "../../Features/topology" >}}),
[show metrics]({{< relref "../../Features/details#metrics" >}}),
[calculate health]({{< relref "../../Features/health" >}}) and
for several other features. Prometheus is enabled by default and is required
for full Kiali functionality.

### Disabling Prometheus

If you want to run Kiali without a Prometheus instance, you can disable it:

```yaml
spec:
  external_services:
    prometheus:
      enabled: false
```

When Prometheus is disabled, Kiali will still start and serve non-metrics features
such as workload/service/app listing, Istio configuration, and mesh topology.
However, the graph, metrics tabs, traffic tabs, and request-rate health will be
unavailable. Health badges for workloads and apps will degrade to show only
Kubernetes-level status (replica counts).

The UI will display a subtle informational message reminding you that metrics
features are unavailable due to your configuration choice.

### When Prometheus is Unreachable

When Prometheus is enabled (the default) but Kiali cannot reach it at startup,
Kiali will still start successfully with metrics features temporarily unavailable.

The UI will display a warning notification explaining why metrics are
unavailable. The Prometheus component will still appear in the masthead status
and the mesh topology page, reported as unhealthy, so you have clear visibility
into the misconfiguration.

To restore full metrics functionality after a startup failure, fix the Prometheus
connectivity issue (correct the URL, ensure the Prometheus server is running, etc.) and
restart Kiali.

### Configuring the Prometheus URL

By default, Kiali assumes that Prometheus is available at the URL of the form
`http://prometheus.<istio_namespace_name>:9090`, which is the usual case if you
are using [the Prometheus Istio
add-on](https://istio.io/latest/docs/ops/integrations/prometheus/#option-1-quick-start).
If your Prometheus instance has a different service name or is installed in a
different namespace, you must manually provide the endpoint where it is
available, like in the following example:

```yaml
spec:
  external_services:
    prometheus:
      # Prometheus service name is "metrics" and is in the "telemetry" namespace
      url: "http://metrics.telemetry:9090/"
```

{{% alert color="success" %}}
Notice that you don't need to expose Prometheus outside the cluster. It is
enough to provide the Kubernetes internal service URL.
{{% /alert %}}

Kiali maintains an internal cache of some Prometheus queries to improve
performance (mainly, the queries to calculate Health indicators). It
would be very rare to see data delays, but should you notice any delays you may
tune caching parameters to values that work better for your environment.

See the [Kiali CR reference page](/docs/configuration/kialis\.kiali\.io/#example-cr) for the current default values.

### Compatibility with Prometheus-like servers

Although Kiali assumes a Prometheus server and is tested against it, there are
<abbr title="Time series databases">TSDBs</abbr> that can be used as a Prometheus
replacement despite not implementing the full Prometheus API. 

Community users have faced two issues when using Prometheus-like TSDBs:
* Kiali may report that the TSDB is unreachable, and/or
* Kiali may show empty metrics if the TSBD does not implement the `/api/v1/status/config`.

To fix these issues, you may need to provide a custom health check endpoint for
the TSDB and/or manually provide the configurations that Kiali reads from the
`/api/v1/status/config` API endpoint:

```yaml
spec:
  external_services:
    prometheus:
      # Fix the "Unreachable" metrics server warning.
      health_check_url: "http://custom-tsdb-health-check-url"
      # Fix for the empty metrics dashboards
      thanos_proxy:
        enabled: true
        retention_period: "7d"
        scrape_interval: "30s"
```

## Prometheus Tuning

Production environments should not be using the Istio Prometheus add-on, or carrying over its configuration settings.  That is useful only for small, or demo installations.  Instead, Prometheus should have been installed in a production-oriented way, following the [Prometheus documentation](https://prometheus.io/docs/prometheus/latest/installation).

This section is primarily for users where Prometheus is being used specifically for Kiali, and possible optimizations that can be made knowing that Kiali does not utilize all of the default Istio and Envoy telemetry.

Istio and Envoy generate a large amount of telemetry for analysis and troubleshooting.  This can result in significant resources being required to ingest and store the telemetry, and to support queries into the data.  If you use the telemetry specifically to support Kiali, it is possible to drop unnecessary metrics and unnecessary labels on required metrics.  This [FAQ Entry]({{< ref "/docs/faq/general#requiredmetrics" >}}) displays the metrics and attributes required for Kiali to operate.

### Option 1: Recording Rules and Federation (Recommended)

For production meshes at scale, [metric thinning](#option-2-metric-thinning) on a single Prometheus TSDB reduces storage somewhat but still retains per-proxy Istio series. A more efficient approach—aligned with [Istio Observability Best Practices](https://istio.io/latest/docs/ops/best-practices/observability/#federation-using-workload-level-aggregated-metrics)—is to:

1. **Aggregate at the edge** using Prometheus recording rules that "sum away" per-proxy labels (`pod`, `instance`, etc.) into `workload:*` series. "Sum away" is a recording rule term that means that several time-series will be aggregated into one, by combining those with like values for specified fields. The resulting value is the sum of the individual time-series values. Because Kiali presents information at the workload level, not the pod level, aggregation offers a significant reduction in time-series cardinality.
2. **Federate** only those aggregates (plus a small set of control-plane metrics) into your long-retention production Prometheus.
3. **Relabel** `workload:istio_requests_total` back to `istio_requests_total` on the production instance so Kiali queries standard metric names.

Kiali already aggregates traffic at workload/service granularity in its PromQL; it does not use per-pod Istio labels. Pre-aggregated counters and histograms are therefore compatible with the traffic graph, health monitoring, and metrics tabs.

{{% alert color="info" %}}
This pattern uses **two Prometheus roles** (edge and production). They are often in different namespaces or clusters in real deployments. The Kiali repository includes a **demo lab harness** that co-locates both in `istio-system` for learning and CI—it is not a production installer.
{{% /alert %}}

#### Architecture

```
  Edge Prometheus                         Production Prometheus
  (scrapes Istio/Envoy)                   (long retention; Kiali queries here)
        │                                           ▲
        │  recording rules                          │  /federate
        │  istio_*  →  workload:*                   │  + relabel workload: → istio_
        │  short retention                          │
        └───────────────────────────────────────────┘
```

**Edge Prometheus** is whichever instance scrapes Istio mesh telemetry (often *not* the same as your platform monitoring stack). It evaluates recording rules and keeps a **short retention** (for example 6 hours) on raw and aggregated series.

**Production Prometheus** is the TSDB Kiali should query. It federates selected series from the edge, relabels `workload:*` back to `istio_*`, and holds **long retention**. Configure Kiali accordingly:

```yaml
spec:
  external_services:
    prometheus:
      # Production Prometheus URL — not the edge Istio scraper
      url: "http://prometheus-prod.monitoring:9090/"
```

If you use [Kiali Perses dashboards]({{< relref "./perses" >}}), point Perses at the same production Prometheus URL.

{{% alert color="warning" %}}
**Production assumption:** In this pattern, `external_services.prometheus.url` **always** targets production Prometheus—the long-retention TSDB that holds federated mesh metrics. Kiali must **not** query the edge Istio scraper in production. The edge exists only to collect raw telemetry, evaluate recording rules, and federate upstream; it is not Kiali's database.

`kiali_*` self-monitoring metrics must also end up in that production TSDB, but may reach it via edge aggregation and federation or via direct scrape—see [Kiali self-monitoring metrics](#kiali-self-monitoring-metrics).
{{% /alert %}}

#### Metric tiers

Federation configuration is split so operators only pull what they need:

| Tier | Purpose | Required for |
| ---- | ------- | ------------ |
| **Core** | [Kiali required metrics]({{< ref "/docs/faq/general#requiredmetrics" >}}) | Traffic graph, health, lists, mesh overview |
| **Dashboards** | Optional control-plane, perf, ztunnel, and WASM metrics | [Perses Istio dashboards](https://github.com/perses/community-mixins/tree/main/examples/dashboards/perses/istio) |
| **Kiali self-monitoring** | Kiali operational metrics (`kiali_*`) | Kiali Internal Metrics dashboard, optional health-status alerting |
&nbsp;

Mesh, service, and workload Perses dashboards work on the **core** tier alone. Enable the **Dashboards** tier only when using those detailed dashboards. Enable **Kiali self-monitoring** when the built-in Kiali metrics dashboard or `kiali_health_status` alerting is needed.

Reference files live in the Kiali repository under [`hack/istio/metric-rules/`](https://github.com/kiali/kiali/tree/master/hack/istio/metric-rules):

| File | Description |
| ---- | ----------- |
| `recording-rules.yml` | Edge recording rules producing `workload:*` series |
| `kiali-required-metrics.yml` | Canonical core Istio metric list |
| `federation-match-dashboards.yml` | Optional federation `match[]` selectors for Perses dashboards |
| `prometheus-prod.yaml` | Example production federation scrape job (core tier) |
| `kiali-recording-rules.yml` | Edge recording rules for Kiali metrics (`kiali:*` series) |
| `kiali-export-metrics.yml` | Canonical Kiali self-monitoring metric list |
| `federation-match-kiali.yml` | Federation `match[]` selectors for `kiali:*` series |
| `prometheus-kiali-edge.yaml` | Example dedicated Kiali edge Prometheus (Option 2) |
&nbsp;

#### Recording rules (edge Prometheus)

Add rules like the following to the Prometheus instance that scrapes Istio traffic. Rules sum away scrape-level labels while preserving the workload/service labels Kiali uses in queries:

```yaml
groups:
- name: istio.workload-aggregation
  interval: 30s
  rules:
  - record: workload:istio_requests_total
    expr: sum without (pod, instance, namespace, job, node) (istio_requests_total)
  - record: workload:istio_request_duration_milliseconds_bucket
    expr: sum without (pod, instance, namespace, job, node) (istio_request_duration_milliseconds_bucket)
  # ... remaining traffic counters and histogram components — see recording-rules.yml
```

{{% alert color="warning" %}}
Record **counter snapshots**, not `rate()`. Kiali applies `rate()` at query time with user-selected durations. Use `sum without (...)` rather than `sum by (...)` so required labels are not dropped accidentally.
{{% /alert %}}

How you install the rules depends on your platform—for example a `rule_files` entry in `prometheus.yml`, a ConfigMap volume mount, or a Prometheus Operator `PrometheusRule` CR in the namespace where edge Prometheus runs.

#### Federation (production Prometheus)

Add a federation scrape job to your **existing** long-retention Prometheus. Federate `workload:*` traffic metrics from the edge and relabel names before storage:

```yaml
- job_name: istio-mesh-federate
  honor_labels: true
  metrics_path: /federate
  scrape_interval: 30s
  params:
    match[]:
      - '{__name__=~"workload:istio_requests_total"}'
      - '{__name__=~"workload:istio_request_bytes_(bucket|count|sum)"}'
      - '{__name__=~"workload:istio_request_duration_milliseconds_(bucket|count|sum)"}'
      # ... see prometheus-prod.yaml for the full core-tier list
  metric_relabel_configs:
  - source_labels: [__name__]
    regex: 'workload:(.*)'
    target_label: __name__
    action: replace
  static_configs:
  - targets:
    - '<edge-prometheus-host>:9090'
```

Also federate non-traffic metrics that Kiali needs but does not aggregate (for example `istio_build`, `pilot_xds`, `container_cpu_usage_seconds_total`) directly by name—see `kiali-required-metrics.yml` and `prometheus-prod.yaml`.

To include Perses dashboard metrics, append the selectors from `federation-match-dashboards.yml` to `match[]`.

Configure **network access**, **TLS**, and **authentication** between production and edge Prometheus according to your environment. Kiali authentication for the production URL is configured separately (see [Prometheus authentication configuration](#prometheus-authentication-configuration) below).

#### Demo walkthrough (lab only)

The Kiali repository provides a demo script that patches the Istio add-on Prometheus in `istio-system`, deploys a sample `prometheus-prod` federator, and optionally switches Kiali to use it. Use this to learn the pattern or validate in CI—not as a production deployment:

```bash
# From a clone of github.com/kiali/kiali, with Istio add-on Prometheus running:
./hack/istio/metric-rules/install.sh

# Optional: also federate Perses dashboard metrics
./hack/istio/metric-rules/install.sh --with-dashboards

# Optional: federate Kiali self-monitoring (shared Istio edge Prometheus)
./hack/istio/metric-rules/install.sh --with-kiali-metrics

# Optional: federate Kiali self-monitoring (dedicated Kiali edge Prometheus)
./hack/istio/metric-rules/install.sh --with-kiali-metrics --kiali-edge dedicated

# Optional: point Kiali at the demo production Prometheus
./hack/istio/metric-rules/install.sh --switch-kiali

# Combine flags as needed, for example:
./hack/istio/metric-rules/install.sh --with-dashboards --with-kiali-metrics --switch-kiali
```

After install, port-forward and verify:

```bash
# Istio edge Prometheus (recording rules)
kubectl port-forward -n istio-system svc/prometheus 9091:9090

# Demo production Prometheus (federated data; point Kiali here)
kubectl port-forward -n istio-system svc/prometheus-prod 9092:9090

# Dedicated Kiali edge (only with --kiali-edge dedicated)
kubectl port-forward -n istio-system svc/prometheus-kiali-edge 9093:9090

# Edge: workload:* aggregates
curl -s 'http://localhost:9091/api/v1/query?query=count(workload:istio_requests_total)'

# Production: istio_* and kiali_* (no workload: or kiali: prefix)
curl -s 'http://localhost:9092/api/v1/query?query=count(istio_requests_total)'
curl -s 'http://localhost:9092/api/v1/query?query=count({__name__=~"kiali_.*"})'
```

The **Kiali Internal Metrics** dashboard only works when Kiali queries production Prometheus (`--switch-kiali` or `external_services.prometheus.url` → `prometheus-prod`).

See [`hack/istio/metric-rules/README.md`](https://github.com/kiali/kiali/blob/master/hack/istio/metric-rules/README.md) for teardown (`uninstall.sh`).

#### Production checklist

1. Identify **edge Prometheus**—the TSDB that scrapes Istio/Envoy (may be in a `monitoring` namespace, a remote cluster, or a managed service—not necessarily `istio-system`).
2. Install **recording rules** on the edge; set **short retention** on raw mesh telemetry.
3. Add a **federation scrape job** to your existing **production** Prometheus using the core-tier `match[]` list.
4. Optionally extend `match[]` with **dashboard-tier** selectors if Perses Istio dashboards are enabled.
5. If Kiali self-monitoring is enabled, choose an option from [Kiali self-monitoring metrics](#kiali-self-monitoring-metrics): apply `kiali-recording-rules.yml` on the Kiali edge and federate `federation-match-kiali.yml` to production (Options 1–2), or scrape Kiali directly into production (Option 3).
6. Point **`external_services.prometheus.url`** at production Prometheus (and Perses at the same URL).
7. **Validate** equivalence between edge aggregates and federated data (see below).
8. Tune intervals using [Interval tuning](#interval-tuning) below.

For **multi-cluster** deployments, federation is typically per mesh cluster (edge → production for that cluster). Kiali already supports per-cluster Prometheus URLs in multicluster configuration.

#### Interval tuning

Several independent intervals affect freshness, CPU use, and the minimum time windows Kiali can use for `rate()` queries. Set them together—not in isolation.

| Setting | Where configured | Role |
| ------- | ---------------- | ---- |
| **Edge scrape interval** | Edge Prometheus `global.scrape_interval` (or per-job override on Istio/Envoy targets) | How often raw `istio_*` counters are collected from proxies |
| **Recording rule interval** | `interval` on the rule group in `recording-rules.yml` | How often `workload:*` aggregates are recomputed on the edge |
| **Federation scrape interval** | `scrape_interval` on the production federation job | How often production Prometheus pulls `workload:*` (and other federated series) from the edge |
| **Edge retention** | Edge Prometheus `storage.tsdb.retention.time` | How long raw and `workload:*` series are kept before expiry (short, e.g. 6h) |
| **Production retention** | Production Prometheus retention | Long-term history Kiali and dashboards query |

**Rules of thumb**

1. **Recording rule interval ≥ edge scrape interval.** Rules read raw series; evaluating more often than scrapes complete adds CPU without new data. A practical range is **equal to the scrape interval, up to 2× the scrape interval** ([Istio guidance](https://istio.io/latest/docs/ops/best-practices/observability/#federation-using-workload-level-aggregated-metrics)).
2. **Federation interval ≥ recording rule interval.** Production should pull aggregates after the edge has evaluated them. **30s** is a common federation interval and matches the Kiali reference configuration.
3. **Set `scrape_timeout` below `scrape_interval`** on the federation job (for example `25s` timeout with `30s` interval) so slow federation scrapes do not overlap.
4. **Kiali minimum duration** depends on the **effective sampling** of the data it queries (production Prometheus), not the edge scrape interval. With federation, that is roughly **recording rule interval + federation scrape interval**. Kiali needs at least **two samples** in a rate window, so minimum graph duration should be **≥ 2× that effective interval** (see [Scrape Interval](#scrape-interval) below).

##### Recommended settings when edge scrape is 30s

This is a common production default (for example kube-prometheus-stack). The Kiali reference bundle uses these values:

| Setting | Recommended value | Notes |
| ------- | ----------------- | ----- |
| Edge `scrape_interval` | `30s` | Your stated baseline |
| Recording rule `interval` | `30s` | Matches scrape; good balance of freshness and CPU |
| Federation `scrape_interval` | `30s` | Istio-recommended; used in `prometheus-prod.yaml` |
| Federation `scrape_timeout` | `25s` | Slightly less than scrape interval |
| Edge retention | `6h` | Enough for troubleshooting; raw series expire after federation |
| Effective sampling (Kiali) | `~60s` | Rule interval + federation interval |
| Practical minimum Kiali duration | `≥ 2m` (`120s`) | `2 × 60s`; Kiali may round up in the duration dropdown |

Example edge rule group header and production federation job:

```yaml
# Edge Prometheus — recording rules
groups:
- name: istio.workload-aggregation
  interval: 30s          # match 30s scrape_interval
  rules:
  - record: workload:istio_requests_total
    expr: sum without (pod, instance, namespace, job, node) (istio_requests_total)
```

```yaml
# Production Prometheus — federation job
- job_name: istio-mesh-federate
  scrape_interval: 30s
  scrape_timeout: 25s
  metrics_path: /federate
  # ... match[] and relabel configs
```

**Expected freshness:** mesh traffic visible in Kiali on production Prometheus is typically on the order of **one to two minutes** behind live traffic (one scrape + one rule evaluation + one federation cycle, plus alignment jitter).

##### Other edge scrape intervals

| Edge scrape | Recording rules | Federation | Effective sampling | Min duration (2×) |
| ----------- | --------------- | ---------- | ------------------ | ----------------- |
| `15s` (Istio add-on demo) | `15s`–`30s` | `30s` | `45s`–`60s` | `90s`–`120s` |
| `30s` (recommended row above) | `30s` | `30s` | `60s` | `120s` |
| `1m` | `1m` | `1m` | `2m` | `4m` |

For **fresher** aggregates at the cost of more edge CPU, use a recording rule interval **equal to** the scrape interval (for example both `15s`). For **lower** edge CPU, use rule interval **2×** scrape (for example `30s` rules with `15s` scrape, or `60s` rules with `30s` scrape)—accepting additional lag before `workload:*` updates.

Istio’s own examples sometimes use **5s** rule evaluation with **30s** federation for faster edge aggregation; that is reasonable when edge scrape is `15s` and you want sub-minute freshness. It increases rule-evaluation load and is optional—not required for Kiali correctness.

##### Kiali duration dropdown

Today Kiali reads `globalScrapeInterval` from the Prometheus URL in `external_services.prometheus.url` (production) and filters durations with **`≥ 2 × globalScrapeInterval`**. When using federation:

- Ensure production Prometheus **`global.scrape_interval`** (or the value exposed in `/api/v1/status/config`) reflects the **federation job interval** if that is the coarsest sampling Kiali sees, **or**
- Plan for a future **`metric_aggregation_interval`** setting (see the [metric rules KEP](https://github.com/kiali/kiali/blob/master/design/KEPS/metric-rules/proposal.md)) to set the minimum duration floor explicitly to **rule interval + federation interval**.

Until `metric_aggregation_interval` is available, if production `global.scrape_interval` is `1m` but federation runs every `30s`, Kiali may offer durations that are shorter than ideal for federated traffic metrics. Operators can rely on slightly longer graph durations (for example `2m` or `5m`) for rate-based views when in doubt.

#### Kiali self-monitoring metrics

Kiali can export its own Prometheus metrics (`kiali_*`) for performance and optional health-status monitoring. These are **not** Istio mesh metrics—they are not produced on the edge by Envoy, not listed in `kiali-required-metrics.yml`, and not part of the Istio federation tiers.

Because Kiali queries **production** Prometheus, `kiali_*` series must ultimately be available in that same TSDB. The [metric rules KEP](https://github.com/kiali/kiali/blob/master/design/KEPS/metric-rules/proposal.md#kiali-self-monitoring-metrics) describes **three deployment options**:

| Option | Kiali metrics scraped by | Before production |
| ------ | ------------------------ | ----------------- |
| **1. Shared Istio edge** | Same edge Prom as Istio/Envoy | Recording rules + federation (parallel to `workload:*`) |
| **2. Dedicated Kiali edge** | Separate edge Prom for Kiali only | Recording rules + federation to prod |
| **3. Direct to production** | Production Prom directly | Raw scrape; dedup required in queries for HA |

| Config | Default | Purpose |
| ------ | ------- | ------- |
| `server.observability.metrics.enabled` | `true` | Operational metrics (API, graph, cache, validation, etc.) |
| `server.observability.metrics.health_status.enabled` | `false` | `kiali_health_status` gauge per entity (opt-in; higher cardinality) |

The metrics HTTP listener (port `server.observability.metrics.port`, default `9090`) starts when **either** flag is true.

**`kiali_health_status` and HA:** Multiple Kiali replicas export the **same** gauge values for the same entities (duplicate series, not partition-of-work). With Options 1 or 2, use `max without (pod, instance, …)` in recording rules to deduplicate—not `sum`. With Option 3, apply the same dedup in alert/dashboard queries (for example `max by (cluster, namespace, health_type, name) (kiali_health_status)`), because raw scrape retains per-replica copies.

The built-in **Kiali Internal Metrics** custom dashboard queries `external_services.prometheus.url`; it only works when production Prometheus holds the `kiali_*` series (via federation or direct scrape).

Reference files for Options 1–2: `kiali-recording-rules.yml`, `federation-match-kiali.yml`, and (for Option 2) `prometheus-kiali-edge.yaml`. Try them in the [demo walkthrough](#demo-walkthrough-lab-only) with `--with-kiali-metrics` and optionally `--kiali-edge dedicated`.

For `kiali_health_status` alerting on OpenShift, see the [OSSM health status alerts tutorial]({{< relref "../../Tutorials/ossm-multicluster/ossm-health-status-alerts" >}}).

#### Validation

Confirm that federated series match edge aggregates (on production Prometheus, after relabel):

```promql
# Edge Prometheus
sum(rate(workload:istio_requests_total{destination_workload_namespace="bookinfo"}[5m]))

# Production Prometheus
sum(rate(istio_requests_total{destination_workload_namespace="bookinfo"}[5m]))
```

Compare series counts on the edge before federation:

```promql
count({__name__="istio_requests_total"})
count({__name__="workload:istio_requests_total"})
```

The `workload:*` count should be substantially lower when workloads have been associated with multiple pods (replicas or restarts).


### Option 2: Metric Thinning

If the Federation option is not possible and you are limited to a single TSDB intance, this may be helpful.

To reduce the default telemetry to only what is needed by Kiali[^1] users can add the following snippet to their Prometheus configuration. Because things can change with different versions, it is recommended to ensure you use the correct version of this documentation based on your Kiali/Istio version.

[^1]: Some non-essential telemetry remains in order to not over-complicate the configuration change.  The remaining telemetry is typically negligible.

The `metric_relabel_configs:` attribute should be added under each job name defined to scrape Istio or Envoy metrics. Below we show it under the `kubernetes-pods` job, but you should adapt as needed. Be careful of indentation.

```
    - job_name: kubernetes-pods
      metric_relabel_configs:
      - action: drop
        source_labels: [__name__]
        regex: istio_agent_.*|istiod_.*|istio_build|citadel_.*|galley_.*|pilot_[^psx].*|envoy_cluster_[^u].*|envoy_cluster_update.*|envoy_listener_[^dh].*|envoy_server_[^mu].*|envoy_wasm_.*
      - action: labeldrop
        regex: chart|destination_app|destination_version|heritage|.*operator.*|istio.*|release|security_istio_io_.*|service_istio_io_.*|sidecar_istio_io_inject|source_app|source_version
```

Applying this configuration should reduce the number of stored metrics by about 20%, as well as reducing the number of attributes stored on many remaining metrics.



### Metric Thinning with Disabled Features

The section above drops metrics unused by Kiali. As such, making those configuration changes should not negatively impact Kiali behavior in any way. But some very heavy metrics remain. These metrics can also be dropped, but their removal will impact the behavior of Kiali.  This may be OK if you don't use the affected features of Kiali, or if you are willing to sacrifice the feature for the associated metric savings. In particular, these are "Histogram" metrics.  Istio is planning to make some improvements to help users better configure these metrics, but as of this writing they are still defined with fairly inefficient default "buckets", making the number of associated time-series quite large, and the overhead of maintaining and querying the metrics, intensive.  Each histogram actually is comprised of 3 stored metrics.  For example, a histogram named `xxx` would result in the following metrics stored into Prometheus:

- `xxx_bucket`
  - The most intensive metric, and is required to calculate percentile values.
- `xxx_count`
  - Required to calculate 'avg' values.
- `xxx_sum`
  - Required to calculate rates over time, and for 'avg' values.

When considering whether to thin the Histogram metrics, one of the following three approaches is recommended:

1. If the relevant Kiali reporting is needed, keep the histogram as-is.
2. If the relevant Kiali reporting is not needed, or not worth the additional metric overhead, drop the entire histogram.
3. If the metric chart percentiles are not required, drop only the xxx_bucket metric.  This removes the majority of the histogram overhead while keeping rate and average (non-percentile) values in Kiali.


These are the relevant Histogram metrics:

#### istio_request_bytes

This metric is used to produce the `Request Size` chart on the metric tabs.  It also supports `Request Throughput` edge labels on the graph.

- Appending `|istio_request_bytes_.*` to the `drop` regex above would drop all associated metrics and would prevent any request size/throughput reporting in Kiali.
- Appending `|istio_request_bytes_bucket` to the `drop` regex above, would prevent any request size percentile reporting in the Kiali metric charts.

#### istio_response_bytes

This metric is used to produce the `Response Size` chart on the metric tabs.  And also supports `Response Throughput` edge labels on the graph

- Appending `|istio_response_bytes_.*` to the `drop` regex above would drop all associated metrics and would prevent any response size/throughput reporting in Kiali.
- Appending `|istio_response_bytes_bucket` to the `drop` regex above would prevent any response size percentile reporting in the Kiali metric charts.

#### istio_request_duration_milliseconds

This metric is used to produce the `Request Duration` chart on the metric tabs.  It also supports `Response Time` edge labels on the graph.

- Appending `|istio_request_duration_milliseconds_.*` to the `drop` regex above would drop all associated metrics and would prevent any request duration/response time reporting in Kiali.
- Appending `|istio_request_duration_milliseconds_bucket` to the `drop` regex above would prevent any request duration/response time percentile reporting in the Kiali metric charts or graph edge labels.


### Scrape Interval

The Prometheus `globalScrapeInterval` is an important configuration option[^2]. The scrape interval can have a significant effect on metrics collection overhead as it takes effort to pull all of those configured metrics and update the relevant time-series. And although it doesn't affect time-series cardinality, it does affect storage for the data-points, as well as having impact when computing query results (the more data-points, the more processing and aggregation).

[^2]: Note that Prometheus can be configured such that individual scrape points can override the global setting, but Kiali is not currently concerned with this corner case.

Users should think carefully about their configured scrape interval. Note that the Istio addon for prometheus configures it to 15s. This is great for demos but may be too frequent for production scenarios. The prometheus helm charts set a default of 1m, which is more reasonable for most installations, but may not be the desired frequency for any particular setup.

The recommendation for Kiali is to set the longest interval possible, while still providing a useful granularity. The longer the interval the less data points scraped, thus reducing processing, storage, and computational overhead. But the impact on Kiali should be understood. It is important to realize that request rates (or byte rates, message rates, etc) require a minumum of two data points:

`rate = (dp2 - dp1) / timePeriod`

That means for Kiali to show anything useful in the graph, or anywhere rates are used (many places), the minimum duration must be `>= 2 x globalScrapeInterval`. Kiali will [eliminate invalid Duration options]({{< ref "/docs/faq/graph#scrapeduration" >}}) given the globalScrapeInterval.

Kiali does a lot of aggregation and querying over time periods. As such, the number of data points will affect query performance, especially for larger time periods.

For more information, see the [Prometheus documentation](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration).


### TSDB retention time

The Prometheus `tsdbRetentionTime` is an important configuration option. It has a significant effect on metrics storage, as Prometheus will keep each reported data-point for that period of time, performing compaction as needed. The larger the retention time, the larger the required storage.  Note also that Kiali queries against large time periods, and very large data-sets, may result in poor performance or timeouts.

The recommendation for Kiali is to set the shortest retention time that meets your needs and/or operational limits.  In some cases users may want to offload older data to a secondary store.  Kiali will [eliminate invalid Duration options]({{< ref "/docs/faq/graph#scrapeduration" >}}) given the tsdbRetentionTime.

For more information, see the [Prometheus documentation](https://prometheus.io/docs/prometheus/latest/storage/#operational-aspects).

### Prometheus authentication configuration

The Kiali CR provides authentication configuration that will be used also for querying the version check to provide information in the Mesh graph.

```yaml
spec:
  external_services:
    prometheus:
      auth:
        insecure_skip_verify: false
        password: "pwd"
        token: ""
        type: "basic"
        use_kiali_token: false
        username: "user"
      health_check_url: ""
```

To configure a secret to be used as a password, see this [FAQ entry]({{< relref "../../FAQ/installation#how-can-i-use-a-secret-to-pass-external-service-credentials-to-the-kiali-server" >}}).

To authenticate using OAuth2 `client_credentials` flow (for example, Azure Monitor Managed Prometheus or any OAuth2-protected endpoint), set `type: "oauth2"` and provide the `oauth2` block:

```yaml
spec:
  external_services:
    prometheus:
      auth:
        type: "oauth2"
        oauth2:
          client_id: "my-client-id"
          client_secret: "secret:my-oauth2-secret:client_secret"
          token_url: "https://login.microsoftonline.com/<tenant>/oauth2/v2.0/token"
          scopes:
          - "https://prometheus.monitor.azure.com/.default"
          audience: ""          # optional: some providers require this
          auth_style: "header"  # "header" (default) or "params"
```

The `client_secret` field supports the `secret:<secretName>:<secretKey>` pattern for automatic secret mounting and rotation without pod restart. See the [FAQ entry]({{< relref "../../FAQ/installation#how-can-i-use-a-secret-to-pass-external-service-credentials-to-the-kiali-server" >}}) for details.

{{% alert color="warning" %}}
`insecure_skip_verify` applies only to the Prometheus connection, not to the OAuth2 token endpoint. The token endpoint always validates TLS certificates. To trust a private CA for the token endpoint, add the CA to the `kiali-cabundle` ConfigMap as described in the [TLS Configuration]({{< relref "./tls-configuration" >}}) page.
{{% /alert %}}

### TLS Certificate Configuration

If your Prometheus server uses HTTPS with a certificate issued by a private CA, see the [TLS Configuration]({{< relref "./tls-configuration" >}}) page to learn how to configure Kiali to trust your CA.