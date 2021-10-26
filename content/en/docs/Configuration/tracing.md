---
title: "Distributed Tracing / Jaeger"
description: "Configuring Kiali's Jaeger integration."
---

Below are some commonly used configuration options for Kiali's Jaeger integration for Tracing.

For advanced tracing integration, you can also refer to [the Kiali CR `external_services.tracing` section](https://github.com/kiali/kiali-operator/blob/master/deploy/kiali/kiali_cr.yaml).  For Helm installations, it is valid for the config map as well.


## In-Cluster URL

In order to fully integrate with Jaeger, Kiali needs a URL that can be resolved from inside the cluster, typically using Kubernetes DNS. This is the `in_cluster_url` configuration. For instance, for a Jaeger service named `tracing`, within `istio-system` namespace, Kiali config would be:

```yaml
  external_services:
    tracing:
      in_cluster_url: 'http://tracing.istio-system/jaeger'
```

{{% alert color="success" %}}
If you use the Kiali operator (recommended), this config can be set in the Kiali CR. But in most cases, the Kiali operator will set a valid default `in_cluster_url` so you wouldn't have to change anything. If you don't use the Kiali operator, this config can be set in Kiali config map.
{{% /alert %}}

## External URL

When not using an In-Cluster configuration, Kiali can be configuring with an external URL. This can be useful, for example, if Jaeger is not accessible from the Kiali pod. Doing so will enable links from Kiali to the Jaeger UI. This URL needs to be accessible from the browser (it's used for links generation). Example:

```yaml
  external_services:
    tracing:
      in_cluster_url: 'http://tracing.istio-system/jaeger'
      url: 'http://my-jaeger-host/jaeger'
```

{{% alert color="warning" %}}
When using `url` and not `in_cluster_url`, Kiali will not be able to show its native tracing charts, but instead will display external links to the Jaeger UI.
{{% /alert %}}

Once this URL is set, Kiali will show an additional item to the main menu:

![Distributed Tracing View](/images/documentation/configuration/trace-external.png)


