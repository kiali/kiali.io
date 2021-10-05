---
title: "Istio Component Status"
date: 2020-10-26T18:04:38+02:00
draft: false
weight: 7
---


### How can I add one component to the list?

If you are interested in adding one more component to the Istio Component Status tooltip, you have the option to add one new component into the
[Kiali CR](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml), under the `external_services.istio.component_status` field.

For each component there, you will need to specify the `app` label of the deployment's pods, the namespace and whether is a core component or add-on.


### One component is 'Not found' but I can see it running. What can I do?

The first thing you should do is check into the Kiali CR for the `istio.component_status` field.

Kiali looks for a Deployment for which its pods have the `app` label with the specified value in the CR, and lives in that namespace.
The `app` label name may be changed from the default (app) and it is specified in the `istio_labels.app_label_name` in the [Kiali CR](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml).

Ensure that you have specified correctly the namespace and that the deployment's pod template has the specified label.


### One component is 'Unreachable' but I can see it running. What can I do?

Kiali considers one component as `Unreachable` when the component responds to a GET request with a 4xx or 5xx response code.

The URL where Kiali sends a GET request to is the same as it is used for the component consumption. However, Kiali allows you to set a specific URL for health check purposes: the `health_check_url` setting.

In this example, Kiali uses the Prometheus `url` for both metrics consumption and health checks.

```yaml
external_services:
  prometheus:
    url: "http://prometheus.istio-system:9090"
```

In case that the `prometheus.url` endpoint doesn't return 2XX/3XX to GET requests, you can use the following settings to specify which health check URL Kiali should use:

```yaml
external_services:
  prometheus:
    health_check_url: "http://prometheus.istio-system:9090/healthz"
    url: "http://prometheus.istio-system:9090"
```

Please check the [Kiali CR](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml) for more information. Each external service component has its own `health_check_url` and `is_core` setting to tailor the experience in the Istio Component Status feature.

