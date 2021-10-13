---
title: Detail Views
description: Kiali provides list and detail views for your mesh components.
weight: 3
---

Kiali provides filtered list views of all your service mesh definitions. Each view provides health, details, YAML definitions and links to help you visualize your mesh. There are list and detail views for:

* Applications
* Istio Configuration
* Services
* Workloads

![Detail list apps](/images/documentation/features/detail-list-app.png)
![Detail list workload](/images/documentation/features/detail-list-service.png)
![Detail list workload](/images/documentation/features/detail-list-workload.png)
![Detail list workload](/images/documentation/features/detail-list-config.png)

</br>

Selecting an object from the list will bring you to its detail page.  For Istio Config, Kiali will present its YAML, along with contextual validation information. Other mesh components present a variety of Tabs.

## Overview Tab

Overview is the default Tab for any detail page.  The overview tab provides detailed information, including health status, and a detailed mini-graph of the current traffic involving the component.  The full set of tabs, as well as the detailed information, varies based on the component type.

Each Overview provides:

* links to related components and linked Istio configuration.
* health status.
* validation information.
* an Action menu for actions that can be taken on the component.
  * several [Wizards](#wizards) are available.

And also type-specfic information.  For example:

* Service detail includes Network information.
* Workload detail provides backing Pod information.

![Detail list workload](/images/documentation/features/detail-overview-app.png)
![Detail list workload](/images/documentation/features/detail-overview-service.png)
![Detail list workload](/images/documentation/features/detail-overview-workload.png)

</br>

Both Workload and Service detail can be customized to some extent, by adding additional details supplied as annotations. This is done through the `additional_display_details` field in [the Kiali CR](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml).

 <a class="image-popup-fit-height" href="/images/documentation/features/additional-details-v1.28.0.png" title="Additional details">
  <img src="/images/documentation/features/additional-details-v1.28.0.png" style="display:block;margin: 0 auto;" />
 </a>

## Traffic

The traffic tab collects all connections from and to a specific Application, Workload and/or Service.

It groups them in Inbound and Outbound tables providing traffic details and links to specific detailed metrics.

 <a class="image-popup-fit-height" href="/images/documentation/features/traffic-v1.22.0.png" title="Traffic tab">
  <img src="/images/documentation/features/traffic-thumb-v1.22.0.png" style="display:block;margin: 0 auto;" />
 </a>

## Logs

The Workload detail offer a special Logs tab. Kiali allows side-by-side viewing of both the application and the proxy logs of a selected pod.

The logs tab adds additional filtering capabilities to show or hide specific lines.

 <a class="image-popup-fit-height" href="/images/documentation/features/logs-v1.22.0.png" title="Logs tab">
  <img src="/images/documentation/features/logs-thumb-v1.22.0.png" style="display:block;margin: 0 auto;" />
 </a>

## Metrics Dashboards

Each detail view provides predefined metric dashboards. The metric dashboards provided are tailored to the relevant application, workload or service level.

Application and workload detail views show request and response metrics such as volume, duration, size, or tcp traffic. The traffic can also be viewed for either inbound or outbound traffic.

The service detail view shows request and response metrics for inbound traffic.

<div style="display: flex;">
    <span style="margin: 0 auto;">
      <a class="image-popup-fit-height" href="/images/documentation/features/metrics-inbound-v1.22.0.png" title="Inbound Metrics">
          <img src="/images/documentation/features/metrics-inbound-thumb-v1.22.0.png" style="width: 660px; display:inline;margin: 0 auto;" />
      </a>
      <a class="image-popup-fit-height" href="/images/documentation/features/metrics-outbound-v1.22.0.png" title="Outbound Metrics">
          <img src="/images/documentation/features/metrics-outbound-thumb-v1.22.0.png" style="width: 660px; display:inline;margin: 0 auto;" />
      </a>
    </span>
</div>

## Custom Dashboards

Kiali comes with built-in dashboards for several runtimes, including Go, Envoy, Node.js, and others.

You can create custom dashboards for your own applications by defining them within the Kiali CR field `spec.custom_dashboards`.

<div style="display: flex;">
    <span style="margin: 0 auto;">
      <a class="image-popup-fit-height" href="/images/documentation/features/metrics-dashboards-jvm-v1.22.0.png" title="Custom JVM Metrics">
          <img src="/images/documentation/features/metrics-dashboards-jvm-thumb-v1.22.0.png" style="width: 660px; display:inline;margin: 0 auto;" />
      </a>
      <a class="image-popup-fit-height" href="/images/documentation/features/metrics-dashboards-vertx-v1.22.0.png" title="Custom Vertx Metrics">
          <img src="/images/documentation/features/metrics-dashboards-vertx-thumb-v1.22.0.png" style="width: 660px; display:inline;margin: 0 auto;" />
      </a>
    </span>
</div>

### Prometheus Configuration

Kiali custom dashboards work exclusively with Prometheus, so it must be configured correctly to pull your application metrics.

If you are using the demo Istio installation with addons, your Prometheus instance should already be correctly configured and you can skip to the next section; with the exception of Istio 1.6.x where
[you need customize the ConfigMap, or install Istio with the flag](https://github.com/istio/istio/issues/24075#issuecomment-635281531) `--set meshConfig.enablePrometheusMerge=true`.

#### Using another Prometheus instance

You can use a different instance of Prometheus for these metrics, as opposed to Istio metrics. This second Prometheus instance can be configured from the _Kiali CR_ when using the Kiali operator, or _ConfigMap_ otherwise:

```yaml
# ...
external_services:
  custom_dashboards:
    prometheus:
      url: URL_TO_PROMETHEUS_SERVER_FOR_CUSTOM_DASHBOARDS
    namespace_label: kubernetes_namespace
  prometheus:
    url: URL_TO_PROMETHEUS_SERVER_FOR_ISTIO_METRICS
# ...
```

For more details on this configuration, such as Prometheus authentication options, [check this page](https://github.com/kiali/kiali-operator/blob/76242369299c35db350119516c6db6fd87f47822/deploy/kiali/kiali_cr.yaml#L452-L470).

You must make sure that this Prometheus instance is correctly configured to scrape your application pods and generates labels that Kiali will understand. Please refer to
[this documentation](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#kubernetes_sd_config) to setup the `kubernetes_sd_config` section. As a reference,
[here is](https://github.com/istio/istio/blob/907aa731c3f76ad21faac98614751e8ab3531893/install/kubernetes/helm/istio/charts/prometheus/templates/configmap.yaml#L229) how it is configured in Istio.

It is important to preserve label mapping, so that Kiali can filter by _app_ and _version_, and to have the same namespace label as defined per Kiali config. Here's a `relabel_configs` that allows this:

```yaml
      relabel_configs:
      - action: labelmap
        regex: __meta_kubernetes_pod_label_(.+)
      - source_labels: [__meta_kubernetes_namespace]
        action: replace
        target_label: kubernetes_namespace
```

### Pods Annotations and Auto-discovery {#pods-annotations}

Application pods must be annotated for the Prometheus scraper, for example, within a _Deployment_ definition:

```yaml
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "8080"
        prometheus.io/path: "/metrics"
```

* _prometheus.io/scrape_ tells Prometheus to fetch these metrics or not
* _prometheus.io/port_ is the port under which metrics are exposed
* _prometheus.io/path_ is the endpoint path where metrics are exposed, default is /metrics

Kiali will try to discover automatically dashboards that are relevant for a given Application or Workload. To do so, it reads their metrics and try to match them with the `discoverOn` field defined on dashboards.

But if you can't rely on automatic discovery, you can explicitly annotate the pods to associate them with Kiali dashboards.

```yaml
spec:
  template:
    metadata:
      annotations:
        # (prometheus annotations...)
        kiali.io/dashboards: vertx-server
```

_kiali.io/dashboards_ is a comma-separated list of dashboard names that Kiali will look for. Each name in the list must match the name of a built-in dashboard or the name of a custom dashboard as defined in the Kial CR's `spec.custom_dashboards`.

### Built-in dashboards

Kiali comes with a set of built-in dashboards for various runtimes.

#### Go

Contains metrics such as the number of threads, goroutines, and heap usage. The expected metrics are provided by the [Prometheus Go client](https://prometheus.io/docs/guides/go-application/).

Example to expose built-in Go metrics:

```go
        http.Handle("/metrics", promhttp.Handler())
        http.ListenAndServe(":2112", nil)
```

As an example and for self-monitoring purpose Kiali itself [exposes Go metrics](https://github.com/kiali/kiali/blob/055b593e52ebf8a0eb00372bca71fbef94230f0f/server/metrics_server.go).

The pod annotation for Kiali is: `kiali.io/dashboards: go`

#### Envoy

Istio's Envoy sidecars supply [some internal metrics](https://www.envoyproxy.io/docs/envoy/latest/configuration/upstream/cluster_manager/cluster_stats), that can be viewed in Kiali. They are different than the metrics reported by Istio Telemetry, which Kiali uses extensively. Some of Envoy's metrics may be redundant.

Unlike the other custom dashboards, there is no automatic discovery configured for Envoy. You must explicitly enable the Envoy dashboard with the pod annotation `kiali.io/dashboards: envoy`.

Note that the enabled Envoy metrics can be tuned, as explained in the [Istio documentation](https://istio.io/docs/ops/telemetry/envoy-stats/): it's possible to get more metrics using the `statsInclusionPrefixes` annotation. Make sure you include `cluster_manager` and `listener_manager` as they are required.

For example, `sidecar.istio.io/statsInclusionPrefixes: cluster_manager,listener_manager,listener` will add `listener` metrics for more inbound traffic information. You can then customize the Envoy dashboard of Kiali according to the collected metrics.

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

### Create new dashboards

The built-in dashboards described above are just some of what you can have. It's pretty easy to create new ones.

When installing Kiali, you define your own custom dashboards in the Kiali CR `spec.custom_dashboards` field. Here's an example of what it looks like:

```yaml
custom_dashboards:
- name: vertx-custom
  title: Vert.x Metrics
  runtime: Vert.x
  discoverOn: "vertx_http_server_connections"
  items:
  - chart:
      name: "Server response time"
      unit: "seconds"
      spans: 6
      metrics:
      - metricName: "vertx_http_server_responseTime_seconds"
        displayName: "Server response time"
      dataType: "histogram"
      aggregations:
      - label: "path"
        displayName: "Path"
      - label: "method"
        displayName: "Method"
  - chart:
      name: "Server active connections"
      unit: ""
      spans: 6
      metricName: "vertx_http_server_connections"
      dataType: "raw"
  - include: "micrometer-1.1-jvm"
  externalLinks:
  - name: "My custom Grafana dashboard"
    type: "grafana"
    variables:
      app: var-app
      namespace: var-namespace
      version: var-version
```

The *name* field corresponds to what you can set in the pod annotation #pods-annotations[`kiali.io/dashboards`].

The rest of the field definitions are:

* *runtime*: optional, name of the related runtime. It will be displayed on the corresponding Workload Details page. If omitted no name is displayed.
* *title*: dashboard title, displayed as a tab in Application or Workloads Details
* *discoverOn*: metric name to match for auto-discovery. If omitted, the dashboard won't be discovered automatically, but can still be used via pods annotation.
* *items*: a list of items, that can be either *chart*, to define a new chart, or *include* to reference another dashboard
  * *chart*: new chart object
    * *name*: name of the chart
    * *chartType*: type of the chart, can be one of _line_ (default), _area_, _bar_ or _scatter_
    * *unit*: unit for Y-axis. Free-text field to provide any unit suffix. It can eventually be scaled on display. See [specific section below](#units).
    * *unitScale*: in case the unit needs to be scaled by some factor, set that factor here. For instance, if your data is in milliseconds, set `0.001` as scale and `seconds` as unit.
    * *spans*: number of "spans" taken by the chart, from 1 to 12, using [bootstrap convention](https://www.w3schools.com/bootstrap4/bootstrap_grid_system.asp)
    * *metrics*: a list of metrics to display on this single chart:
      * *metricName*: the metric name in Prometheus
      * *displayName*: name to display on chart
    * *dataType*: type of data to be displayed in the chart. Can be one of _raw_, _rate_ or _histogram_. Raw data will be queried without transformation. Rate data will be queried using
[_promQL rate() function_](https://prometheus.io/docs/prometheus/latest/querying/functions/#rate). And histogram with [_histogram_quantile() function_](https://prometheus.io/docs/prometheus/latest/querying/functions/#histogram_quantile).
    * *min* and *max*: domain for Y-values. When unset, charts implementations should usually automatically adapt the domain with the displayed data.
    * *xAxis*: type of the X-axis, can be one of _time_ (default) or _series_. When set to _series_, only one datapoint per series will be displayed, and the chart type then defaults to _bar_.
    * *aggregator*: defines how the time-series are aggregated when several are returned for a given metric and label set. For example, if a Deployment creates a ReplicaSet of several Pods, you will have at least one time-series per Pod. Since Kiali shows the dashboards at the workload (ReplicaSet) level or at the application level, they will have to be aggregated. This field can be used to fix the aggregator, with values such as _sum_ or _avg_ (full list available [in Prometheus documentation](https://prometheus.io/docs/prometheus/latest/querying/operators/#aggregation-operators)). However, if omitted the aggregator will default to _sum_ and can be changed from the dashboard UI.
    * *aggregations*: list of labels eligible for aggregations / groupings (they will be displayed in Kiali through a dropdown list)
      * *label*: Prometheus label name
      * *displayName*: name to display in Kiali
      * *singleSelection*: boolean flag to switch between single-selection and multi-selection modes on the values of this label. Defaults to _false_.
    * *groupLabels*: a list of Prometheus labels to be used for grouping. Similar to *aggregations*, except this grouping will be always turned on.
    * *sortLabel*: Prometheus label to be used for the metrics display order.
    * *sortLabelParseAs*: set to _int_ if *sortLabel* needs to be parsed and compared as an integer instead of string.
  * *include*: to include another dashboard, or a specific chart from another dashboard. Typically used to compose with generic dashboards such as the ones about _MicroProfile Metrics_ or _Micrometer_-based JVM metrics. To reference a full dashboard, set the name of that dashboard. To reference a specific chart of another dashboard, set the name of the dashboard followed by `$` and the name of the chart (ex: `include: "microprofile-1.1$Thread count"`).
* *externalLinks*: a list of related external links (e.g. to Grafana dashboards)
  * *name*: name of the related dashboard in the external system (e.g. name of a Grafana dashboard)
  * *type*: link type, currently only _grafana_ is allowed
  * *variables*: a set of variables that can be injected in the URL. For instance, with something like _namespace: var-namespace_ and _app: var-app_, an URL to a Grafana dashboard that manages _namespace_ and _app_ variables would look like:
_\http://grafana-server:3000/d/xyz/my-grafana-dashboard?var-namespace=some-namespace&var-app=some-app_. The available variables in this context are *namespace*, *app* and *version*.

{{% alert color="warning" %}}
*Label clash*: you should try to avoid labels clashes within a dashboard.
{{% /alert %}}

In Kiali, labels for grouping are aggregated in the top toolbar, so if the same label refers to different things depending on the metric, you wouldn't be able to distinguish them in the UI. For that reason, ideally, labels should not have too generic names in Prometheus.
For instance labels named "id" for both memory spaces and buffer pools would better be named "space_id" and "pool_id". If you have control on label names, it's an important aspect to take into consideration.
Else, it is up to you to organize dashboards with that in mind, eventually splitting them into smaller ones to resolve clashes.

{{% alert color="success" %}}
*Modifying Built-in Dashboards*: If you want to modify or remove a built-in dashboard, you can set its new definition in the Kiali CR's `spec.custom_dashboards`. Simply define a custom dashboard with the same name as the built-in dashboard. To remove a built-in dashboard so Kiali doesn't use it, simply define a custom dashboard by defining only its name with no other data associated with it (e.g. in `spec.custom_dashboards` you add a list item that has `- name: <name of built-in dashboard to remove>`.
{{% /alert %}}

#### Create new dashboards per namespace or workload

The custom dashboards defined in the Kiali CR are available for all workloads in all namespaces.

Additionally, new custom dashboards can be created for a given namespace or workload, using the `dashboards.kiali.io/templates` annotation.

This is an example where a "Custom Envoy" dashboard will be available for all applications and workloads for the `default` namespace:

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: default
  annotations:
    dashboards.kiali.io/templates: |
      - name: custom_envoy
        title: Custom Envoy
        discoverOn: "envoy_server_uptime"
        items:
          - chart:
              name: "Pods uptime"
              spans: 12
              metricName: "envoy_server_uptime"
              dataType: "raw"
```

This other example will create an additional "Active Listeners" dashboard only on `details-v1` workload:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: details-v1
  labels:
    app: details
    version: v1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: details
      version: v1
  template:
    metadata:
      labels:
        app: details
        version: v1
      annotations:
        dashboards.kiali.io/templates: |
          - name: envoy_listeners
            title: Active Listeners
            discoverOn: "envoy_listener_manager_total_listeners_active"
            items:
              - chart:
                  name: "Total Listeners"
                  spans: 12
                  metricName: "envoy_listener_manager_total_listeners_active"
                  dataType: "raw"
    spec:
      serviceAccountName: bookinfo-details
      containers:
      - name: details
        image: docker.io/istio/examples-bookinfo-details-v1:1.16.2
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 9080
        securityContext:
          runAsUser: 1000
```

### Units {#units}

Some units are recognized in Kiali and scaled appropriately when displayed on charts:

* `unit: "seconds"` can be scaled down to `ms`, `µs`, etc.
* `unit: "bytes-si"` and `unit: "bitrate-si"` can be scaled up to `kB`, `MB` (etc.) using [SI / metric system](https://en.wikipedia.org/wiki/International_System_of_Units). The aliases `unit: "bytes"` and `unit: "bitrate"` can be used instead.
* `unit: "bytes-iec"` and `unit: "bitrate-iec"` can be scaled up to `KiB`, `MiB` (etc.) using [IEC standard / IEEE 1541-2002](https://en.wikipedia.org/wiki/IEEE_1541-2002) (scale by powers of 2).

Other units will fall into the default case and be scaled using SI standard. For instance, `unit: "m"` for meter can be scaled up to `km`.

