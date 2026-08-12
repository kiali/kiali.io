---
title: "OSSM Console"
description: >
  OpenShift Service Mesh Console - Dynamic plugin
  for OpenShift
weight: 10
---

OpenShift Service Mesh Console (OSSMC) is a dynamic plugin for OpenShift Console based on OpenShift [dynamic plugins](https://docs.openshift.com/container-platform/4.21/web_console/dynamic-plugin/dynamic-plugin-overview.html) technology.

OSSMC provides standalone **Kialis** and **Istios** pages that display Kiali CRs and Istio CRs directly from the cluster — these do not require a Kiali server connected to the plugin. When a Kiali instance is promoted and reachable, OSSMC also provides Kiali-powered observability — a dedicated **Service Mesh** navigation category with pages for overview, traffic graph, mesh infrastructure, namespaces, applications, services, workloads, and Istio configuration, plus **Service Mesh** tabs on OpenShift resource detail pages.

![OSSMC](/images/documentation/ossmc/05-overview.png)

OSSMC was [first released](https://cloud.redhat.com/blog/introducing-the-openshift-service-mesh-console-a-developer-preview) in September 2022 as a developer preview. It has since been released GA in October 2023.

### Documentation
* [User guide](/docs/ossmc/users-guide) — includes [standalone features without a connected Kiali server](/docs/ossmc/users-guide/#standalone-features-without-a-connected-kiali-server)
* [Install via OSSMConsole CR](/docs/installation/installation-guide/creating-updating-ossmconsole-cr/)


### Get Involved
* [Development guide](https://github.com/kiali/openshift-servicemesh-plugin/blob/main/README.md)
* [Create a bug report or an Improvement Request](https://github.com/kiali/openshift-servicemesh-plugin/issues/new)
* [Contribute with an existing issue](https://github.com/kiali/openshift-servicemesh-plugin/issues)

### Releases
* [Release list](https://github.com/kiali/openshift-servicemesh-plugin/releases)
