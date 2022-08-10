---
title: "Prometheus"
description: >
  This page describes how to configure Prometheus for Kiali.
---


## Prometheus configuration

Kiali *requires* Prometheus to generate the
[topology graph]({{< relref "../../Features/topology" >}}),
[show metrics]({{< relref "../../Features/details#metrics" >}}),
[calculate health]({{< relref "../../Features/health" >}}) and
for several other features. If Prometheus is missing or Kiali
can't reach it, Kiali won't work properly.

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

See the [Kiali CR reference page]("/docs/configuration/kialis.kiali.io/#example-cr" >}}) for the current default values.

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


### Metric Thinning

Istio and Envoy generate a large amount of telemetry for analysis and troubleshooting.  This can result in significant resources being required to ingest and store the telemetry, and to support queries into the data.  If you use the telemetry specifically to support Kiali, it is possible to drop unnecessary metrics and unnecessary labels on required metrics.  This [FAQ Entry]({{< ref "/docs/faq/general#requiredmetrics" >}}) displays the metrics and attributes required for Kiali to operate.

To reduce the default telemetry to only what is needed by Kiali[^1] users can add the following snippet to their Prometheus configuration. Because things can change with different versions, it is recommended to ensure you use the correct version of this documentation based on your Kiali/Istio version.

[^1]: Some non-essential telemetry remains in order to not over-complicate the configuration change.  The remaining telemetry is typically negligible.

The `metric_relabel_configs:` attribute should be added under each job name defined to scrape Istio or Envoy metrics. Below we show it under the `kubernetes-pods` job, but you should adapt as needed. Be careful of indentation.

```
    - job_name: kubernetes-pods
      metric_relabel_configs:
      - action: drop
        source_labels: [__name__]
        regex: istio_agent_.*|istiod_.*|istio_build|citadel_.*|galley_.*|pilot_.*|envoy_cluster_[^u].*|envoy_cluster_update.*|envoy_listener_[^dh].*|envoy_server_[^mu].*|envoy_wasm_.*
      - action: labeldrop
        regex: chart|destination_app|destination_version|heritage|.*operator.*|istio.*|release|security_istio_io_.*|service_istio_io_.*|sidecar_istio_io_inject|source_app|source_version
```

Applying this configuration should reduce the number of stored metrics by about 20%, as well as reducing the number of attributes stored on many remaining metrics.



### Metric Thinning with Crippling

The section above drops metrics unused by Kiali. As such, making those configuration changes should not negatively impact Kiali behavior in any way. But some very heavy metrics remain. Some, or all of these metrics can also be dropped, but their removal will impact the behavior of Kiali.  This may be OK if you don't use the affected features of Kiali, or if you are willing to sacrifice the feature for the associated metric savings. In particular, these are "Histogram" metrics.  Istio is planning to make some improvements to help users better configure these metrics, but as of this writing they are still defined with fairly inefficient default "buckets", making the number of associated time-series quite large, and the overhead of maintaining and querying the metrics, intensive.  Each histogram actually is comprised of 3 stored metrics.  For example, a histogram named `xxx` would result in the following metrics stored into Prometheus:

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

- Appending `|istio_request_bytes_*` to the `drop` regex above would drop all associated metrics and would prevent any request size/throughput reporting in Kiali.
- Appending `|istio_request_bytes_bucket` to the `drop` regex above, would prevent any request size percentile reporting in the Kiali metric charts.

#### istio_response_bytes

This metric is used to produce the `Response Size` chart on the metric tabs.  And also supports `Response Throughput` edge labels on the graph

- Appending `|istio_response_bytes_*` to the `drop` regex above would drop all associated metrics and would prevent any response size/throughput reporting in Kiali.
- Appending `|istio_response_bytes_bucket` to the `drop` regex above would prevent any response size percentile reporting in the Kiali metric charts.

#### istio_request_duration_milliseconds

This metric is used to produce the `Request Duration` chart on the metric tabs.  It also supports `Response Time` edge labels on the graph.

- Appending `|istio_request_duration_milliseconds_*` to the `drop` regex above would drop all associated metrics and would prevent any request duration/response time reporting in Kiali.
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


