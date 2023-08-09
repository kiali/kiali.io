---
title: "Introduction"
description: "Kiali and tempo integration introduction and prerequisites"
weight: 1
---

### Introduction

Kiali uses [Jaeger](https://kiali.io/docs/configuration/p8s-jaeger-grafana/jaeger/) as a default distributed tracing backend. In this tutorial, we will replace it for [Grafana Tempo](https://grafana.com/docs/tempo/next/).

In this tutorial, we will setup a local environment in minikube, and install Kiali with Tempo as a distributed backend. This is a simplified image of the architecture:

![Kiali Tempo Architecture](/images/tutorial/tempo/kiali-tempo.png "Kiali Tempo integration architecture")

* We will setup Istio to send traces to the Tempo collector using the zipkin protocol
* We will use Tempo query frontend to read the traces in Jaeger compatible querier format.
* We will use MinIO, an easy to use and S3 compatible object store.

### Environment

We use the following environment:

* Istio 1.18.1
* Kiali 1.72
* Minikube 1.30
* Tempo operator TempoStack v3.0

There are different installation methods for Grafana Tempo, but in this tutorial we will use the [Tempo operator](https://grafana.com/docs/tempo/latest/setup/operator/).

