---
title: "Configuration"
description: "How to configure Kiali to fit your needs."
weight: 2
---

The pages in this _Configuration_ section describe most available options for
managing and customizing your Kiali installation.

Unless noted, it is assumed that you are using the Kiali operator and that you
are managing the Kiali installation through a Kiali CR. The provided YAML
snippets for configuring Kiali should be placed in your Kiali CR. For example,
the provided configuration snippet for [setting up the Anonymous authentication
strategy]({{< relref "authentication/anonymous/#set-up" >}}) is the following:

```yaml
spec:
  auth:
    strategy: anonymous
```

You will need to take this YAML snippet and apply it to your Kiali CR. As an example, an almost minimal Kiali CR using the previous configuration snippet would be the following:

```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  namespace: kiali-namespace
  name: kiali
spec:
  istio_namespace: istio-system
  deployment:
    namespace: kiali-namespace
  auth:
    strategy: anonymous
```

Then, you can save the finished YAML file and apply it with `kubectl apply -f`.

It is recommended that you read
_[The Kiali CR]({{< relref "../Installation/installation-guide/creating-updating-kiali-cr" >}})_
and the _[Example Install]({{< relref "../Installation/installation-guide/example-install" >}})_
pages of the Installation Guide for more information about using the Kiali CR.

Also, for reference, the [Kiali CR YAML template file](https://github.com/kiali/kiali operator/blob/master/deploy/kiali/kiali_cr.yaml) documents all available options.
