---
title: "No Istiod Access"
description: "Kiali working with no access to Istiod"
---

## Introduction

There are different scenarios where Kiali is required to work with no access to Istio:

* When using other Service Mesh solutions that doesn't expose Istiod
* Different [deployment models](https://istio.io/latest/docs/ops/deployment/deployment-models/#multiple-clusters) where Istiod is not available locally and remotely 

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

* Istio Configurations will be in read only mode. The list of Istio configuration is obtained using the Kubernetes API, but the validation will fail due to the  validatingwebhookconfiguration web hook, created by Istio. 
* The control plane metrics won't be visible.
* The proxy status won't be available in the workloads details view.
* The namespace list will be obtained directly from the Kubernetes API, because it won't be possible to use the Istio cache. This could affect slightly the performance.
* The Istio validations won't be available ? 
* Istio Registry Services that are not present in the Kubernetes list won't be available

<img src="/images/documentation/configuration/no_istio_d.png" />

### Istio Registry Services

Istio Registry Services won't be available in the service list when Istio API is disabled. 

Service list when Istio API is enabled: 

<img src="/images/documentation/configuration/registry_services.png" />

Example when it is disabled: 

<img src="/images/documentation/configuration/registry_services_api_disabled.png" />