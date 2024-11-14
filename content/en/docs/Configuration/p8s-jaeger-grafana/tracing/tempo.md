---
title: "Grafana Tempo"
description: >
  This page describes how to configure Grafana Tempo for Kiali.
weight: 2
---

- [Grafana Tempo Configuration](#grafana-tempo-configuration)
    - [Using the Grafana Tempo API](#using-the-grafana-tempo-api)
      - [Setup the Kiali CR](#set-up-the-kiali-cr)
      - [Set up a Tempo Datasource in Grafana](#set-up-a-tempo-datasource-in-grafana)
      - [Additional Configuration](#additional-configuration)
      - [Service check URL](#service-check-url)
      - [Configuration for the Grafana Tempo Datasource](#configuration-for-the-grafana-tempo-datasource)
    - [Using the Jaeger frontend with Grafana Tempo tracing backend](#using-the-jaeger-frontend-with-grafana-tempo-tracing-backend)
      - [Tanka](#tanka)
      - [Tempo Operator](#tempo-operator)
- [Configuration table](#configuration-table) 
  - [Supported Versions](#supported-versions) 
  - [Minimal configuration for Kiali <= 1.79](#minimal-configuration-for-kiali--179)
  - [Minimal configuration for Kiali > 1.79](#minimal-configuration-for-kiali--179-1)
- [Tempo tuning](#tempo-tuning) 
  - [Resources consumption](#resources-consumption) 
  - [Caching](#caching)
  - [Resources consumption](#tune-search-pipeline)
  - [Dedicated attribute columns](#dedicated-attribute-columns)
- [Tempo authentication configuration](#tempo-authentication-configuration)


## Grafana Tempo Configuration

There are two possibilities to integrate Kiali with Grafana Tempo:

- [Using the Grafana Tempo API](#using-the-grafana-tempo-api): This option returns the traces from the Tempo API in OpenTelemetry format. 
- [Using the Jaeger frontend](#using-the-jaeger-frontend-with-grafana-tempo-tracing-backend) with the Grafana Tempo backend.
- Appendix: [Configuration table](#configuration-table) 

### Using the Grafana Tempo API 

There are two steps to set up Kiali and Grafana Tempo: 

- [Set up the Kiali CR](#set-up-the-kiali-cr) updating the Tracing and Grafana sections. 
- [Set up a Tempo data source](#set-up-a-tempo-datasource-in-grafana) in Grafana. 

#### Set up the Kiali CR

This is a configuration example to set up Kiali tracing with Grafana Tempo: 

```yaml
spec:
  external_services:
    tracing:
      # Enabled by default. Kiali will anyway fallback to disabled if
      # Tempo is unreachable.
      enabled: true
      health_check_url: "https://tempo-instance.grafana.net"
      # Tempo service name is "query-frontend" and is in the "tempo" namespace.
      # Make sure the URL you provide corresponds to the non-GRPC enabled endpoint
      # It does not support grpc yet, so make sure "use_grpc" is set to false.
      internal_url: "http://tempo-tempo-query-frontend.tempo.svc.cluster.local:3200/"
      provider: "tempo"
      tempo_config:
        org_id: "1"
        datasource_uid: "a8d2ef1c-d31c-4de5-a90b-e7bc5252cd00"
        url_format: "grafana"
      use_grpc: false
      # Public facing URL of Tempo 
      external_url: "https://tempo-tempo-query-frontend-tempo.apps-crc.testing/"
```

Kiali will use the _external_url_ to redirect to the Tracing UI, in the "View in tracing" links. 
In Tempo, by default, the _url_format_ is set to _grafana_. This will use a particular url path and query for each link. The default UI for Grafana Tempo is Grafana, so it will use the _external_url_ set in the Grafana section, such as this example: 

```yaml
spec:
  external_services:
    grafana:
      enabled: true
      external_url: https://grafana.apps-crc.testing/
```

It is also possible to set _url_format_ to "jaeger". In that case, Kiali will use the _external_url_ set in the tracing section, and the url path and query will be following the Jaeger UI format. 

#### Set up a Tempo Datasource in Grafana

We can optionally set up a default [Tempo datasource](https://grafana.com/docs/grafana/latest/datasources/tempo/) in Grafana so that you can view the Tempo tracing data within the Grafana UI, as you see here: 

![Kiali grafana_tempo](/images/documentation/configuration/grafana_tempo_ds.png)

To set up the Tempo datasource, go to the _Home_ menu in the Grafana UI, click _Data sources_, then click the _Add new data source_ button and select the `Tempo` data source.  You will then be asked to enter some data to configure the new Tempo data source: 

![Kiali grafana_tempo](/images/documentation/configuration/tempo_ds.png)

The most important values to set up are the following: 

- Mark the data source as default, so the URL that Kiali uses will redirect properly to the Tempo data source. 
- Update the HTTP URL. This is the internal URL of the HTTP tempo frontend service. e.g. `http://tempo-tempo-query-frontend.tempo.svc.cluster.local:3200/`

#### Additional configuration 

The _Traces_ tab in the Kiali UI will show your traces in a bubble chart:

![Kiali grafana_tempo](/images/documentation/configuration/grafana_tempo.png)

Increasing performance is achievable by enabling gRPC access, specifically for query searches. However, accessing the HTTP API will still be necessary to gather information about individual traces. This is an example to configure the gRPC access: 

```yaml
spec:
  external_services:
    tracing:
      enabled: true
      # grpc port defaults to 9095
      grpc_port: 9095 
      internal_url: "http://query-frontend.tempo:3200"
      provider: "tempo"
      use_grpc: true
      external_url: "http://my-tempo-host:3200"
```

##### Service check URL

By default, Kiali will check the service health in the endpoint `/status/services`, but sometimes, this is exposed in a different url, which can lead to a component unreachable message: 

![component_unreachable](/images/documentation/configuration/component_unreachable.png)

This can be changed with the `health_check_url` configuration option. 

```yaml
spec:
  external_services:
    tracing:
      health_check_url: "http://query-frontend.tempo:3200"
```

##### Configuration for the Grafana Tempo Datasource 

In order to correctly redirect Kiali to the right Grafana Tempo Datasource, there are a couple of configuration options to update: 

```yaml
spec:
  external_services:
    tracing:
      tempo_config:
        org_id: "1"
        datasource_uid: "a8d2ef1c-d31c-4de5-a90b-e7bc5252cd00"
```

`org_id` is usually not needed since "1" is the default value which is also Tempo's default org id. 
The `datasource_uid` needs to be updated in order to redirect to the right datasource in Grafana versions 10 or higher. 

### Using the Jaeger frontend with Grafana Tempo tracing backend

It is possible to use the Grafana Tempo tracing backend exposing the Jaeger API.
[tempo-query](https://github.com/grafana/tempo/tree/main/cmd/tempo-query) is a
Jaeger storage plugin. It accepts the full Jaeger query API and translates these
requests into Tempo queries.

Since Tempo is not yet part of the built-in addons that are part of Istio, you
need to manage your Tempo instance.

#### Tanka

The [official Grafana Tempo documentation](https://grafana.com/docs/tempo/latest/setup/tanka/)
explains how to deploy a Tempo instance using [Tanka](https://tanka.dev/). You
will need to tweak the settings from the default Tanka configuration to:

- Expose the Zipkin collector
- Expose the GRPC Jaeger Query port

When the Tempo instance is deployed with the needed configurations, you have to
set
[`meshConfig.defaultConfig.tracing.zipkin.address`](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#ProxyConfig-tracing)
from Istio to the Tempo Distributor service and the Zipkin port. Tanka will deploy
the service in `distributor.tempo.svc.cluster.local:9411`.

The `external_services.tracing.internal_url` Kiali option needs to be set to:
`http://query-frontend.tempo.svc.cluster.local:16685`.

#### Tempo Operator

The [Tempo Operator for Kubernetes](https://github.com/grafana/tempo-operator)
provides a native Kubernetes solution to deploy Tempo easily in your system.

After installing the Tempo Operator in your cluster, you can create a new
Tempo instance with the following CR:

```yaml
kubectl create namespace tempo
kubectl apply -n tempo -f - <<EOF
apiVersion: tempo.grafana.com/v1alpha1
kind: TempoStack
metadata:
  name: smm
spec:
  storageSize: 1Gi
  storage:
    secret:
      type: s3
      name: object-storage
  template:
    queryFrontend:
      component:
        resources:
          limits:
            cpu: "2"
            memory: 2Gi
      jaegerQuery:
        enabled: true
        ingress:
          type: ingress
EOF
```

Note the name of the bucket where the traces will be stored in our example is
called `object-storage`. Check the
[Tempo Operator](https://grafana.com/docs/tempo/next/setup/operator/object-storage)
documentation to know more about what storages are supported and how to create
the secret properly to provide it to your Tempo instance.

Now, you are ready to configure the
[`meshConfig.defaultConfig.tracing.zipkin.address`](https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#ProxyConfig-tracing)
field in your Istio installation. It needs to be set to the `9411` port of the
Tempo Distributor service. For the previous example, this value will be
`tempo-smm-distributor.tempo.svc.cluster.local:9411`.

Now, you need to configure the `internal_url` setting from Kiali to access
the Jaeger API. You can point to the `16685` port to use GRPC or `16686` if not.
For the given example, the value would be
`http://tempo-ssm-query-frontend.tempo.svc.cluster.local:16685`.

There is a [related tutorial]({{< ref "/docs/tutorials/tempo/02-kiali-tempo-integration" >}}) with detailed instructions to setup Kiali and Grafana Tempo with the Operator.

### Configuration table

#### Supported versions

| <div style="width:170px">Kiali Version</div> | <div style="width:70px">Jaeger</div> | <div style="width:70px">Tempo</div> | <div style="width:270px">Tempo with JaegerQuery</div> |
|----------------------------------------------|--------|-------|-------------------------------------------------------|
| <= 1.79 (OSSM 2.5)                           | ✅      | ❌     | ✅                                                     |
| > 1.79                                       | ✅      | ✅     | ✅                                                     |

<br>

#### Minimal configuration for Kiali <= 1.79

In `external_services.tracing`

|                                                    | <div style="width:470px">http<hr></div>                                                    | <div style="width:470px">grpc <hr></div>                                                                                 |
|----------------------------------------------------|--------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------|
| Jaeger | `.internal_url = 'http://jaeger_service_url:16686/jaeger'`<br/> `.use_grpc = false` <hr> | `.internal_url = 'http://jaeger_service_url:16685/jaeger'`<br/> `.use_grpc = true (Not required: by default)` <br><hr> | 
| Tempo                                              | `.internal_url = 'http://query_frontend_url:16686'`<br/> `.use_grpc = false` <hr>        | `.internal_url = 'http://query_frontend_url:16685'`  <br/>`.use_grpc = true (Not required: by default)` <br/><hr>                                                    |

<br>

#### Minimal configuration for Kiali > 1.79

|        | <div style="width:470px">http<hr></div>                                                                     | <div style="width:470px">grpc  <hr></div>                                                                                                                        |
|--------|-------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Jaeger | `.internal_url = 'http://jaeger_service_url:16686/jaeger'`<br/> `.use_grpc = false` <hr>                  | `.internal_url = 'http://jaeger_service_url:16685/jaeger'` <br>`.use_grpc = true (Not required: by default)`<br><hr>                                           | 
| Tempo  | <br/>`internal_url = 'http://query_frontend_url:3200'`<br/> `.use_grpc = false`<br/> `.provider = 'tempo'`<br/><hr> | `.internal_url = 'http://query_frontend_url:3200'`<br/> `.grpc_port: 9095` <br/>`.provider: 'tempo'`<br/>`.use_grpc = true (Not required: by default)`<hr> |

### Tempo tuning

#### Resources consumption

Grafana Tempo is a powerful tool, but it can lead to performance issues when not configured correctly. 
For example, the following configuration is not recommended and may lead to OOM issues for simple queries in the query-frontend component: 

```yaml
spec:
  resources:
    total:
      limits:
        memory: 2Gi
        cpu: 2000m
```

These resources are shared between all the Tempo components. 
When needed, apply resources to each specific component, instead of applying the resources globally:

```yaml
spec:
  template:
    queryFrontend:
      component:
        resources:
          limits:
            cpu: "2"
            memory: 2Gi
```

[This Grafana Dashboard](/files/tempo-dashboard.json) is available to measure the resources used in the **tempo** namespace. 

#### Caching

Tempo offers multi-level [caching](https://grafana.com/docs/tempo/latest/operations/caching/) that is used by default with Tanka and Helm deployment examples. It uses external cache, supporting Memcached and Redis. 
The lower level cache has a higher hit rate, and caches bloom filters and parquet data.
The higher level caches frontend-search data.

Optimizing the cache depends on the application usage, and can be done modifying different parameters:

- Connection limit for MemCached: Should be increased in large deployments, as MemCached is set to 1024 by default.
- Cache size control: Should be increased when the working set is larger than the size of cache.

#### Tune search pipeline

There are many parameters to [tune the search pipeline](https://grafana.com/docs/tempo/latest/operations/backend_search/), some of these:

- max_concurrent_queries: If it is too high it can cause OOM. 
- concurrent_jobs: How many jobs are done concurrently.
- max_retries: When it is too high it can result in a lot of load. 

#### Dedicated attribute columns

When using the vParquet3 storage format , defining [dedicated attribute columns](https://grafana.com/docs/tempo/latest/operations/dedicated_columns/) can improve the query performance. 
In order to best choose those columns (Up to 10), a good criteria is to choose attributes that contribute growing the block size (And not those commonly used).

### Tempo authentication configuration

The Kiali CR provides authentication configuration that will be used also for querying the version check to provide information in the Mesh graph.

```yaml
spec:
  external_services:
    tracing:
      enabled: true
      auth:
        ca_file: ""
        insecure_skip_verify: false
        password: "pwd"
        token: ""
        type: "basic"
        use_kiali_token: false
        username: "user"
      health_check_url: ""
```

To configure a secret to be used as a password, see this [FAQ entry]({{< relref "../../../FAQ/installation#how-can-i-use-a-secret-to-pass-external-service-credentials-to-the-kiali-server" >}})
