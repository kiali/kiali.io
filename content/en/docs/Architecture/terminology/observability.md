---
title: "Observability"
date: 2018-06-20T19:04:38+02:00
draft: false
---

### Envoy

A proxy that Istio starts for each pod in the service mesh.
For more information see the [Istio Envoy Documentation](https://istio.io/docs/ops/deployment/architecture/#envoy).

### Envoy Health

A health check performed by Envoy proxies, for inbound and outbound traffic: see membership_healthy and membership_total from [Envoy documentation](https://www.envoyproxy.io/docs/envoy/v1.7.1/configuration/cluster_manager/cluster_stats#general).

