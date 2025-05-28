---
title: "Debugging Kiali"
description: "How to debug Kiali using logs, metrics, traces, and profiler."
---

## Logs

The most basic way of debugging the internals of Kiali is to examine its log messages. A typical way of examining the log messages is via:
```
kubectl logs -n istio-system deployment/kiali
```
Each log message is logged at a specific level. The different log levels are `trace`, `debug`, `info`, `warn`, `error`, and `fatal`. By default, log messages at `info` level and higher will be logged. If you want to see more verbose logs, set the log level to `debug` or `trace` (`trace` is the most verbose setting and will make the log output very "noisy"). You set the log level in the Kiali CR:

```yaml
spec:
  deployment:
    logger:
      log_level: debug
```

By default, Kiali will log messages in a basic text format. You can have Kiali log messages in JSON format, which can sometimes make reading, querying, and filtering the logs easier:

```yaml
spec:
  deployment:
    logger:
      log_format: json
```

### Filtering logs

You may want to pinpoint specific log messages in the Kiali logs. The following are different commands and expressions you can use in order to filter the logs to help expose messages you are most interested in. There are two sets of commands/expressions documented below: one using `grep` and `sed` if Kiali is logging its messages in simple text format, and the other using [`jq`](https://jqlang.org/) if Kiali is logging its messages in JSON format. (Note that `jq` will format each JSON message into multiple lines to read the JSON easier. Pass the `-c` option to `jq` to condense the JSON into one line per log message - it may be harder to read, but will reduce the amount of lines considerably.)

Note that all commands/expressions below should have the Kiali logs piped into its stdin. Usually this means using `kubectl` to get the logs from Kiali and pipe them, like this:

```sh
kubectl logs -n istio-system deployments/kiali | <...commands/expressions here...>
```

#### Remove log levels

If you have enabled the log level of "trace", the Kiali logs will contain a large amount of messages. If you have a hard time sifting through all of those messages, rather than reconfigure Kiali with a different log level you can simply filter out the trace messages.

| | |
|-|-|
| text: | `grep -v ' TRC '` |
| json: | `jq -R 'fromjson? \| select(.level != "trace")'` |

<br/>If you want to remove both "trace" and "debug" level messages (leaving "info" and higher priority messages):

| | |
|-|-|
| text: | `grep -vE ' (TRC\|DBG) '` |
| json: | `jq -R 'fromjson? \| select(.level != "trace" and .level != "debug")'` |

<br/>

#### Show logs for only a single request

Some log messages are associated with a single, specific request. You can obtain all the logs associated with any specific request given a request ID. To determine which request ID you want to use as a filter, you first find all the request IDs in the logs:

| | |
|-|-|
| text: | `grep -o 'request-id=[^ ]*' \| sed 's/^request-id=//' \| sort -u` |
| json: | `jq -rR 'fromjson? \| select(has("request-id")) \| ."request-id"'` |

<br/>Pick a request ID, and use it to retrieve all the logs associated with that request:

| | |
|-|-|
| text: | `grep 'request-id=abc123'` |
| json: | `jq -rR 'fromjson? \| select(."request-id" == "abc123")'` |

<br/>But just having a list of every request ID is likely not enough. You most likely want to look at the logs for requests for a specific Kiali API (like the graph generation API). To see all the different routes into the Kiali API server that were requested, you can get their route names like this:

| | |
|-|-|
| text: | `grep -o 'route=[^ ]*' \| sed 's/^route=//' \| sort -u` |
| json: | `jq -rR 'fromjson? \| select(.route) \| .route' \| sort -u` |

<br/>The `GraphNamespaces` route is an important one - it is the API that is used to generate the main Kiali graphs. If you want to see all the IDs for all requests to this API, you can do this:

| | |
|-|-|
| text: | `grep 'route=GraphNamespaces' \| grep -o 'request-id=[^ ]*' \| sed 's/^request-id=//' \| sort -u` |
| json: | `jq -rR 'fromjson? \| select(.route == "GraphNamespaces") \| .["request-id"]' \| sort -u` |

<br/>Now you can take one of those request IDs and obtain logs for it (as explained earlier) to see all the logs for that request to generate a graph.

Some routes that may be of interest are:

* `AggregateMetrics`: aggregate metrics for a given resource
* `AppMetrics`, `ServiceMetrics`, `WorkloadMetrics`: gets metrics for a given resource
* `AppSpans`, `ServiceSpans`, `WorkloadSpans`: gets tracing spans for a given resource
* `AppTraces`, `ServiceTraces`, `WorkloadTraces`: gets traces for a given resource
* `Authenticate`: authenticates users
* `ClustersHealth`: gets the health data for all resources in a namespace within a single cluster
* `ConfigValidationSummary`: gets the validation summary for all resources in given namespaces
* `ControlPlaneMetrics`: gets metrics for a single control plane
* `GraphAggregate`: generates a node detail graph
* `GraphNamespaces`: generates a namespaces graph
* `IstioConfigDetails`: gets the content of an Istio configuration resource
* `IstioConfigList`: gets the list of Istio configuration resources in a namespace
* `MeshGraph`: generates a mesh graph
* `NamespaceList`: gets the list of available namespaces
* `NamespaceMetrics`: gets metrics for a single namespace
* `NamespaceValidationSummary`: gets the validation summary for all resources in a given namespace
* `TracesDetails`: gets detailed information on a specific trace

#### Show logs of processing times

Kiali collects metrics of its internal systems to track its performance (see the next section, "Metrics"). Many of these metrics use a timer to measure the duration of time that Kiali takes to process some unit of work (for example, the time it takes to generate a graph). Kiali will log these duration times as well as export them to Prometheus. To see what metric timers Kiali is tracking internally, you can do this:

| | |
|-|-|
| text: | `grep -o 'timer=[^ ]*' \| sed 's/^timer=//' \| sort -u` |
| json: | `jq -rR 'fromjson? \| select(.timer) \| .timer' \| sort -u` |

<br/>Note that Kiali will not log times that are under 3 seconds since those are deemed uninteresting and logging them will make the logs "noisy". Prometheus will still collect those metrics, so they are still being recorded.

One timer is especially useful - the timer named "GraphGenerationTime". You can query the log for all the graph generation times like this:

| | |
|-|-|
| text: | `grep 'timer=GraphGenerationTime'` |
| json: | `jq -R 'fromjson? \| select(.timer == "GraphGenerationTime")'` |

<br/>Each log message contains a `duration` attribute - this is the amount of time it took to generate the graph (or parts of the graph). Look at the additional attributes for details on what the timer measured.

Some timers that may be of interest are:
* `APIProcessingTime`: The time it takes to process an API request in its entirety
* `GraphGenerationTime`: The time it takes to generate a full graph
* `GraphAppenderTime`: The time it takes for an appender to decorate a graph
* `PrometheusProcessingTime`:  The time it takes to run Prometheus queries
* `TracingProcessingTime`: The time it takes to run Tracing queries
* `ValidationProcessingTime`: The time it takes to validate a set of Istio configuration resources
* `SingleValidationProcessingTime`: The time it takes to validate an Istio configuration resource
* `CheckerProcessingTime`: The time it takes to run a specific validation checker

## Metrics

Kiali has a [metrics endpoint that can be enabled](/docs/configuration/kialis.kiali.io/#.spec.server.observability.metrics.enabled), allowing Prometheus to collect Kiali metrics. You can then use Prometheus (or Kiali itself) to examine and analyze these metrics.

To see the metrics that are currently being emitted by Kiali, you can run the following command which simply parses the metrics endpoint data and outputs all the metrics it finds:

```sh
curl -s http://<KIALI_HOSTNAME>:9090/metrics | grep -o '^# HELP kiali_.*' | awk '{print $3}'
```

The Kiali UI itself graphs some of these metrics. In the Kiali UI, navigate to the _Kiali_ workload and select the "Kiali Internal Metrics" tab:

![Kiali metrics](/images/documentation/configuration/kiali_own_metrics.png)

Use the Kiali UI to analyze these metrics in the same way that you would analyze your application metrics. (Note that "Tracing processing duration" will be empty if you have not [integrated your Tracing backend with Kiali](/docs/configuration/p8s-jaeger-grafana/tracing/)).

Because these are metrics collected by Promtheus, you can analyze Kiali's metrics through Prometheus queries and the Prometheus UI. Some of the more interesting Prometheus queries are listed below.

* API routes
  * Average latency per API route: `rate(kiali_api_processing_duration_seconds_sum[5m]) / rate(kiali_api_processing_duration_seconds_count[5m])`
  * Request rate per API route: `rate(kiali_api_processing_duration_seconds_count[5m])`
  * 95th percentile latency per API route: `histogram_quantile(0.95, rate(kiali_api_processing_duration_seconds_bucket[5m]))`
  * Alert: 95th Percentile Latency > 5s: `histogram_quantile(0.95, rate(kiali_api_processing_duration_seconds_bucket[5m])) > 5s`
  * Top 5 slowest API routes (avg latency over 5m): `topk(5, rate(kiali_api_processing_duration_seconds_sum[5m]) / rate(kiali_api_processing_duration_seconds_count[5m]))`
* Graph
  * Use the same queries as "API routes" but with the metric `kiali_graph_generation_duration_seconds_[count,sum,bucket]` to get information about the graph generator.
  * Use the same queries as "API routes" but with the metric `kiali_graph_appender_duration_seconds_[count,sum,bucket]` to get information about the graph generator appenders. This helps analyze the performance of the individual appenders that are used to build and decorate the graphs.
* Tracing
  * Use the same queries as "API routes" but with the metric `kiali_tracing_processing_duration_seconds_[count,sum,bucket]` to get information about the groups of different Tracing queries. This helps analyze the performance of the Kiali/Tracing integration.
* Metrics
  * Use the same queries as "API routes" but with the metric `kiali_prometheus_processing_duration_seconds_[count,sum,bucket]` to get information about the different groups of Prometheus queries. This help analyze the performance of the Kiali/Prometheus integration.
* Validations
  * Use the same queries as "API routes" but with the metric `kiali_validation_processing_duration_seconds_[count,sum,bucket]` to get information about Istio configuration validation. This helps analyze the performance of Istio configuration validation as a whole.
  * Use the same queries as "API routes" but with the metric `kiali_checker_processing_duration_seconds_[count,sum,bucket]` to get information about the different validation checkers. This helps analyze the performance of the individual checkers performed during the Istio configuration validation.
* Failures
  * Failures per API route (in the past hour): `sum by (route) (rate(kiali_api_failures_total[1h]))`
  * Error rate percentage per API route: `100 * sum by (route) (rate(kiali_api_failures_total[1h])) / sum by (route) (rate(kiali_api_processing_duration_seconds_count[1h]))`
  * The number of failures per API route in the past 30 minutes: `increase(kiali_api_failures_total[30m])`
  * The top 5 API routes with failures in the past 30 minutes `topk(5, increase(kiali_api_failures_total[30m]))`
<br/>

## Tracing

Kiali provides the ability to emit debugging traces to the [distributed tracing](/docs/configuration/p8s-jaeger-grafana/tracing) platform, Jaeger or Grafana Tempo.

{{% alert color="warning" %}}
From Kiali 1.79, the feature of Kiali emitting tracing data into Jaeger format **has been removed**.
{{% /alert %}}

The traces can be sent in HTTP, HTTPS or gRPC protocol. It is also possible to use TLS. When _tls_enabled_ is set to true, one of the options _skip_verify_ or _ca_name_ should be specified.

The traces are sent in OTel format, indicated in the _collector_type_ setting.

```yaml
server:
  observability:
    tracing:
      collector_url: "jaeger-collector.istio-system:4317"
      enabled: true
      otel:
        protocol: "grpc"
        tls_enabled: true
        skip_verify: false
        ca_name: "/tls.crt"
```

Usually, the tracing platforms expose different ports to collect traces in distinct formats and protocols:
* The Jaeger collector accepts OpenTelemetry Protocol over HTTP (4318) and gRPC (4317).
* The Grafana Tempo distributor accepts OpenTelemetry Protocol over HTTP (4318) and gRPC (4317). It can be configured to accept TLS.

The traces emitted by Kiali can be searched in the _Kiali_ workload:

![Kiali traces](/images/documentation/configuration/kiali_own_traces.png)

## Profiler

The Kial Server is integrated with the Go pprof profiler. By default, the integration is disabled. If you want the Kiali Server to generate profile reports, enable it in the Kiali CR:

```yaml
spec:
  server:
    profiler:
      enabled: true
```

Once the profiler is enabled, you can access the profile reports by pointing your browser to the `<kiali-root-url>/debug/pprof` endpoint and click the link to the profile report you want. You can obtain a specific profile report by appending the name of the profile to the URL. For example, if your Kiali Server is found at the root URL of "http://localhost:20001/kiali", and you want the heap profile report, the URL `http://localhost:20001/kiali/debug/pprof/heap` will provide the data for that report.

Go provides a pprof tool that you can then use to visualize the profile report. This allows you to analyze the data to help find potential problems in the Kiali Server itself. For example, you can start the pprof UI on port 8080 which allows you to see the profile data in your browser:

```
go tool pprof -http :8080 http://localhost:20001/kiali/debug/pprof/heap
```

You can download a profile report and store it as a file for later analysis. For example:

```
curl -o pprof.txt http://localhost:20001/kiali/debug/pprof/heap
```

You can then examine the data found in the profile report:

```
go tool pprof -http :8080 ./pprof.txt
```

Your browser will be opened to `http://localhost:8080/ui` which allows you to see the profile report.

## Kiali CR Status

When you install the Kiali Server via the Kiali Operator, you do so by creating a Kiali CR. One quick way to debug the status of a Kiali Server installation is to look at the Kiali CR's `status` field (e.g. `kubectl get kiali --all-namespaces -o jsonpath='{..status}'`). The operator will report any installation errors within this Kiali CR status. If the Kiali Server fails to install, always check the Kiali CR status field first because in many instances you will find an error message there that can provide clear guidance on what to do next.
