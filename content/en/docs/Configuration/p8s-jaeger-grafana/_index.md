---
title: "Prometheus, Tracing, Grafana"
description: "Kiali data sources and add-ons."
---

Prometheus is a required telemetry data source for Kiali. Jaeger/Tempo is a highly recommended tracing data source. Kiali also offers simple add-on integrations for Grafana and Perses. This page describes how to configure Kiali to communicate with these dependencies.

Read the dedicated configuration page to learn more.

If any of these services use HTTPS with certificates issued by a private CA, see the [TLS Configuration]({{< relref "./tls-configuration" >}}) page.
