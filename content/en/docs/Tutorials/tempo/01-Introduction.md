---
title: "Introduction"
description: "Kiali and Tempo integration introduction and prerequisites"
weight: 1
---

### Introduction

Kiali uses [Jaeger]({{< ref "/docs/Configuration/p8s-jaeger-grafana/tracing/jaeger" >}}) as a default distributed tracing backend. In this tutorial, we will replace it for [Grafana Tempo](https://grafana.com/docs/tempo/next/).

We will setup a local environment in minikube, and install Kiali with Tempo as a distributed backend. This is a simplified architecture diagram:

![Kiali Tempo Architecture](/images/tutorial/tempo/kiali-tempo.png "Kiali Tempo integration architecture")

- We will install Tempo with the Tempo Operator and enable Jaeger query frontend to be compatible with Kiali in order to query traces.
- We will setup Istio to send traces to the Tempo collector using the zipkin protocol. It is enabled by default from version 3.0 or higher of the Tempo Operator.
- We will install MinIO and setup it up as object store, S3 compatible.

### Environment

We use the following environment:

- Istio 1.18.1
- Kiali 1.72
- Minikube 1.30
- Tempo operator TempoStack v3.0

There are different installation methods for Grafana Tempo, but in this tutorial we will use the [Tempo operator](https://grafana.com/docs/tempo/latest/setup/operator/).
