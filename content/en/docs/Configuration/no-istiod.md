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

* The control plane metrics won't be available.
* The proxy status won't be available in the workloads details view.
* The namespace list will be obtained directly from the Kubernetes API, because it won't be possible to use the Istio cache. This could affect slightly the performance.
* The [Istio validations](#istio_validations) won't be available. There are, though, some cases where they will be still available.
* [Istio Registry Services](#istio_registry) that are not present in the Kubernetes list won't be available.
* [Istio Configurations](#istio_configurations) will be available. This is because the list of Istio configurations is obtained using the Kubernetes API.

<img src="/images/documentation/configuration/no_istiod.png" />

### <a name="istio_validations"></a> Istio Validations

The Istio validations won't be available as this is a logic provided by the Istio API. 
But, if the Istio Config was created and the validatingwebhookconfiguration web hook was enabled, the validation messages will be available and the validations can be found:

<img src="/images/documentation/configuration/istio_validations.png" />

Kiali validations will be available:

<img src="/images/documentation/configuration/kiali_validations.png" />

### <a name="istio_registry"></a> Istio Registry Services

Istio Registry Services won't be available in the service list when Istio API is disabled. 

Service list when Istio API is enabled: 

<img src="/images/documentation/configuration/registry_services.png" />

Example when it is disabled: 

<img src="/images/documentation/configuration/registry_services_api_disabled.png" />

### <a name="istio_configurations"></a> Istio Configurations

Istio Configurations are available in view and edit mode. 
There is one scenario where the creation/deletion/edition could fail: If the Istio validation webhook is enabled but istio API is not available. In this case, the Istio validation would be removed in order for this to work. 

It can be checked with the following command: 

```cmd
kubectl get ValidatingWebhookConfiguration
```