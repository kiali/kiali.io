---
title: Detail Views
description: Kiali provides list and detail views for your mesh components.
---

Kiali provides filtered list views of all your service mesh definitions. Each view provides health, details, YAML definitions and links to help you visualize your mesh. There are list and detail views for:

* Applications
* Istio Configuration
* Services
* Workloads

![Detail list apps](/images/documentation/features/detail-list-app.png)
![Detail list service](/images/documentation/features/detail-list-service.png)
![Detail list workload](/images/documentation/features/detail-list-workload.png)
![Detail list Istio config](/images/documentation/features/detail-list-config.png)

Selecting an object from the list will bring you to its detail page.  For Istio Config, Kiali will present its YAML, along with contextual validation information. Other mesh components present a variety of Tabs.

## Overview Tab

Overview is the default Tab for any detail page.  The overview tab provides detailed information, including health status, and a detailed mini-graph of the current traffic involving the component.  The full set of tabs, as well as the detailed information, varies based on the component type.

Each Overview provides:

* links to related components and linked Istio configuration.
* health status.
* validation information.
* an Action menu for actions that can be taken on the component.
  * several [Wizards]({{< relref "wizards" >}}) are available.

And also type-specfic information.  For example:

* Service detail includes Network information.
* Workload detail provides backing Pod information.

![Detail overview app](/images/documentation/features/detail-overview-app.png)
![Detail overview service](/images/documentation/features/detail-overview-service.png)
![Detail overview workload](/images/documentation/features/detail-overview-workload.png)

Both Workload and Service detail can be customized to some extent, by adding additional details supplied as annotations. This is done through the `additional_display_details` field in [the Kiali CR](/docs/configuration/kialis.kiali.io/#.spec.additional_display_details).

![Detail overview additional details](/images/documentation/features/detail-overview-additional-details.png)

## Traffic

The Traffic Tab presents a service, app, or workload's Inbound and Outbound traffic in a table-oriented way:

![Detail traffic](/images/documentation/features/detail-traffic.png)

## Logs

Workload detail offers a special Logs tab.  Kiali offers a special _unified_ logs view that lets users correlate app and proxy logs.  It can also add-in trace span information to help identify important traces based on associated logging. More powerful features include substring or regex Show/Hide, full-screen, and the ability to set proxy log level without a pod restart.

![Detail logs](/images/documentation/features/detail-logs.png)

## Metrics

Each detail view provides _Inbound Metrics_ and/or _Outbound Metrics_ tabs, offering predefined metric dashboards. The dashboards provided are tailored to the relevant application, workload or service level. Application and workload detail views show request and response metrics such as volume, duration, size, or tcp traffic.  The service detail view shows request and response metrics for inbound traffic only.

Kiali allows the user to customize the charts by choosing the charted dimensions.  It can also present metrics reported by either source or destination proxy metrics.  And for troublshooting it can overlay trace spans.

![Detail metric inbound](/images/documentation/features/detail-metrics-in.png)
![Detail metrics outbound](/images/documentation/features/detail-metrics-out.png)

## Traces

Each detail view provides a _Traces_ tab with a native integration with Jaeger.  For more, see [Tracing]({{< relref "./tracing" >}}).


## Dashboards

Kiali will display additional tabs for each applicable [Built-In Dashboard](#built-in-dash) or  [Custom Dashboard](#custom-dash).

### Built-in dashboards {#built-in-dash}

Kiali comes with built-in dashboards for several runtimes, including Envoy, Go, Node.js, and others.

#### Envoy

The most important built-in dashboard is for Envoy.  Kiali offers the _Envoy_ tab for many workloads that run an Istio sidecar, waypoint, or gateway proxy.  The Envoy tab is actually a [Built-In Dashboard](#built-in-dash), but it is very common as it applies to any workload injected with, or that is itself, an Envoy proxy.  Being able to inspect the Envoy proxy is invaluable when troublshooting your mesh.  The Envoy tab itself offers five subtabs, exposing a wealth of information.

![Detail Envoy](/images/documentation/features/detail-envoy.png)

Istio's Envoy sidecars supply [some internal metrics](https://www.envoyproxy.io/docs/envoy/latest/configuration/upstream/cluster_manager/cluster_stats), that can be viewed in Kiali. They are different than the metrics reported by Istio Telemetry, which Kiali uses extensively. Some of Envoy's metrics may be redundant.

Note that the enabled Envoy metrics can be tuned, as explained in the [Istio documentation](https://istio.io/docs/ops/telemetry/envoy-stats/): it's possible to get more metrics using the `statsInclusionPrefixes` annotation. Make sure you include `cluster_manager` and `listener_manager` as they are required for the built-in Envoy dashboard and for [Envoy memory diagnostics](#envoy-memory).

For example, `sidecar.istio.io/statsInclusionPrefixes: cluster_manager,listener_manager,listener` will add `listener` metrics for more inbound traffic information. You can then customize the Envoy dashboard of Kiali according to the collected metrics.

#### Envoy memory diagnostics {#envoy-memory}

For workloads with an Envoy proxy, Kiali evaluates proxy memory and shows a compact **Envoy memory** status when the [required metrics]({{< ref "/docs/faq/general#requiredmetrics" >}}) are present in Prometheus. The status is meant to highlight sidecars, waypoints, or gateways that may be using more memory than expected and whether configuration size or traffic is the more likely driver.

On the workload **Overview** tab, the status sits with the rest of the workload summary:

![Envoy memory on workload Overview](/images/documentation/features/details/envoy_overview.png "Envoy memory summary on the workload Overview tab")

On the overview tab, when Envoy is detected, the Envoy health indicator will be shown in the details card:

![Envoy memory on workload Envoy tab](/images/documentation/features/details/envoy-details-overview.png "Envoy memory status and Envoy Memory dashboard on the workload Envoy tab")

Kiali combines Prometheus Envoy stats with Istio telemetry (and config-dump cluster counts when the admin API is reachable) to show:

- allocated memory, optional limit from the `sidecar.istio.io/proxyMemoryLimit` annotation, and active cluster count;
- traffic signals (HTTP request rate or, for waypoints and some gateways, TCP byte rate);
- a heuristic **cause** when memory is high: `configuration` (many active clusters), `traffic`, `ok`, or `unknown`.

When the cause points to configuration, Kiali links to Istio [configuration scoping](https://istio.io/latest/docs/ops/configuration/mesh/configuration-scoping/), which can reduce proxy memory by limiting the config each Envoy receives.

Thresholds differ by proxy role (sidecar, waypoint, gateway). If required metrics are missing from Prometheus, the Envoy Memory UI may be hidden or incomplete. See [required Envoy metrics]({{< ref "/docs/faq/general#requiredmetrics" >}}) and [metric tuning / federation]({{< ref "/docs/configuration/external-services/metrics/tuning" >}}) when you scrape or federate only a subset of Istio telemetry.


#### Go

Contains metrics such as the number of threads, goroutines, and heap usage. The expected metrics are provided by the [Prometheus Go client](https://prometheus.io/docs/guides/go-application/).

Example to expose built-in Go metrics:

```go
        http.Handle("/metrics", promhttp.Handler())
        http.ListenAndServe(":2112", nil)
```

As an example and for self-monitoring purpose Kiali itself [exposes Go metrics](https://github.com/kiali/kiali/blob/055b593e52ebf8a0eb00372bca71fbef94230f0f/server/metrics_server.go).

The pod annotation for Kiali is: `kiali.io/dashboards: go`


#### Kiali

Kiali has its own built-in dashboard that helps you observe performance of the Kiali server itself. To view this dashboard, navigate to either the application or workload view of the Kiali server and select the `Kiali Internal Metrics` tab to see Kiali's own internal metrics:

![Kiali Metrics (app view)](/images/documentation/features/kiali-dashboard-app-metrics.png)
![Kiali Metrics (workload view)](/images/documentation/features/kiali-dashboard-workload-metrics.png)

#### Node.js

Contains metrics such as active handles, event loop lag, and heap usage. The expected metrics are provided by [prom-client](https://www.npmjs.com/package/prom-client).

Example of Node.js metrics for Prometheus:

```javascript
const client = require('prom-client');
client.collectDefaultMetrics();
// ...
app.get('/metrics', (request, response) => {
  response.set('Content-Type', client.register.contentType);
  response.send(client.register.metrics());
});
```

Full working example: https://github.com/jotak/bookinfo-runtimes/tree/master/ratings

The pod annotation for Kiali is: `kiali.io/dashboards: nodejs`

#### Quarkus

Contains JVM-related, GC usage metrics. The expected metrics can be provided by [SmallRye Metrics](https://smallrye.io/), a MicroProfile Metrics implementation. Example with maven:

```xml
    <dependency>
      <groupId>io.quarkus</groupId>
      <artifactId>quarkus-smallrye-metrics</artifactId>
    </dependency>
```

The pod annotation for Kiali is: `kiali.io/dashboards: quarkus`

#### Spring Boot

Three dashboards are provided: one for JVM memory / threads, another for JVM buffer pools and the last one for Tomcat metrics. The expected metrics come from
[Spring Boot Actuator for Prometheus](https://docs.spring.io/spring-boot/docs/current/reference/html/actuator.html#actuator.metrics.export.prometheus). Example with maven:

```xml
    <dependency>
      <groupId>org.springframework.boot</groupId>
      <artifactId>spring-boot-starter-actuator</artifactId>
    </dependency>
    <dependency>
      <groupId>io.micrometer</groupId>
      <artifactId>micrometer-core</artifactId>
    </dependency>
    <dependency>
      <groupId>io.micrometer</groupId>
      <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
```

Full working example: https://github.com/jotak/bookinfo-runtimes/tree/master/details

The pod annotation for Kiali with the full list of dashboards is: `kiali.io/dashboards: springboot-jvm,springboot-jvm-pool,springboot-tomcat`

By default, the metrics are exposed on path _/actuator/prometheus_, so it must be specified in the corresponding annotation: `prometheus.io/path: "/actuator/prometheus"`

#### Thorntail

Contains mostly JVM-related metrics such as loaded classes count, memory usage, etc. The expected metrics are provided by the MicroProfile Metrics module. Example with maven:

```xml
    <dependency>
      <groupId>io.thorntail</groupId>
      <artifactId>microprofile-metrics</artifactId>
    </dependency>
```

Full working example: https://github.com/jotak/bookinfo-runtimes/tree/master/productpage

The pod annotation for Kiali is: `kiali.io/dashboards: thorntail`

#### Vert.x

Several dashboards are provided, related to different components in Vert.x: HTTP client/server metrics, Net client/server metrics, Pools usage, Eventbus metrics and JVM. The expected metrics are provided by the
[vertx-micrometer-metrics](https://vertx.io/docs/vertx-micrometer-metrics/java/) module. Example with maven:

```xml
    <dependency>
      <groupId>io.vertx</groupId>
      <artifactId>vertx-micrometer-metrics</artifactId>
    </dependency>
    <dependency>
      <groupId>io.micrometer</groupId>
      <artifactId>micrometer-registry-prometheus</artifactId>
    </dependency>
```

Init example of Vert.x metrics, starting a dedicated server (other options are possible):

```java
      VertxOptions opts = new VertxOptions().setMetricsOptions(new MicrometerMetricsOptions()
          .setPrometheusOptions(new VertxPrometheusOptions()
              .setStartEmbeddedServer(true)
              .setEmbeddedServerOptions(new HttpServerOptions().setPort(9090))
              .setPublishQuantiles(true)
              .setEnabled(true))
          .setEnabled(true));
```

Full working example: https://github.com/jotak/bookinfo-runtimes/tree/master/reviews

The pod annotation for Kiali with the full list of dashboards is: `kiali.io/dashboards: vertx-client,vertx-server,vertx-eventbus,vertx-pool,vertx-jvm`

### Custom Dashboards {#custom-dash}

When the built-in dashboards don't offer what you need, it's possible to create your own.  See [Custom Dashboard Configuration]({{< ref "/docs/configuration/custom-dashboard" >}}) for more information.


