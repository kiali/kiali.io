---
title: "Concepts"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 1
---

### Application

Is a logical grouping of [Workloads](#workload) defined by the application labels that users apply to an object. In Istio it is defined by the [Label App](#label-app). See [Istio Label Requirements](https://istio.io/docs/setup/kubernetes/spec-requirements/).

### Application Name

It's the name of the [Application](#application) deployed in your environment. This name is provided by the [Label App](#label-app) on the [Workload](#workload).

### Istio object/configuration Type

This is the type specified in the Istio Config. This could be any of the following types: Gateway, [Virtual Service](#virtual-service), DestinationRule, ServiceEntry, Rule, Quota or QuotaSpecBinding.

### Istio Sidecar

For more information see the Istio Sidecar definition in [Istio Sidecar Documentation](https://istio.io/v1.5/docs/reference/commands/sidecar-injector/).

### Label

It's a user-created tag to identify a set of objects.

An empty [label selector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) (that is, one with zero requirements) selects every object in the collection.

A null [label selector](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) (which is only possible for optional selector fields) selects no objects.

For example, Istio uses the [Label App](#label-app) & [Label Version](#label-version) on a [Workload](#workload) to specify the version and the application.

### Label App

This is the 'app' label on an object. For more information, see [Istio Label Requirements](https://istio.io/docs/setup/kubernetes/spec-requirements/).

### Label Version

This is the 'version' label on an object. For more information, see [Istio Label Requirements](https://istio.io/docs/setup/kubernetes/spec-requirements/).

### Namespace

Namespaces are intended for use in environments with many users spread across multiple teams, or projects.

Namespaces are a way to divide cluster resources between multiple users.

### Quota

A limited or fixed number or amount of resources.

### ReplicaSet

Ensures that a specified number of pod replicas are running at any one time.

### Service

A Service is an abstraction which defines a logical set of Pods and a policy by which to access them.  A Service is determined by a [Label](#label).

### Service Entry

For more information see the Service Entry definition in [Istio Service Entry Documentation](https://istio.io/docs/reference/config/networking/service-entry).

### Virtual Service

For more information see the Virtual Service definition in [Istio VirtualService Documentation](https://istio.io/docs/reference/config/networking/virtual-service).

### Workload

For more information see the [Istio Workload definition](https://istio.io/help/glossary/#workload).

