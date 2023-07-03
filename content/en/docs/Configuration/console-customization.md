---
title: "Console Customization"
description: "Default selections, find and hide presets and custom metric aggregations."
---

## Custom metric aggregations

The inbound and outbound metric pages, in the _Metrics settings_ drop-down,
provides an opinionated set of groupings that work both for filtering out
metric data that does not match the selection and for aggregating data into
series. Each option is backed by a label on the collected Istio telemetry.

It is possible to add custom aggregations, like in the following example:

```yaml
spec:
  kiali_feature_flags:
    ui_defaults:
      metrics_inbound:
        aggregations:
        - display_name: Istio Network
          label: topology_istio_io_network
        - display_name: Istio Revision
          label: istio_io_rev
      metrics_outbound:
        aggregations:
        - display_name: Istio Revision
          label: istio_io_rev
```

Notice that custom aggregations for inbound and outbound metrics are defined separately.

You can find some [screenshots in Kiali v1.40 feature update blog
post](https://medium.com/kialiproject/kiali-release-1-40-features-update-78f19fd113c5#fe3d).

## Default metrics duration and refresh interval

Most Kiali pages show _metrics per refresh_ and _refresh interval_
drop-downs. These are located at the top-right of the page.

_Metrics per refresh_ specifies the time range back from the current
instant to fetch metrics and/or distributed tracing data. By default, a
1-minute time range is selected.

_Refresh interval_ specifies how often Kiali will automatically refresh the
data shown. By default, Kiali refreshes data every 15 seconds.

```yaml
spec:
  kiali_feature_flags:
    ui_defaults:
      # Valid values: 1m, 5m, 10m, 30m, 1h, 3h, 6h, 12h, 1d, 7d, 30d
      metrics_per_refresh: "1m"

      # Valid values: pause, 10s, 15s, 30s, 1m, 5m, 15m
      refresh_interval: "15s"
```

User selections won't persist a reload.

## Default namespace selection

By default, when Kiali is accessed by the first time, on most Kiali pages users
will need to use the namespace drop-down to choose namespaces they want to view
data from. The selection will be persisted on reloads.

However, it is possible to configure a predefined selection of
namespaces, like in the following example:

```yaml
spec:
  kiali_feature_flags:
    ui_defaults:
      namespaces:
      - istio-system
      - bookinfo
```

Namespace selection will reset to the predefined set on reloads. Also, if for
some reason a namespace becomes deleted, Kiali will simply ignore it from the
list.

## Graph find and hide presets

In the toolbar of the topology graph, the _Find_ and _Hide_ textboxes can be
configured with presets for your most used criteria. You can find [screenshots
and a brief description of this feature in the feature update blog post for
versions 1.31 to 1.33](https://medium.com/kialiproject/kiali-releases-1-34-to-1-39-overview-587f33fac41a#3962).

The following are the default presets:

```yaml
spec:
  kiali_feature_flags:
    ui_defaults:
      graph:
        find_options:
        - auto_select: false  
          description: "Find: slow edges (> 1s)"
          expression: "rt > 1000"
        - auto_select: false
          description: "Find: unhealthy nodes"
          expression:  "! healthy"
        - auto_select: false
          description: "Find: unknown nodes"
          expression:  "name = unknown"
        hide_options:
        - auto_select: false
          description: "Hide: healthy nodes"
          expression: "healthy"
        - auto_select: false
          description: "Hide: unknown nodes"
          expression:  "name = unknown"
```

Hopefully, the attributes to configure this feature are self-explanatory.

To enable one of the configurations by default, it is possible to set _auto_select_ to true, available for find and hide settings.

Note that by providing your own presets, you will be overriding the default
configuration. Make sure to include any default presets that you need in case
you provide your own configuration.

## Graph default traffic rates

Traffic rates in the graph are fetched from Istio telemetry and there are
several [metric sources](https://istio.io/latest/docs/reference/config/metrics/)
that can be used.

In the graph page, you can select the traffic rate metrics using the _Traffic_
drop-down (next to the _Namespaces_ drop-down). By default, _Requests_ is
selected for GRPC and HTTP protocols, and _Sent bytes_ is selected for the TCP
protocol, but you can change the default selection:

```yaml
spec:
  kiali_feature_flags:
    ui_defaults:
      graph:
        traffic:
          grpc: "requests" # Valid values: none, requests, sent, received and total
          http: "requests" # Valid values: none and requests
          tcp:  "sent"     # Valid values: none, sent, received and total
```

Note that only _requests_ provide response codes and will allow health to be
calculated. Also, the resulting topology graph may be different for each source.

