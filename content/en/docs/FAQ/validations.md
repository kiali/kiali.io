---
title: "Validations"
date: 2019-12-11T09:04:38+02:00
draft: false
weight: 4
---


### Which formats does Kiali support for specifying hosts?

Istio highly recommends that you always use fully qualified domain names (FQDN) for hosts in DestinationRules. However, Istio does allow you to use other formats like short names (_details_ or _details.bookinfo_).
Kiali only supports FQDN and simple service names as host formats: for example _details.bookinfo.svc.cluster.local_ or _details_. Validations using the _details.bookinfo_ format might not be accurate.


In the following example it should show the validation of "More than one Destination Rule for the same host subset combination". Because of the usage of the short name _reviews.bookinfo_ Kiali won't show the warning message on both destination rules.

```yaml
{{% readfile file="/themes/docsy/static/files/validation_examples/001.yaml" %}}
```

See the recomendation Istio gives regarding [host format^](https://istio.io/docs/reference/config/networking/destination-rule/#DestinationRule):
_"To avoid potential misconfigurations, it is recommended to always use fully qualified domain names over short names."_

For best results with Kiali, you should use fully qualified domain names when specifying hosts.

