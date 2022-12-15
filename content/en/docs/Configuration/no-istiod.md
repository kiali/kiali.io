---
title: "No Istiod Access"
description: "Kiali working with no access to Istiod"
---

## Introduction

There are different scenarios where Kiali is required to work with no access to Istio:

* When using other Service Mesh alternatives to Istio
* Multi cluster environments in non multi primary scenarios

## Configuration

Kiali needs to be set up when the Istio registry is not accesible, this is done with a new configuration item, istio_api_enabled.  
By default, istio_api_enabled is true. 

```yaml
# ...
spec:
external_services:
  istio:
    istio_api_enabled: false
# ...
```

## How does it affects Kiali

When Istio registry is not available, there are some expected changes: 

* Istio Configurations will be in read only mode
* The control plane metrics won't be visible
* The sidecar information won't be available in the workloads details view
* The namespace list will be obtained directly from the Kube API, because it won't be possible to use the Istio cache. This could affect slightly the performance. 

<img src="/images/documentation/configuration/no_istio_d.png" />