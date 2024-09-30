---
title: "Release Notes"
type: docs
weight: 1
---

For additional information check our [sprint demo videos](https://www.youtube.com/channel/UCcm2NzDN_UCZKk2yYmOpc5w) and [blogs](https://medium.com/kialiproject).

## 1.89.7
Sprint Release: Sep 30, 2024

Features:

The next feature release will be Kiali v 2.0.0

Fixes:

* [K8s Gateways: Fix "Out of mesh" error when not in 'istio-system'](https://github.com/kiali/kiali/issues/7720)
* [Operator: Fix support of namespaces that just have numbers in their name](https://github.com/kiali/kiali/issues/7773)
* [Validations - Fix “exportTo” validation inconsistency between List and Detail pages](https://github.com/kiali/kiali/issues/7685)

## 1.89.3
Sprint Release: Sep 09, 2024

Features:

The next feature release will be Kiali v 2.0.0

Fixes:

* [Custom Dashboard - External Links of Custom dashboard not visible](https://github.com/kiali/kiali/issues/7638)
* [Graph - Cannot load the graph: cluster (unknown) is not found or is not accessible for Kiali](https://github.com/kiali/kiali/issues/7672)
* [Graph - Inconsistent ServiceEntry Display in Multi-Namespace Environment](https://github.com/kiali/kiali/issues/7590)
* [Graph - Fix handling of defaultExportTo setting in serviceEntry and other components](https://github.com/kiali/kiali/issues/7589)
* [Tempo - query_scope is ignored for Tempo in single-cluster environment](https://github.com/kiali/kiali/issues/7658)

## 1.89.0
Sprint Release: Aug 19, 2024

Features:

* [Maintenance - Upgrade go from 1.22.1 to 1.22.5](https://github.com/kiali/kiali/issues/7480)
* [Maintenance - Move to node 20](https://github.com/kiali/kiali/issues/7503)
* [Mesh page - Hide mesh page for non istio-system users](https://github.com/kiali/kiali/issues/7527)
* [Perf - Kiali Performance improvements.](https://github.com/kiali/kiali/issues/7076)
* [UX - Align the notification badge with PF standards](https://github.com/kiali/kiali/issues/7553)

Fixes:

* [Auth - k8s api token not auto refreshing for calls to fetch cacerts](https://github.com/kiali/kiali/issues/7542)
* [Mesh page - Display full yaml from `istio` configmap](https://github.com/kiali/kiali/issues/7459)
* [Operator - when installing OSSMC, make sure the Kiali version is the same.](https://github.com/kiali/kiali/issues/7619)
* [OSSMC - cannot update namespace or create Istio objects](https://github.com/kiali/openshift-servicemesh-plugin/issues/330)
* [OSSMC - Upgrade api from v1alpha1 to v1](https://github.com/kiali/kiali/issues/7622)

## 1.88.0
Sprint Release: Jul 29, 2024

Features:

* [Ambient - Identify waypoint proxies for Istio Ambient](https://github.com/kiali/kiali/issues/7350)
* [Dependencies - React Router migration from v5 to v6](https://github.com/kiali/kiali/issues/7207)
* [Mesh page - Hide mesh page for non istio-system users](https://github.com/kiali/kiali/issues/7527)
* [Mesh page - View Tempo version in Mesh Page](https://github.com/kiali/kiali/issues/7531)
* [K8s GW API - Autodiscover gateways](https://github.com/kiali/kiali/issues/7501)
* [K8s GW API - Rework - Duplicate labels in Kiali CR and code](https://github.com/kiali/kiali/issues/7524)
* [K8s GW API - Cross-Namespace routing](https://github.com/kiali/kiali/issues/7413)
* [UI - Place alert notifications in the top right corner of the screen](https://github.com/kiali/openshift-servicemesh-plugin/issues/335)
* [UI - Align the notification badge with PF standards](https://github.com/kiali/kiali/issues/7553)

Fixes:

* [Mesh page - Grafana version checks don't use configured Grafana auth](https://github.com/kiali/kiali/issues/7475)
* [Mesh page - throws error when one of the clusters is inaccessible](https://github.com/kiali/kiali/issues/7455)
* [Tracing - The tracing service is disabled by default](https://github.com/kiali/kiali/issues/7332)
* [K8s GW API - Hardcoded ingressgateway labels in code](https://github.com/kiali/kiali/issues/7232)
* [Cypress - KIA1102 validation fails - Issue in Kiali](https://github.com/kiali/kiali/issues/7522)
* [Ambient - Hiding TCP hides HTTP](https://github.com/kiali/kiali/issues/7549)
* [Kiali operator - helmchart frequently changes the replica count when HPA is enabled](https://github.com/kiali/kiali/issues/7559)

## 1.87.0
Sprint Release: Jul 08, 2024

Features:

* [Ambient - Show Ambient labels in Service and Application details](https://github.com/kiali/kiali/issues/7432)
* [Ambient - Improve Ambient appender performance](https://github.com/kiali/kiali/issues/7473)
* [Graph - improve PFT "focus node'](https://github.com/kiali/kiali/issues/7444)
* [K8s GW API - 1.1 Support](https://github.com/kiali/kiali/issues/7355)
* [K8s GW API - GRPCRoute support](https://github.com/kiali/kiali/issues/7223)
* [Kiali.io - Include performance results and improvements into kiali.io](https://github.com/kiali/kiali/issues/7397)
* [Kiali.io - Add Kiali and Ambient documentation](https://github.com/kiali/kiali/issues/7490)
* [Operator - ansible kubernetes.core collection update](https://github.com/kiali/kiali/issues/7476)
* [OSSMC - Support for Gateway API objects in the Istio Config list page](https://github.com/kiali/openshift-servicemesh-plugin/issues/317)

Fixes:

* [Ambient - Cannot load the graph: Namespace is excluded](https://github.com/kiali/kiali/issues/7448)
* [Ambient - ztunnel logs are using pod name (And not workload)](https://github.com/kiali/kiali/issues/7500)
* [Masthead - kiali may hang when asking for masthead's Debug Info while graph page is displayed](https://github.com/kiali/kiali/issues/7504)
* [Mesh page - controlplanes have an edge to every dataplane](https://github.com/kiali/kiali/issues/7458)
* [Multi-cluster - Visual bug on the Overview page upon refresh](https://github.com/kiali/kiali/issues/7063)
* [Routing Wizard - Empty Matching fail](https://github.com/kiali/kiali/issues/7447)
* [K8s GW API - ReferenceGrant has incorrect API version in the wizard](https://github.com/kiali/kiali/issues/7463)
* [OSSMC cannot update namespace or create Istio objects](https://github.com/kiali/openshift-servicemesh-plugin/issues/330)
* [Validations - KIA0106 False Positive - Unable to Find Service Accounts](https://github.com/kiali/kiali/issues/7481)

Deprecations:
* Kiali is deprecating its current namespace selection approach. For a description of the new mechanism see https://github.com/kiali/kiali/blob/master/design/KEPS/namespace-discovery/proposal.md. The following configuration is deprecated:
  * spec.deployment.accessible_namespaces
* Note that the following settings have already been deprecated and will soon be removed:
  * api.namespaces.exclude
  * api.namespaces.include
  * api.namespaces.label_selector_exclude
  * api.namespaces.label_selector_include

## 1.86.0
Sprint Release: Jun 17, 2024

Features:

* [mesh page - Add legend to the mesh graph](https://github.com/kiali/kiali/issues/7377)
* [mesh page = display side-panel JSON in a table format](https://github.com/kiali/kiali/issues/7379)
* [ambient - support http ambient waypoint telemetry in graph](https://github.com/kiali/kiali/issues/7344)
* [ambient - support http ambient waypoint telemetry in charts](https://github.com/kiali/kiali/issues/7429)
* [ambient - Adapt Auto Injection action in Ambient Mesh](https://github.com/kiali/kiali/issues/7420)
* [Request for fetch traces is timeouted after 30s](https://github.com/kiali/kiali/issues/7388)
* [Simplify i18n support ](https://github.com/kiali/kiali/issues/7394)

Fixes:

* [Traces are not filtered for cluster in Multi cluster](https://github.com/kiali/kiali/issues/7384)
* [graph - PFT graph does not show parallel edges with different protocols](https://github.com/kiali/kiali/issues/7418)
* [Helm chart/operator does not support Adding an Inaccessible Cluster ](https://github.com/kiali/kiali/issues/7187)
* [CI - Flake - graph_context_menu nodes undefined](https://github.com/kiali/kiali/issues/7256)
* [CI - Improve Cypress test related in kiali_help.feature](https://github.com/kiali/kiali/issues/7180)

## 1.85.0
Sprint Release: May 27

Features:

* [New Mesh Topology page](https://github.com/kiali/kiali/issues/5913)
* [Custom http headers for tracing](https://github.com/kiali/kiali/issues/7266)
* [Add the ability to modify the dnsconfig for the kiali deployment in kubernetes](https://github.com/kiali/kiali/issues/7150)
* [make sure Kiali can observe important istiod metrics](https://github.com/kiali/kiali/issues/7238)
* [kiali-server helm chart: Do not create ClusterRole if not needed](https://github.com/kiali/kiali/issues/7357)
* [Include Mesh page in OSSMC](https://github.com/kiali/openshift-servicemesh-plugin/issues/308)

Fixes:

* [graph - Getting "Cannot load the graph: cluster (kubernetes) is not found or is not accessible for Kiali" with certain prometheus configurations.](https://github.com/kiali/kiali/issues/7305)
* [ambient - Improve check for detection of workload in Ambient Mesh](https://github.com/kiali/kiali/issues/6523)
* [ambient - ztunnel logs are not shown on a kind cluster ](https://github.com/kiali/kiali/issues/7338)
* [ossmc - Istio config list page does not filter by namespace (OCP 4.15)](https://github.com/kiali/openshift-servicemesh-plugin/issues/298)
* [Vulnerability in Go Crypto CVE-2022-27191](https://github.com/kiali/kiali/issues/6648)

## 1.84.0
Sprint Release: May 06, 2024

Features:

* [Ambient - support ztunnel access logs](https://github.com/kiali/kiali/issues/6898)
* [Operator - be able to disable namespace watching](https://github.com/kiali/kiali/issues/7322)
* [OSSMC - Adapt OSSMC to PF5](https://github.com/kiali/openshift-servicemesh-plugin/issues/198)
* [OSSMC - Internationalization (I18N)](https://github.com/kiali/openshift-servicemesh-plugin/issues/279)

Fixes:

* [KIA1102 shows warning instead of a danger status](https://github.com/kiali/kiali/issues/7275)
* [Traffic graph context menu options do not redirect to the correct pages](https://github.com/kiali/openshift-servicemesh-plugin/issues/284)
* [(multi-Cluster AuthorizationPolicy) (KIA0106) when namespace SPIFFY is on remote cluster](https://github.com/kiali/kiali/issues/7152)
* [False KIA1102 alert](https://github.com/kiali/kiali/issues/7287)
* [Kiali fails to watch Gateway due to `spec.servers(*).tls.mode: OPTIONAL_MUTUAL` setting](https://github.com/kiali/kiali/issues/7315)

## 1.83.0
Sprint Release: Apr 12, 2024

Features:

* n/a

Fixes:

* [Namespace selector order is random](https://github.com/kiali/kiali/issues/7227)
* [The Istio config list page does not update when switching from a forbidden namespace to an accessible one](https://github.com/kiali/openshift-servicemesh-plugin/issues/288)
* [token & OpenShift authentication not working ](https://github.com/kiali/kiali/issues/7252)
* [automaxprocs removed from kiali](https://github.com/kiali/kiali/issues/7254)
* [Graph for Ambient ns is not generated correctly when the traffic is not generated throw a Gateway](https://github.com/kiali/kiali/issues/7259)
* [(e2e) Tests should check status code before attempting to unmarshal into json](https://github.com/kiali/kiali/issues/6777)
* [(molecule) flake in molecule test "os-console-links-test"](https://github.com/kiali/kiali/issues/7243)

## 1.82.0
Sprint Release: Mar 22, 2024

Features:

* [Multicluster - External controlplane support](https://github.com/kiali/kiali/issues/6036)
* [Multicluster - Token per cluster](https://github.com/kiali/kiali/issues/6037)
* [Tracing - Include a health_check_url for tracing external service](https://github.com/kiali/kiali/issues/7176)
* [Tracing - Update Tempo resource usage](https://github.com/kiali/kiali/issues/7185)
* [Auth - Enhancing Kiali OIDC process by supporting CSI secrets](https://github.com/kiali/kiali/issues/6942)

Fixes:

* [Kiali tracing URLs don't work with Grafana 10+](https://github.com/kiali/kiali/issues/7086)
* [Warning in workload 'istio-ingressgateway' in non control-plane namespace](https://github.com/kiali/kiali/issues/7127)
* [Distributed Tracing menu item active when there is no public URL defined](https://github.com/kiali/kiali/issues/7171)
* [Graph - crash in DeadNode appender in multi mesh-setup](https://github.com/kiali/kiali/issues/7179)

## 1.81.0
Sprint Release: Mar 01, 2024

Features:

* [Kiali Server Helm Chart Support Custom NodePort](https://github.com/kiali/kiali/issues/7093)

Fixes:

* [envoy access log entry doc links are broken](https://github.com/kiali/kiali/issues/7071)
* [Istio config href is broken](https://github.com/kiali/openshift-servicemesh-plugin/issues/251)
* [TLS information is not available](https://github.com/kiali/openshift-servicemesh-plugin/issues/253)
* [AlertUtils Kiali messages are not shown in OSSMC](https://github.com/kiali/openshift-servicemesh-plugin/issues/264)
* [Kiali operator does not preserve camel case on additional ingress labels](https://github.com/kiali/kiali/issues/7145)
* [The duration label is confusing in the Overview control plane charts](https://github.com/kiali/kiali/issues/7147)
* [Fix help text for graph Security Display option.](https://github.com/kiali/kiali/issues/7149)
* [(graph) ServiceEntry ExportTo is not handled correctly](https://github.com/kiali/kiali/issues/7153)

## 1.80.0
Sprint Release: Feb 09, 2024

Features:

* [Make support of "ExportTo" feature of Istio config configurable](https://github.com/kiali/kiali/issues/6879)
* [Use client-go's service account token client refresh](https://github.com/kiali/kiali/issues/6924)
* [Kiali v1.73.x compatible with Istio 1.20 and GW API v1](https://github.com/kiali/kiali/issues/7090)
* [Upgrade Patternfly to version 5.2](https://github.com/kiali/kiali/issues/7089)
* [Add pprof endpoints for debugging perf issues](https://github.com/kiali/kiali/issues/4597)

Fixes:

* [Multicluster - delete traffic routing on "remote" cluster 404](https://github.com/kiali/kiali/issues/7024)
* [Switching namespaces does not work on Istio Config page](https://github.com/kiali/openshift-servicemesh-plugin/issues/239)
* [Error fetching Istio deployment status of the remote control plane in the Primary remote deployment](https://github.com/kiali/kiali/issues/7053)
* [Validations: Missing KIA0005 in objects details page when wrongly exported](https://github.com/kiali/kiali/issues/7061)
* [PFT Graph not handling graph background clicks](https://github.com/kiali/kiali/issues/7077)
* [Close button on the Certificates information does not do anything](https://github.com/kiali/kiali/issues/7074)

## 1.79.0
Sprint Release: Jan 19, 2024

Features:

* [Tempo - Initial Support Complete](https://github.com/kiali/kiali/issues/5850)
* [Multicluster - provide links to external Kialis without requiring istio secrets](https://github.com/kiali/kiali/issues/6243)
* [Multicluster - Add documentation for configuring Kiali with primary-primary](https://github.com/kiali/kiali/issues/6937)
* [K8s GW API - Support of TCP/TLS/GRPC Routes](https://github.com/kiali/kiali/issues/7025)
* [K8s GW API - Support of ReferenceGrant](https://github.com/kiali/kiali/issues/6918)
* [Use the Prometheus `/-/healthy` endpoint for the default value for health_check_url](https://github.com/kiali/kiali/issues/6966)
* [Ambient - Workload graph reports the istio-waypoint proxies as "Out of Mesh" ](https://github.com/kiali/kiali/issues/7027)
* [re-enable ARM builds](https://github.com/kiali/openshift-servicemesh-plugin/issues/192)
* [Remove graph "Compress-On-Hide" Display option](https://github.com/kiali/kiali/issues/7030)

Fixes:

* [Bug after v1.72.0 release with oAuth2 strategy when DisableRBAC is true](https://github.com/kiali/kiali/issues/6677)
* [Potential runtime error in kube_cache.GetK8sGateways](https://github.com/kiali/kiali/issues/7006)
* [Prometheus retention config not resolved correctly when using defaults in prom](https://github.com/kiali/kiali/issues/5734)
* [Incorrect spacing and icon sizing in Graph Summary Panel](https://github.com/kiali/kiali/issues/6946)
* [Istio config bug](https://github.com/kiali/kiali/issues/6948)
* [kiali operator cannot determine kiali version when installing ossmc](https://github.com/kiali/kiali/issues/6950)
* [Tracing client must use the Kiali SA Token (Not the user token)](https://github.com/kiali/kiali/issues/6955)
* [Double istio rev in configmap name](https://github.com/kiali/kiali/issues/6669)
* [debug info shows incorrect log level](https://github.com/kiali/kiali/issues/6964)
* [Fix rank options in the graph](https://github.com/kiali/kiali/issues/6961)
* [Update axios HTTP client library](https://github.com/kiali/kiali/issues/6971)
* [Kiali render hostnames as individual service instead of serviceentry as whole](https://github.com/kiali/kiali/issues/6962)
* [Scrollbar in Workloads Logs view](https://github.com/kiali/kiali/issues/6982)
* [UI Error after deleting Istio Config](https://github.com/kiali/kiali/issues/7000)
* [Extra padding in long namespace names](https://github.com/kiali/kiali/issues/6998)
* [Graph: Link to App which does not exist](https://github.com/kiali/kiali/issues/7022)

## 1.78.0
Sprint Release: Dec 08, 2023

Features:

* [Update Patternfly library to version 5.1](https://github.com/kiali/kiali/issues/6768)
* [Add labels and annotations in wizards](https://github.com/kiali/kiali/issues/6806)
* [Multicluster - When istiod is unavailable portforwarding requests scale with namespaces](https://github.com/kiali/kiali/issues/5692)
* [Multicluster - Create an istio registry per primary](https://github.com/kiali/kiali/issues/6432)
* [Tempo Integration - Use select for query in Tempo 2.2 ](https://github.com/kiali/kiali/issues/6616)
* [Apply new eslint rules only to edited files](https://github.com/kiali/kiali/issues/6893)
* [(Kiali-operator Helm Chart) Mount /tmp instead of /tmp/ansible-operator/runner as emptyDir to enable read-only root filesystem](https://github.com/kiali/kiali/issues/6888)
* [Workload logs - improve appearance of checkboxes](https://github.com/kiali/kiali/issues/6811)
* [Set Secure Attribute on Session Cookie ](https://github.com/kiali/kiali/issues/6912)

Fixes:

* [Info icon in yaml editor's overview panel is not aligned properly](https://github.com/kiali/kiali/issues/6773)
* [patternfly graph not showing node decorators](https://github.com/kiali/kiali/issues/6926)
* [Kiali UI not showing API Docs](https://github.com/kiali/kiali/issues/6665)
* [(Multicluster) Not all reviews workloads are visible in Kiali ](https://github.com/kiali/kiali/issues/6780)
* [Integration tests - Kiali 1.73 is not compatible with Istio 1.20](https://github.com/kiali/kiali/issues/6858)
* [Istio 1.20 incompatibility](https://github.com/kiali/kiali/issues/6856)
* [Jaeger traces: Filter by percentile no returning any trace](https://github.com/kiali/kiali/issues/6870)
* [tracing UI - hover over trace dots "flickers" the heat map](https://github.com/kiali/kiali/issues/6881)
* [Health icon in Application summary panel graph looks weird](https://github.com/kiali/kiali/issues/6884)
* [panic when observability section does not configure the tracing endpoint correctly](https://github.com/kiali/kiali/issues/6913)
* [Show kiali own traces](https://github.com/kiali/kiali/issues/6916)
* [Disalignment in API Documentation info for Workloads and Services](https://github.com/kiali/kiali/issues/6911)
* [Link to trace does not always open trace details](https://github.com/kiali/kiali/issues/5635)

Deprecations:

* Kiali is deprecating use of the Jaeger exporter for Kiali's own traces. Kiali will move to supporting only the OTel exporter.


## 1.77.0
Sprint Release: Nov 17, 2023

Features:

* [Tempo - Wrong Distributed Tracing link for nav menu](https://github.com/kiali/kiali/issues/6795)
* [Tempo - Span query returning emptly results ](https://github.com/kiali/kiali/issues/6540)
* [PF5 - Upgrade to patternfly 5](https://github.com/kiali/kiali/issues/6438)
* [PF5 - Move table deprecated component](https://github.com/kiali/kiali/issues/6450)
* [OSSMC - add version fields to operator CSV metadata for display in OS Console UI](https://github.com/kiali/kiali/issues/6813)

Fixes:

* [helm-charts smoke test GH action fails to start](https://github.com/kiali/kiali/issues/6704)
* [Traces are duplicated across both clusters ](https://github.com/kiali/kiali/issues/6710)
* [getNamespaceMetrics includes cluster in query params](https://github.com/kiali/kiali/issues/6753)
* [(operator) only process one OSSMConsole CR](https://github.com/kiali/kiali/issues/6792)
* [ossmc package.json did not get updated version during last build](https://github.com/kiali/kiali/issues/6807)
* [empty tree entry in kiali.io installation menu and goes to incorrect place](https://github.com/kiali/kiali/issues/6787)
* [Repeatedly refreshing causes the UI to crash](https://github.com/kiali/kiali/issues/6714)
* [Extra space between left nav and top nav](https://github.com/kiali/kiali/issues/6810)
* [Multicluster - Missing cluster param in Show traces](https://github.com/kiali/kiali/issues/6815)
* [Trace link in Graph - Trace is not loaded when clicked](https://github.com/kiali/kiali/issues/6825)
* [(run-kiali) Error fetching availability of the tracing service](https://github.com/kiali/kiali/issues/6808)
* [Error deploying istio 1.20 with hack script in OpenShift](https://github.com/kiali/kiali/issues/6847)

## 1.76.0
Sprint Release: Oct 27, 2023

Features:

* [Update go version 1.20.10](https://github.com/kiali/kiali/issues/6716)
* [Tempo - Update the main external link to distributed tracing](https://github.com/kiali/kiali/issues/6687)
* [Tempo - Update documentation](https://github.com/kiali/kiali/issues/6689)
* [Tempo - Update Trace data on hover ](https://github.com/kiali/kiali/issues/6699)
* [Add cluster_name support for run-kiali.sh hack script](https://github.com/kiali/kiali/issues/6742)
* [Istio warning/error status for situations where eastwestgateway is not healthy.](https://github.com/kiali/kiali/issues/6609)
* [istio hack script: cluster name should not be set to empty string](https://github.com/kiali/kiali/issues/6751)
* [OSSMC - build and release ossmc plugin at end of sprint](https://github.com/kiali/kiali/issues/6706)
* [OSSMC - Add scrollbar environment variable](https://github.com/kiali/openshift-servicemesh-plugin/issues/208)
* [PF5 - Move deprecated component Dropdown](https://github.com/kiali/kiali/issues/6448)

Fixes:

* [Kiali Crashing in sidecar validation (without a sidecar)](https://github.com/kiali/kiali/issues/6010)
* [(CI) Test flake - workload logs](https://github.com/kiali/kiali/issues/6494)
* [Unable to reach API Server 'istio APIs and resources are not present in cluster (Kubernetes)'](https://github.com/kiali/kiali/issues/6598)
* [Multi mesh setup results in an error when fetching workloads](https://github.com/kiali/kiali/issues/6772)
* [Double istio rev in configmap name](https://github.com/kiali/kiali/issues/6669)
* [Selecting a trace in the Graph does not mark the edges when using Tempo ](https://github.com/kiali/kiali/issues/6674)
* [Service of a remote app/workload is not reported in the detail view](https://github.com/kiali/kiali/issues/6682)
* [Tempo - Incomplete span data](https://github.com/kiali/kiali/issues/6693)
* [Invalid AuthorizationPolicy generated from Overview page ](https://github.com/kiali/kiali/issues/6702)
* [Envoy is duplicated across both clusters](https://github.com/kiali/kiali/issues/6711)
* [Traffic tab in Apps details is duplicated for both clusters](https://github.com/kiali/kiali/issues/6712)
* [(ci) need to fix CI script for running molecule tests on openshift](https://github.com/kiali/kiali/issues/6738)
* [Gateway badge is not being applied to gateways in the graph](https://github.com/kiali/kiali/issues/6740)
* [Inbound Metrics tab for the Service detail is duplicated for services in different clusters](https://github.com/kiali/kiali/issues/6745)
* [setup-kind-ci.sh script fails if it is not executed from root folder](https://github.com/kiali/kiali/issues/6750)

## 1.75.0
Sprint Release: Oct 06, 2023

Features:

* [GW API Multiple implementations](https://github.com/kiali/kiali/issues/6429)
* [Support K8s native sidecars](https://github.com/kiali/kiali/issues/6130)
* [PF5 Move deprecated Select](https://github.com/kiali/kiali/issues/6449)
* [Tempo tempo reading traces](https://github.com/kiali/kiali/issues/5849)
* [Tempo Rename to Tracing instead of Jaeger when applicable ](https://github.com/kiali/kiali/issues/6537)
* [Tempo Update hack script to support OpenShift](https://github.com/kiali/kiali/issues/6663)
* [Focus selector support in PF graph](https://github.com/kiali/openshift-servicemesh-plugin/issues/203)
* [Include Ambient annotations as configuration settings](https://github.com/kiali/kiali/issues/6522)
* [FAQ on how to get Kiali and Istio versions](https://github.com/kiali/kiali/issues/6599)

Fixes:

* [Remote cluster istio-system namespace card show data from primary control plane](https://github.com/kiali/kiali/issues/6437)
* ["Cannot load the graph: json: cannot unmarshal object into Go value of type ()*kubernetes.RegistryEndpoint"](https://github.com/kiali/kiali/issues/6510)
* [Multicluster - Traffic routings created via Graph page are always located in the local cluster](https://github.com/kiali/kiali/issues/6615)
* [Breadcrumb click on Istio Type filter - Filter type is reset](https://github.com/kiali/kiali/issues/6632)
* [Grafana, Ingress, Egress pods not running in Openshift after installing istio via istioctl](https://github.com/kiali/kiali/issues/6635)
* [K8sGateway Validations - Inconsistency in lists](https://github.com/kiali/kiali/issues/6633)
* [Little disalignments in Kiali UI](https://github.com/kiali/kiali/issues/6639)
* [Wrong cluster when double tapping on a service/application in node graph](https://github.com/kiali/kiali/issues/6657)
* [molecule tests are broken due to upstream galaxy changes](https://github.com/kiali/kiali/issues/6670)
* [Annotation wizard behaviour is not correct when user add/deletes some annotations](https://github.com/kiali/kiali/issues/6676)

## 1.74.0
Sprint Release: Sep 15, 2023

Features:

* [Added support of multiple Gateway API classes](https://github.com/kiali/kiali/issues/6429)
* [Ensure Tempo works using jaeger-query](https://github.com/kiali/kiali/issues/5848)
* [Update Releasing doc](https://github.com/kiali/kiali/issues/6526)
* [Adjust PFT graph-tour](https://github.com/kiali/openshift-servicemesh-plugin/issues/202)
* [document minimum helm version](https://github.com/kiali/kiali/issues/6566)
* [Make Kiali compatible with OSSMC](https://github.com/kiali/kiali/issues/6261)
* [Minimal upgrade to PF5](https://github.com/kiali/kiali/issues/6446)

Fixes:

* [Duplicate test ID related to Overview page in Multicluster mode](https://github.com/kiali/kiali/issues/6398)
* [PFGraph throws console error when hovering an application label](https://github.com/kiali/kiali/issues/6458)
* [Graph not showing traffic from portals to travels in west cluster](https://github.com/kiali/kiali/issues/6492)
* [IstioType in istioconfigList is propagated to other views](https://github.com/kiali/kiali/issues/6512)
* [kiali pod stay in Error status after node shutdown](https://github.com/kiali/kiali/issues/6535)
* [Graph side-panel has multi-cluster issues](https://github.com/kiali/kiali/issues/6544)
* [(make) work around opm render bug when building for OLM](https://github.com/kiali/kiali/issues/6545)
* [Double tap on a node redirects to wrong cluster](https://github.com/kiali/kiali/issues/6548)
* [UI issues in Graph replay for OSSMC](https://github.com/kiali/kiali/issues/6561)
* [Sorting by cluster does not work in the list view located in the Overview page](https://github.com/kiali/kiali/issues/6504)

## 1.73.0
Sprint Release: Aug 25, 2023

Features:

* [Tutorial for Multicluster](https://github.com/kiali/kiali/issues/6306)
* [Support for dark mode](https://github.com/kiali/kiali/issues/6268)
* [Ambient for Istio 1.19, experimental support](https://github.com/kiali/kiali/issues/6401)
* [Fixed help icon in Envoy tab](https://github.com/kiali/kiali/issues/6502)
* [Update Releasing doc](https://github.com/kiali/kiali/issues/6526)
* [OSSMC: update user guide/install guide for 0.4.0](https://github.com/kiali/openshift-servicemesh-plugin/issues/195)

Fixes:

* [Incorrect save commit may be triggered while editing yaml](https://github.com/kiali/kiali/issues/6374)
* [Data race when accessing `IsGatewayAPI`](https://github.com/kiali/kiali/issues/6387)
* [Kiali Istio Config page -- KIA0104 validation (failed)](https://github.com/kiali/kiali/issues/6460)
* [Traffic tab - 'View metrics' link broken](https://github.com/kiali/kiali/issues/6462)
* [Wrong cluster badge shown in the page for reviews app detail when accessing it from a graph](https://github.com/kiali/kiali/issues/6464)
* [Multicluster - Namespace Validations in Graph](https://github.com/kiali/kiali/issues/6467)
* [operator installed via OLM cannot set kiali server pod securityContext.readOnlyRootFilesystem to false](https://github.com/kiali/kiali/issues/6481)
* [Kiali fails on OCP cluster](https://github.com/kiali/kiali/issues/6517)

## 1.72.0
Sprint Release: Aug 04, 2023

Features:

* [Remove option to disable kube caching](https://github.com/kiali/kiali/issues/5599)
* [Multi-cluster view for Istio config wizards](https://github.com/kiali/kiali/issues/5923)
* [Multi-cluster - hack scripts work with kind](https://github.com/kiali/kiali/issues/6358)
* [K8s Gateway API - improve graph support](https://github.com/kiali/kiali/issues/6397)
* [create Istio configs for services in Ambient Namespace](https://github.com/kiali/kiali/issues/6423)

Fixes:

* [Multi-cluster Some pages are broken when meshID is not set](https://github.com/kiali/kiali/issues/6249)
* [Unwanted "fit" on refresh](https://github.com/kiali/kiali/issues/6248)
* [Helm Chart 1.66.1 is missing](https://github.com/kiali/kiali/issues/6362)
* [Multicluster - unbound variable in kiali-deploy](https://github.com/kiali/kiali/issues/6366)
* [App health - Inconsistency in Overview page](https://github.com/kiali/kiali/issues/6372)
* [Kiali pod fails to start because of "failed to list *v1beta1.Gateway: gateways.gateway.networking.k8s.io is forbidden"](https://github.com/kiali/kiali/issues/6380)
* [openshift auth logout not behaving](https://github.com/kiali/kiali/issues/6381)
* [Traces tab - 500 errors](https://github.com/kiali/kiali/issues/6405)
* [Service Traffic Wizard - Autogenerated Gateways shown](https://github.com/kiali/kiali/issues/6404)
* [(hack) run-kiali.sh not working with OpenShift](https://github.com/kiali/kiali/issues/6402)
* [Slider CSS affects Openshift console look and feel (OSSMC plugin)](https://github.com/kiali/kiali/issues/6417)
* [Add global typestyle to OSSMC top HTML element](https://github.com/kiali/openshift-servicemesh-plugin/issues/180)
* [Convert all custom static CSS to typestyle](https://github.com/kiali/kiali/issues/6349)

## 1.71.0
Sprint Release: Jul 14, 2023

Features:

* [Multicluster - Config validation from remote cluster](https://github.com/kiali/kiali/issues/6056)
* [Add documentation for 'Kiali Internal Metrics' dashboard](https://github.com/kiali/kiali/issues/5984)
* [Operator - speed up the setting up of configuration](https://github.com/kiali/kiali/issues/6132)
* [Align Patternfly version with Openshift 4.13](https://github.com/kiali/kiali/issues/6270)
* [Auto-enable find/hide filters via Kiali CR](https://github.com/kiali/kiali/issues/6012)
* [Add edit actions in contextual menu for remote clusters ](https://github.com/kiali/kiali/issues/6330)
* [Get rid of the experimental warning in the Mesh section](https://github.com/kiali/kiali/issues/6338)

Fixes:

* [Graph IdleNodes option is broken](https://github.com/kiali/kiali/issues/6331)
* [Grafana link is not available in Kiali](https://github.com/kiali/kiali/issues/5988)
* [Cluster and ClusterName params in the same API url](https://github.com/kiali/kiali/issues/6328)
* [kiali_feature_flags.clustering.autodetect_secrets.label default is incorrect](https://github.com/kiali/kiali/issues/6344)
* [Incorrect ServiceAccount used for Multi-cluster when using OpenID without RBAC](https://github.com/kiali/kiali/issues/6308)

## 1.70.0
Sprint Release: Jun 23, 2023

Features:

* [Update Kiali to build with Go 1.20](https://github.com/kiali/kiali/issues/6218)
* [Use ExecPlugin for remote cluster secret](https://github.com/kiali/kiali/issues/6193)
* [Multicluster - add kiali.io docs](https://github.com/kiali/kiali/issues/5928)
* [Blog post for Multicluster](https://github.com/kiali/kiali/issues/6214)
* [Video demo for multi cluster](https://github.com/kiali/kiali/issues/6236)
* [Multicluster - Edit Istio Configs in remote clusters](https://github.com/kiali/kiali/issues/6239)
* [show more control plane info in OverView page](https://github.com/kiali/kiali/issues/6177)
* [Verify Kiali using Istio 1.18 Ambient alpha](https://github.com/kiali/kiali/issues/6241)
* [Upgrade Typescript version](https://github.com/kiali/kiali/issues/6267)

Fixes:

* [Using LISTENER_FILTER within an EnvoyFilter leads to a cache error](https://github.com/kiali/kiali/issues/6285)
* [K8Gateway object not visible in the Istio Config List. ](https://github.com/kiali/kiali/issues/6253)
* [Wrong IstioObject field types](https://github.com/kiali/kiali/issues/6011)
* [Create ServiceEntry - Required Ports - Empty Accepted](https://github.com/kiali/kiali/issues/6287)
* [Service details of ServiceEntry fails](https://github.com/kiali/kiali/issues/6294)
* [kiali.io Architecture is outdated - direct istio dependency](https://github.com/kiali/kiali/issues/5376)

## 1.69.0
Sprint Release: Jun 02, 2023

Features:

* [Multicluster - details Views](https://github.com/kiali/kiali/issues/5920)
* [Multicluster - Remove warning "Not all remote clusters have reachable Kiali instances"](https://github.com/kiali/kiali/issues/6102)
* [Multicluster - Overview page istio status](https://github.com/kiali/kiali/issues/6169)
* [Multicluster - Add contextual menu in the nodes for the remote cluster](https://github.com/kiali/kiali/issues/6150)
* [Multicluster - Add cluster column in traffic details tab](https://github.com/kiali/kiali/issues/6152)
* [Graph - Improve graph node labels - remove parentheses](https://github.com/kiali/kiali/issues/6123)
* [Operator - Add new server configuration for ClusterName](https://github.com/kiali/kiali/issues/6137)

Fixes:

* [UI - Styling in the Overview page in the UI for cards with long namespace names pushes out kebab menu into adjacent card](https://github.com/kiali/kiali/issues/6133)
* [Multicluster Workload list - Wrong details column content](https://github.com/kiali/kiali/issues/6136)
* [edge colors get "stuck" as yellow / red after service health recovers](https://github.com/kiali/kiali/issues/6138)
* [Workload List gets Validations from backend but do not use them](https://github.com/kiali/kiali/issues/6020)
* [Multicluster Graph page - Validations error in logs](https://github.com/kiali/kiali/issues/6117)
* [Typo in accessibleNamespaces field of server config get API](https://github.com/kiali/kiali/issues/6160)
* [Multicluster support Namespace Validations](https://github.com/kiali/kiali/issues/6161)
* [Failed to update kiali-server helm chart value view_only_mode in standalone Kiali installation](https://github.com/kiali/kiali/issues/6139)
* [Multicluster - Propagate Cluster param in graph nodes](https://github.com/kiali/kiali/issues/6171)
* [need to document the auth.openshift settings](https://github.com/kiali/kiali/issues/6176)
* [support openshift route over non-standard port](https://github.com/kiali/kiali/issues/6180)
* [Graph - hiding an entire namespace or cluster keeps the namespace/boxes](https://github.com/kiali/kiali/issues/6184)
* [After navigating to the Service graph, all other graphs are displayed with injectServiceNodes=false](https://github.com/kiali/kiali/issues/6098)
* [Multicluster - Add sort by Cluster column](https://github.com/kiali/kiali/issues/6179)
* [Multi-cluster graph - error when user lacks access to remote cluster](https://github.com/kiali/kiali/issues/6185)

## 1.68.0
Sprint Release: May 12, 2023

Features:

* [Kiali initial Istio Ambient support](https://github.com/kiali/kiali/issues/5910)
* [Multi-cluster List Views ](https://github.com/kiali/kiali/issues/5919)
* [Multi-cluster view for overview page](https://github.com/kiali/kiali/issues/5921)
* [Multi-cluster list view - Istio Config](https://github.com/kiali/kiali/issues/5962)
* [Multi-cluster Update the namespace health service](https://github.com/kiali/kiali/issues/6028)
* [Multi-cluster Services details view](https://github.com/kiali/kiali/issues/5964)
* [Multi-cluster Workloads details view](https://github.com/kiali/kiali/issues/5965)
* [Multi-cluster Istio config details view](https://github.com/kiali/kiali/issues/5967)
* [Multi-cluster Health calculation for workload/app/svc](https://github.com/kiali/kiali/issues/6026)
* [Multi-cluster Applications details view](https://github.com/kiali/kiali/issues/5966)
* [Operator Remove ansible loops for better performance](https://github.com/kiali/openshift-servicemesh-plugin/issues/144)
* [Update log level getting istio-cni-config configmap](https://github.com/kiali/kiali/issues/6103)
* [Cluster badges in details pages should be only visible in Multi cluster ](https://github.com/kiali/kiali/issues/6107)
* [Cypress test coverage for #5718](https://github.com/kiali/kiali/issues/5934)
* [Cypress Add validation references to K8S Gateways validations](https://github.com/kiali/kiali/issues/5868)


Fixes:

* [Multi-cluster - Istio Configs duplicated](https://github.com/kiali/kiali/issues/6063)
* [Client generating 503 metric requests for some node graphs](https://github.com/kiali/kiali/issues/6068)
* [no_istiod_test integration test is not working in ocp](https://github.com/kiali/kiali/issues/6071)
* [Operator Support ingress override_yaml to set OpenShift Route spec.host](https://github.com/kiali/kiali/issues/6083)
* [Crash in graph appender due to excluded namespace](https://github.com/kiali/kiali/issues/6084)
* [Improve Grafana integration documentation](https://github.com/kiali/kiali/issues/6082)
* [Cache tries to list cluster scoped resource but it is namespace scoped](https://github.com/kiali/kiali/issues/6114)
* [hardcoded label name](https://github.com/kiali/kiali/issues/6124)

## 1.67.0
Sprint Release: Apr 21, 2023

Features:

* [Support for Istio's discoverySelectors](https://github.com/kiali/kiali/issues/3914)
* [Updated documentatation for Namespace Management (discovery selectors, cluster-wide-access, accessible namespaces_ and namespace watching](https://github.com/kiali/kiali/issues/6054)
* [(operator) use "include_tasks:", not the deprecated "include:"](https://github.com/kiali/kiali/issues/5931)
* [Multi-cluster - way to create roles/SA in remote clusters](https://github.com/kiali/kiali/issues/5987)
* [Multi-cluster - Home cluster name should match Istio cluster name](https://github.com/kiali/kiali/issues/6001)
* [Multi-cluster - Combine duplicated namespaces in dropdown selector](https://github.com/kiali/kiali/issues/6007)
* [Multi-cluster - list view - Services](https://github.com/kiali/kiali/issues/5960)
* [Multi-cluster - list view - Applications](https://github.com/kiali/kiali/issues/5961)

Fixes:

* [List page toggles to help with performance issues with the Kiali UI](https://github.com/kiali/kiali/issues/5867)
* [Missing horizontal scrollbar when seeing logs](https://github.com/kiali/kiali/issues/5989)
* [validation error (KIA0202) for auto generated destination rule](https://github.com/kiali/kiali/issues/5991)
* [Perf regression when fetching workloads](https://github.com/kiali/kiali/issues/6000)
* [validation error (KIA0401) when AutoMtls is enabled in istio MeshConfig](https://github.com/kiali/kiali/issues/6006)
* [CRD does not validate correctly](https://github.com/kiali/kiali/issues/6015)
* [Error fetching app health when a namespace only exist in the remote clusters ](https://github.com/kiali/kiali/issues/6044)

Notes:

* There have been changes to Namespace Management.  The changes are backward compatible but it is recommended to understand the changes regarding Discovery Selector support, cluster-wide access, and accessible-namespaces.  For more see [here](https://kiali.io/docs/configuration/rbac/).

Deprecations:

* The following settings are deprecated and may be removed in a future release:
  * api.namespaces.exclude
  * api.namespaces.include
  * api.namespaces.label_selector_exclude
  * api.namespaces.label_selector_include

It is recommended to instead use Istio Discovery Selectors to limit the namespaces in the mesh.


## 1.66.1
Sprint Release: Mar 31, 2023

Features:

* [make - run-operator should enable the profiler](https://github.com/kiali/kiali/issues/5950)
* [No install-crd reference on README](https://github.com/kiali/openshift-servicemesh-plugin/issues/127)
* [Multicluster - list view - Workloads](https://github.com/kiali/kiali/issues/5959)
* [Multicluster - Services view](https://github.com/kiali/kiali/issues/5943)
* [Multicluster - Hack script for setup a primary-remote scenario](https://github.com/kiali/kiali/issues/5925)
* [Multicluster - Update each business layer to read from each configured backend kube cluster](https://github.com/kiali/kiali/issues/5764)
* [Multicluster - Kiali supports reading from/writing to multiple clusters](https://github.com/kiali/kiali/issues/5701)
* [Multicluster - Update the namespace cache which caches the user token per namespace](https://github.com/kiali/kiali/issues/5766)
* [Multicluster - distributed errors demo for testing](https://github.com/kiali/kiali/pull/5927)
* [Multicluster - Modify the Kube Cache to allow whether to cache Istio types](https://github.com/kiali/kiali/issues/5939)
* [core-ui - Need the configuration and endpoints](https://github.com/kiali/openshift-servicemesh-plugin/issues/114)
* [core-ui - Remove IstioConfigList elements and pull them from library](https://github.com/kiali/openshift-servicemesh-plugin/issues/119)

Fixes:

* [Error fetching Istiod resource thresholds on Web UI](https://github.com/kiali/kiali/issues/5742)
* [make - Error to create operator pull secret](https://github.com/kiali/kiali/issues/5945)
* [Missing scraping parameters in kiali-operator helm chart](https://github.com/kiali/kiali/issues/5949)
* [ansible option we use in operator code is being renamed](https://github.com/kiali/kiali/issues/4338)
* [CORS issue with library API](https://github.com/kiali/openshift-servicemesh-plugin/issues/124)
* [fix flaky test failure](https://github.com/kiali/kiali/issues/5972)

Notes:

* To avoid a known performance degradation, update to v1.66.1 (or later) from v1.66.0.

Deprecations:

* Given that the Kiali cache is now mandatory and that there have been several changes to the cache implementation, the .spec.kubernetes_config.cache_* settings have all deprecated and will be removed from the CRD. It is recommended to remove these settings from your CR, if defined.

## 1.65.0
Sprint Release: Mar 10, 2023

Features:

* [K8sGateway Object Validation - Add References](https://github.com/kiali/kiali/issues/5769)
* [Improve KIA0301 (more than one gateway warning) to treat a single * as not a warning](https://github.com/kiali/kiali/issues/5711)
* [document how to upgrade Go in the Kiali builds](https://github.com/kiali/kiali/issues/5818)
* [Error page could be more than just a text message](https://github.com/kiali/kiali/issues/5862)
* [log the version of go that was used to build the server](https://github.com/kiali/kiali/issues/5878)

Fixes:

* [remove monitoringdashboard CRD (when supporting kiali >= 1.25)](https://github.com/kiali/kiali/issues/5372)
* [bad printf - missing param](https://github.com/kiali/kiali/issues/5859)
* [Istio 1.17.0 image is not available in gcr.io](https://github.com/kiali/kiali/issues/5846)
* [Istio Config doesn't show correct yaml for Sidecar OutboundTrafficPolicy.Mode](https://github.com/kiali/kiali/issues/5882)
* [Application crash when accessing service from K8s Gateway](https://github.com/kiali/kiali/issues/5864)
* [envoy listeners tab - match column shows does not show correct dest port when destination_port is specified](https://github.com/kiali/kiali/issues/5872)
* [navigating from envoy listeners tab to a named route incorrectly highlights the clusters tab](https://github.com/kiali/kiali/issues/5871)
* [Don't let the graph generation panic on bad telemetry](https://github.com/kiali/kiali/issues/5890)

# 1.64.0
Sprint Release: Feb 17, 2023

Features:

* [Mesh wide settings should take the MeshConfig defaults](https://github.com/kiali/kiali/issues/5263)
* [Don't use the anonymous account to fetch cluster version (OpenShift authentication)](https://github.com/kiali/kiali/issues/5755)
* [Editable Istio config annotations for workloads and services](https://github.com/kiali/kiali/issues/4179)
* [Configure Kiali timeouts while fetching traces from jaeger](https://github.com/kiali/kiali/issues/5751)
* [Build Kiali with a newer minor version of Golang](https://github.com/kiali/kiali/issues/5799)
* [K8s GW API Support  - v1alpha2 is deprecated](https://github.com/kiali/kiali/issues/5797)
* [document for contributors in operator and helm chart repos](https://github.com/kiali/kiali/issues/5808)
* [Consistent way to resolve Kiali version from Istio version](https://github.com/kiali/kiali/issues/5823)
* [reponse type id_token check in Open ID authentication is no longer needed](https://github.com/kiali/kiali/issues/5833)
* [Pod labels for Kiali Operator Helm Chart](https://github.com/kiali/kiali/issues/5832)

Fixes:

* [(Cypress) Improve test coverage for Istio Config Wizards](https://github.com/kiali/kiali/issues/5811)
* [Format frontend code with prettier standards](https://github.com/kiali/kiali/issues/5815)
* [remove implicit flow from documentation](https://github.com/kiali/kiali/issues/5813)
* [Remove @webcomponents/custom-elements from package.json since Firefox ESR supports it natively](https://github.com/kiali/kiali/issues/5805)
* [remove compat matrix/version checking](https://github.com/kiali/kiali/issues/5788)
* [Rework RBAC documentation](https://github.com/kiali/kiali/issues/5720)
* [Form to add port should start empty](https://github.com/kiali/kiali/issues/5741)
* [No istiod: Disable validations also in the Overview page](https://github.com/kiali/kiali/issues/5762)
* [Investigate possible flaky test in Cypress suite](https://github.com/kiali/kiali/issues/5770)
* [Graphs loading very slowly](https://github.com/kiali/kiali/issues/5743)
* [Remove "Labels" in Create K8s Gateway Wizard](https://github.com/kiali/kiali/issues/5790)
* [Prettier pre-commit hook is not working correctly](https://github.com/kiali/kiali/issues/5803)
* [Wrong engine node version in package.json](https://github.com/kiali/kiali/issues/5208)
* [Internal server error when creating a Gateway with a duplicate name in the Istio Config Wizard](https://github.com/kiali/kiali/issues/5830)
* [Read-only YAML editor in Istio Config even with write privileges](https://github.com/kiali/kiali/issues/5836)
* [Duplicate IDs for the text inputs + high port value breaks the UI (Istio Config wizard page)](https://github.com/kiali/kiali/issues/5834)

## 1.63.2
Sprint Release: Feb 02, 2023

Features:

* [Validations for Gateway API objects](https://github.com/kiali/kiali/issues/5501)
* [Kiali without Istio API using istio_api_enabled=false](https://github.com/kiali/kiali/issues/5626)
* [Gateway API Objects - Include in wizards](https://github.com/kiali/kiali/issues/5502)
* [upgrade operator base image to 4.12](https://github.com/kiali/kiali/issues/5657)
* [References for k8s httpRoute](https://github.com/kiali/kiali/issues/5709)
* [References for K8s Gateways](https://github.com/kiali/kiali/issues/5708)
* [Add dates in chart tooltips](https://github.com/kiali/kiali/issues/5320)
* [(CI) Gateway API in CI](https://github.com/kiali/kiali/issues/5719)
* [(CI) Gateway API Integration tests.](https://github.com/kiali/kiali/issues/5726)
* [(cypress) Gateway API in Cypress tests.](https://github.com/kiali/kiali/issues/5753)
* [Multicluster - Hack script to setup local multicluster with OIDC](https://github.com/kiali/kiali/issues/5702)
* [Multicluster - cluster configuration](https://github.com/kiali/kiali/issues/5738)

Fixes:

* [Kiali view-only mode allows changing proxy log-level](https://github.com/kiali/kiali/issues/5714)
* [Workload auto-injection of proxy should ensure label and annotation settings don't conflict](https://github.com/kiali/kiali/issues/5713)
* [Upgrade error on role switch for view-only](https://github.com/kiali/kiali/issues/5695)
* [hide "enable injection" menu option in Overview page when in OSSM](https://github.com/kiali/kiali/issues/5725)
* [KIA0106 false positive with wildcard](https://github.com/kiali/kiali/issues/5729)
* [IRC link on kiali.io is not working](https://github.com/kiali/kiali/issues/5739)
* [Service with K8s Gateway - Inconsistency between views](https://github.com/kiali/kiali/issues/5757)

Notes:

* Helm 3.10 is now required to run the Helm Charts.
* To avoid a known performance degradation, update to v1.63.2 (or later) from earlier revisions of v1.63.

Deprecations:

* [The deprecated support for OpenID's _implicit flow_ has now been removed.](https://github.com/kiali/kiali/issues/4705) If necessary, you must switch to using the more secure _authorization code flow_.

## 1.62.1
Sprint Release: Feb 02, 2023

Features:

* [Test the new native stats runtime by setting TELEMETRY_USE_NATIVE_STATS to "true" in istiod](https://github.com/kiali/kiali/issues/5660)
* [Kiali CR definition to allow the use of appProtocol in the service configuration](https://github.com/kiali/kiali/issues/5670)
* [Show Kiali configuration in the application](https://github.com/kiali/kiali/issues/5588)

Fixes:

* [Kiali may prevent istiod from becoming ready on initial startup of istiod pod](https://github.com/kiali/kiali/issues/5669)
* [Kiali errors out loading workload graph in 'default' namespace ](https://github.com/kiali/kiali/issues/5696)

Notes:

* To avoid a known performance degradation, update to v1.62.1 (or later) from v1.62.0.

Deprecations:

* The [experimental support for multicluster deployment models](https://kiali.io/docs/features/multi-cluster/) is now deprecated and may be removed in a future release. [New multicluster features](https://github.com/kiali/kiali/issues/5618) are currently being developed within the Kiali community as a replacement.

## 1.61.0
Sprint Release: Dec 16

Features:

* [Kiali SA should use view-only role unless using anonymous strategy](https://github.com/kiali/kiali/issues/5611)
* [openshift auth timeout customizations](https://github.com/kiali/kiali/issues/5650)

Fixes:

* [Kiali distroless version breaks external https calls](https://github.com/kiali/kiali/issues/5643)
* [Redirect Loop on OpenID Connect Failures](https://github.com/kiali/kiali/issues/5663)
* [Update GH pipelines removing deprecated warnings](https://github.com/kiali/kiali/issues/5646)

## 1.60.0
Sprint Release: Nov 25

Features:

* [Add Kiali validations on Istio Detail pages ](https://github.com/kiali/openshift-servicemesh-plugin/issues/52)
* [Bump go version to 1.18](https://github.com/kiali/kiali/issues/5561)
* [Indicate the status of a canary upgrade in the control plane card](https://github.com/kiali/kiali/issues/5524)
* [Kiali traffic wizard](https://github.com/kiali/kiali/issues/5578)
* [Control Plane Card - Min TLS Improvement](https://github.com/kiali/kiali/issues/5597)
* [document how to specify digest images in the Kiali CR and helm chart](https://github.com/kiali/kiali/issues/5622)

Fixes:

* [(CI) Test Flake - TestCreateSessionNoChunks](https://github.com/kiali/kiali/issues/5197)
* [Min TLS Version - React Warning](https://github.com/kiali/kiali/issues/5623)
* [(kiali.io) Aditional CI issues](https://github.com/kiali/kiali/issues/5631)
* [Kiali heatmap tooltips are too compute-heavy](https://github.com/kiali/kiali/issues/5634)

Deprecations:

* [Support for OpenID's _implicit flow_ is deprecated and will be removed soon.](https://github.com/kiali/kiali/issues/4705) Please, switch to using the _authorization code flow_ which is more secure.

Known Issues:

With the move to a distroless container in v1.59, [root CA certificates went missing](https://github.com/kiali/kiali/issues/5643). This affects the Kiali integration with OpenID. The problem will be fixed in the next release (v1.61).  The workaround is to use one of the "-distro" image tags found on the [Quay.io repo](https://quay.io/repository/kiali/kiali?tab=tags) by specifying it in the `deployment.image_version` setting of the [Kiali CR](https://kiali.io/docs/configuration/kialis.kiali.io/#.spec.deployment.image_version) or [server helm chart value](https://github.com/kiali/helm-charts/blob/v1.60.0/kiali-server/values.yaml#L48). If using the operator, in order to be able to set the `deployment.image_version` within the Kiali CR, you must [enable the allowAdHocKialiImage setting](https://github.com/kiali/helm-charts/blob/v1.60.0/kiali-operator/values.yaml#L66-L70) when installing the operator.

## 1.59.0
Sprint Release: Nov 4, 2022

Features:

* [Validate that Kiali installs as an add-on for Ambient](https://github.com/kiali/kiali/issues/5504)
* [Migrate the control plane related information from the masthead to the control plane card ](https://github.com/kiali/kiali/issues/5525)
* [switch the published images to be distroless](https://github.com/kiali/kiali/issues/5508)
* [Add TLS min version to the Control Plane card in the Overview Page](https://github.com/kiali/kiali/issues/5528)
* [Helm charts installation doesn't work on Apple M1](https://github.com/kiali/kiali/issues/5580)
* [mount secret data from files, not environment variables](https://github.com/kiali/kiali/issues/5591)
* [Filter "istio" GatewayClassName Gateway API gateways](https://github.com/kiali/kiali/issues/5594)

Fixes:

* [Config Create Wizard - Preview shows old state ](https://github.com/kiali/kiali/issues/5546)
* [(Cypress) Fix kiali login test on openshift](https://github.com/kiali/kiali/issues/5568)
* [Kiali dashboard freezes when checking traces information](https://github.com/kiali/kiali/issues/5584)

## 1.58.0
Sprint Release: Oct 14, 2022

Features:

* [openid strategy should not show login page: where are kiali's autologin options?](https://github.com/kiali/kiali/issues/5232)
* [Add Kiali validation on Istio Config list](https://github.com/kiali/openshift-servicemesh-plugin/issues/45)
* [Can we exclude the some accessible namespaces in kiali CR with some labelSelector?](https://github.com/kiali/kiali/issues/5516)
* [Add Argocd Rollout as workload type to Kiali.](https://github.com/kiali/kiali/issues/5261)
* [Badging gateway api gateways correctly on the graph](https://github.com/kiali/kiali/issues/5490)

Fixes:

* ["KIA0203 This subset's labels are not found in any matching host" For Argo Rollout canary scenario](https://github.com/kiali/kiali/issues/4210)
* [Links to ServiceMesh tabs should propagate interval and refresh parameters](https://github.com/kiali/openshift-servicemesh-plugin/issues/53)
* [Duration in Overview tab from details pages not refreshing](https://github.com/kiali/openshift-servicemesh-plugin/issues/94)
* [(CI) Test flake - Kiali Graph page - Find/Hide](https://github.com/kiali/kiali/issues/5465)
* [Control Plane Card icon overlapping ](https://github.com/kiali/kiali/issues/5495)
* [(CI) Test flake - Service Details Traces - Spans](https://github.com/kiali/kiali/issues/5499)
* [Jaeger - namespace_selector not working for services in istio-system](https://github.com/kiali/kiali/issues/4935)
* [(Cypress) login using default authentication method does not work](https://github.com/kiali/kiali/issues/5540)

## 1.57.0
Sprint Release: Sep 23

Features:

* [Optimize the Kiali Cache design under cluster rights presence](https://github.com/kiali/kiali/issues/4678)
* [Reorganize the Overview page to better show data plane vs control plane status](https://github.com/kiali/kiali/issues/5167)
* [Plugin time interval+refresh controls on detail pages](https://github.com/kiali/openshift-servicemesh-plugin/issues/42)
* [Initial Release of OSSMC](https://github.com/kiali/kiali/issues/5451)
* [Relax "missing label" wording in tooltips](https://github.com/kiali/kiali/issues/5368)
* [missing version and commit info in log output](https://github.com/kiali/openshift-servicemesh-plugin/issues/90)
* [make container securityContext configurable](https://github.com/kiali/kiali/issues/5455)
* [Move Kiali<->Istio version checks to the "About" dialog](https://github.com/kiali/kiali/issues/5457)
* [Added K8s Gateway API objects to Istio Config list page](https://github.com/kiali/kiali/issues/5485)
* [Enable github pipeline to run integration tests with token auth enabled](https://github.com/kiali/kiali/issues/5082)

Fixes:

* [Revisit "round timeseries on client-side with significant decimals"](https://github.com/kiali/kiali/issues/5432)
* [(CI) Test flake - Service details page](https://github.com/kiali/kiali/issues/5358)
* [(hack) setup kind in ci finalising with error](https://github.com/kiali/kiali/issues/5441)
* [(CI) Test flake - workload details](https://github.com/kiali/kiali/issues/5407)
* [(CI) Test Flake - TestConcurrentClientExpiration](https://github.com/kiali/kiali/issues/5196)
* [(CI) Test flake - The degraded status of a service is reported in the list of service](https://github.com/kiali/kiali/issues/5226)
* [(CI) Test flake - Sidebar toggle](https://github.com/kiali/kiali/issues/5437)
* [Upgrade operator base image to 4.11](https://github.com/kiali/kiali/issues/5459)
* [Change istioctl install hack script to default to single cluster settings](https://github.com/kiali/kiali/issues/5248)

Upgrade Notes:

The [improved control plane card on the Overview page](https://github.com/kiali/kiali/issues/5167) makes use of previously unused
metrics.  If these metrics have been removed from your environment you will need to add them back for the feature to work.  As a result,

|Metric                                      |Notes|
|--------------------------------------------|-----|
|process_cpu_seconds_total                   |used to graph cpu usage in the control plane overview card |
|container_memory_working_set_bytes          |used to graph memory usage in the control plane overview card |
|pilot_proxy_convergence_time_sum            |used in control plane overview card to show the average proxy push time |
|pilot_proxy_convergence_time_count          |used in control plane overview card to show the average proxy push time |

<br />

If these metrics have been removed from your environment you will need to add them back for the feature to work.  As a result,
we have updated our recommended Prometheus metric thinning configuration.  See [kiali.io](https://kiali.io/docs/configuration/p8s-jaeger-grafana/prometheus/#metric-thinning)
for the updated configuration.  The metrics used are not typically very heavy and adding them back should likely not be an issue.

See [this FAQ entry](https://kiali.io/docs/faq/general/#requiredmetrics) for a list of all metrics required by Kiali.

## 1.56.0
Sprint Release: Sep 2

Features:

* [Support single cluster traces view when using Jaeger with multi-cluster storage backend](https://github.com/kiali/kiali/issues/4635)
* [add capabilities-drop explicitly to deployment](https://github.com/kiali/kiali/issues/5399)
* [Support Telemetry and WasmPlugin Istio objects](https://github.com/kiali/kiali/issues/5274)
* [Plugin service actions on details pages](https://github.com/kiali/openshift-servicemesh-plugin/issues/43)

Fixes:

* [k8s api token not auto refreshing (aws eks warning)](https://github.com/kiali/kiali/issues/5070)

## 1.55.0
Sprint Release: August 12, 2022

Features:

* [(scalability) How to thin metrics to those required only by Kiali](https://github.com/kiali/kiali/issues/5151)
* [Launch Kiali wizard scenarios from graph nodes](https://github.com/kiali/kiali/issues/4505)
* [Milliseconds precision for sorting log entries in the Logs tab](https://github.com/kiali/kiali/issues/5246)
* [Istio Workload Config Validation Optimization](https://github.com/kiali/kiali/issues/5153)
* [Customizable links in Kiosk mode](https://github.com/kiali/kiali/issues/5207)
* [Relax host validations on presence of ALLOW_ANY vs REGISTRY_ONLY](https://github.com/kiali/kiali/issues/5235)

Fixes:

* [Overlay trace onclick event doesn't work in the metrics charts](https://github.com/kiali/kiali/issues/5286)
* [Terminated in Another Window color doesn't look like the PF warning title color](https://github.com/kiali/kiali/issues/5255)
* [Adjust the "View in Grafana" link in metrics tab](https://github.com/kiali/kiali/issues/5273)
* [Sidecar with no workloadSelector in two separate namespaces are marked as conflicting...](https://github.com/kiali/kiali/issues/5310)
* [trace details heatmap vertical labels are truncated](https://github.com/kiali/kiali/issues/5291)
* [Adjust the "View in Tracing" links to the same row](https://github.com/kiali/kiali/issues/5287)
* [Skip workloads when summarizing config validations in Overview page and in Graph](https://github.com/kiali/kiali/issues/5342)
* [logs tab page has wrong container when navigating from trace tab ](https://github.com/kiali/kiali/issues/5289)
* [More than one Gateway, but cannot find duplicate](https://github.com/kiali/kiali/issues/5213)

## 1.54.0
Sprint Release: July 22, 2022

Features:

* [Update istio.io/client-go to Istio 1.14](https://github.com/kiali/kiali/issues/5159)
* [Revisit DestinationRule no labels warning](https://github.com/kiali/kiali/issues/4511)
* [Outdated Kiali validations](https://github.com/kiali/kiali/issues/5266)
* [Review validations documentation on Kiali.io](https://github.com/kiali/kiali/issues/5262)
* [Combine destination/source reporters in metric tab](https://github.com/kiali/kiali/issues/2887)
* [Adjust mouse pointer on areas that user can navigate/jump to](https://github.com/kiali/kiali/issues/5276)
* [remove perms no longer needed](https://github.com/kiali/kiali/issues/5318)
* [(helm) be able to specify custom annotations on the Kiali CR](https://github.com/kiali/kiali/issues/5334)

Fixes:

* [Misaligned dropdown when invalid operand is typed](https://github.com/kiali/kiali/issues/5302)
* [(helm) when operator helm chart optionally creates CR, it puts the annotation in the wrong spot](https://github.com/kiali/kiali/issues/5297)


## 1.53.0
Sprint Release: July 1st, 2022

Features:

* [Add cypress UI tests around the Service Details page](https://github.com/kiali/kiali/issues/5001)
* [Add outboundTrafficPolicy value to overview istio-system card ](https://github.com/kiali/kiali/issues/4896)
* [Create a UI suite test on cypress](https://github.com/kiali/kiali/issues/4854)
* [UI tests around the Workloads Details page.](https://github.com/kiali/kiali/issues/5072)
* [Add Kiali validations on the Istio Config Details sidepanel](https://github.com/kiali/kiali/issues/5204)
* [Not found messages may have a better message in the body page](https://github.com/kiali/kiali/issues/5206)
* [Reproducible performance testing environment](https://github.com/kiali/kiali/issues/5142)
* [Envoy tab: add tooltips with the Envoy terminology](https://github.com/kiali/kiali/issues/5162)
* [Update the information about mTLS data in details pages](https://github.com/kiali/kiali/issues/5187)
* [Document ability to set default Kiali CR image_name in operator from helm charts](https://github.com/kiali/kiali/issues/5238)
* [Release pipeline for the plugin](https://github.com/kiali/openshift-servicemesh-plugin/issues/39)
* [Remove invalid durations based on prometheus scrape interval](https://github.com/kiali/kiali/issues/5269)
* [fix doc link 404](https://github.com/kiali/kiali/issues/5244)

Fixes:

* [404 external link in kiali.io](https://github.com/kiali/kiali/issues/5192)
* [Failing to Display Larger Number of Log Lines](https://github.com/kiali/kiali/issues/4701)
* [Fix UI Actions regressions](https://github.com/kiali/kiali/issues/5186)
* [(CI) Test Flake - Cypress sidecar injection](https://github.com/kiali/kiali/issues/5198)
* [(e2e) Flaky test fix TestAuthPolicyPrincipalsError](https://github.com/kiali/kiali/issues/5219)
* [Keep Envoy tab after refresh](https://github.com/kiali/kiali/issues/5250)
* [DR details open fails in some cases](https://github.com/kiali/kiali/issues/5257)


## 1.52.0
Sprint Release: June 10th, 2022

Features:

* [Update beta interfaces for CronJob workloads](https://github.com/kiali/kiali/issues/4519)
* [Adjust font style in charts options](https://github.com/kiali/kiali/issues/5168)
* ["This subset's labels are not found in any matching host" - DestinationRule and ServiceEntry](https://github.com/kiali/kiali/issues/5131)
* [Upgrade the Patternfly framework](https://github.com/kiali/kiali/issues/4260)
* [Review conditional rendering in the kiosk mode](https://github.com/kiali/kiali/issues/5129)
* [Add more mechanisms to provide OpenShift tokens to Kiali](https://github.com/kiali/kiali/issues/5127)
* [Improve the upstream pipelines](https://github.com/kiali/kiali/issues/4827)
* [UI tests around the Graph page Find/Hide](https://github.com/kiali/kiali/issues/5073)
* [Kiali and Istio validation messages should be placed together](https://github.com/kiali/kiali/issues/4864)

Fixes:

* [Update font color on green/red labels for trace details](https://github.com/kiali/kiali/issues/5092)
* [Toolbar icons misaligned ](https://github.com/kiali/kiali/issues/5148)
* [Adjust Istio/Kiali version warnings](https://github.com/kiali/kiali/issues/5166)
* [(e2e) TestAuthPolicyPrincipalsError test flaking](https://github.com/kiali/kiali/issues/5164)
* [Envoy filter broken](https://github.com/kiali/kiali/issues/5161)
* [(cypress) Sidecar injection tests sometimes fail](https://github.com/kiali/kiali/issues/5076)
* [Fix find/hide toolbar alignment issues](https://github.com/kiali/kiali/issues/5125)
* [Fix "info" icons in the yaml config editor](https://github.com/kiali/kiali/issues/5097)
* [Multiple condition values under builder are displayed without comma to separate multiple values](https://github.com/kiali/kiali/issues/5111)
* [operator aborts if cluster does not support default HPA version](https://github.com/kiali/kiali/issues/5115)
* [Validations missing for few keys of authorization policy conditions](https://github.com/kiali/kiali/issues/5109)

## 1.51.0
Sprint Release: May 20th, 2022

Features:

* [add cypress tests for graph replay](https://github.com/kiali/kiali/issues/5084)
* [Migrate e2e test suite to Golang](https://github.com/kiali/kiali/issues/4826)
* [(cypress) UI tests around the Graph page Toolbars (otherwise not covered)](https://github.com/kiali/kiali/issues/4960)
* [validation: authorization policy validation, principals not found](https://github.com/kiali/kiali/issues/4424)
* [Make the Istio Config details poll explicit](https://github.com/kiali/kiali/issues/4936)
* [Add cypress UI tests around the Workload List page](https://github.com/kiali/kiali/issues/4912)
* [operator release pipeline needs to update createdAt field in CSVs](https://github.com/kiali/kiali/issues/5055)
* [add creation of olm metadata to the new github release workflow](https://github.com/kiali/kiali/issues/5025)
* [Investigate update of Patternfly to be compatible with OS Console](https://github.com/kiali/kiali/issues/4836)
* [Investigate testing demos scripts on upstream + OpenShift platform](https://github.com/kiali/kiali/issues/5045)
* [Schedule release pipelines](https://github.com/kiali/kiali/issues/5029)
* [Update to use new HPA v2](https://github.com/kiali/kiali-operator/pull/536)

Fixes:

## 1.50.0
Sprint Release: April 29th, 2022

Features:

* [Add cypress UI tests around the Graph page Display menu](https://github.com/kiali/kiali/issues/4949)
* [Add cypress UI tests around the Services List page](https://github.com/kiali/kiali/issues/4955)
* [Improve Kiali server release pipeline using Github Actions](https://github.com/kiali/kiali/issues/4869)
* [Improve Kiali operator release pipeline using Github Actions](https://github.com/kiali/kiali/issues/4870)
* [Improve Helm charts release pipeline using Github Actions](https://github.com/kiali/kiali/issues/4992)
* [Improve Kiali site release pipeline using Github Actions](https://github.com/kiali/kiali/issues/4993)

Fixes:

* [Remove Snyk and consolidate on GitHub Dependabot](https://github.com/kiali/kiali/pull/4915)
* [Update operator's Ansible base image](https://github.com/kiali/kiali/issues/4953)
* [Quite some logging](https://github.com/kiali/kiali/pull/4973)
* [Clean expired clients](https://github.com/kiali/kiali/issues/4849)
* [Minor Demo and Tutorial enhancements](https://github.com/kiali/demos/pull/46)
* [Fix to Destination Rule validation (.svc)](https://github.com/kiali/kiali/issues/4975)
* [Fix to Virtual Service YAML display](https://github.com/kiali/kiali/issues/4894)

## 1.49.0
Sprint Release: April 8th, 2022

Features:

* [Auth: Phase out usage of JWTs](https://github.com/kiali/kiali/issues/4542)
* [Kiali UI and Kiali Server can point to a single commit](https://github.com/kiali/kiali/issues/4895)
* [Add cypress UI tests around the Overview page](https://github.com/kiali/kiali/issues/4872)
* [Update Prometheus client lib](https://github.com/kiali/kiali/issues/4884)
* [Transfer frontend repo into kiali repo](https://github.com/kiali/kiali/issues/4825)
* [Hack script to create a Kind cluster in CI](https://github.com/kiali/kiali/issues/4833)
* [Feature flag to disable log browser](https://github.com/kiali/kiali/issues/4737)
* [Support Gateways workloads in user namespaces](https://github.com/kiali/kiali/issues/3408)
* [add the ability to add annotations to configmap.yaml](https://github.com/kiali/kiali/issues/4814)

Fixes:

* [ui crash with no gateways](https://github.com/kiali/kiali/issues/4892)
* [UI messages at INFO level look just like ERROR level messages](https://github.com/kiali/kiali/issues/4871)
* [fatal error: concurrent map writes](https://github.com/kiali/kiali/issues/4842)

## 1.48.0
Sprint Release: March 18th, 2022

Features:

* [Research a new Graph layout to support large topologies](https://github.com/kiali/kiali/issues/4601)
* [Improve the side panel in the Istio Config editor](https://github.com/kiali/kiali/issues/4241)
* [Reduce the number of requests to fetch health data on list pages](https://github.com/kiali/kiali/issues/4748)
* [Improve the representation of edges and connections in large topologies](https://github.com/kiali/kiali/issues/4610)
* [Add help messages for DestinationRules](https://github.com/kiali/kiali/issues/4554)
* [Add help messages for RequestAuthentications](https://github.com/kiali/kiali/issues/4564)
* [Add help messages for Gateways](https://github.com/kiali/kiali/issues/4556)
* [Add help messages for AuthorizationPolicies](https://github.com/kiali/kiali/issues/4562)
* [Add help messages for WorkloadGroups](https://github.com/kiali/kiali/issues/4561)
* [Add help messages for WorkloadEntries](https://github.com/kiali/kiali/issues/4560)
* [Add help messages for Sidecars](https://github.com/kiali/kiali/issues/4558)
* [Add help messages for ServiceEntries](https://github.com/kiali/kiali/issues/4557)
* [Add help messages for EnvoyFilters](https://github.com/kiali/kiali/issues/4555)
* [Reduce the number of requests to fetch health data on detail pages](https://github.com/kiali/kiali/issues/4790)
* [Research workload/service label filters on Graph](https://github.com/kiali/kiali/issues/4605)
* [Add help messages for VirtualServices](https://github.com/kiali/kiali/issues/4559)
* [Ensure all validations has object references](https://github.com/kiali/kiali/issues/2447)
* [Base side panel redesign for Istio config objects](https://github.com/kiali/kiali/issues/4553)
* [Improve crossnamespace Istio Gateways query in ServiceDetailsPage](https://github.com/kiali/kiali/issues/4692)
* [Envoy metrics look broken](https://github.com/kiali/kiali/issues/4769)
* [Develop a mock backend server for local UI work in scalability scenarios](https://github.com/kiali/kiali/issues/4585)
* [feat(multitenancy): support additional metric label for prometheus](https://github.com/kiali/kiali/issues/4664)

Fixes:

* [Sidecar Validations - Workloads should be from local namespace](https://github.com/kiali/kiali/issues/4758)
* [Gateway details warning - Missing validation reference](https://github.com/kiali/kiali/issues/4807)
* [Kiali graph is not working with disabled Istio's /debug endpoints](https://github.com/kiali/kiali/issues/4798)
* [Mismatched Node Graph Type breaks UI in Application](https://github.com/kiali/kiali/issues/4797)
* [Misconfigured `istiod_deployment_name` causes a panic](https://github.com/kiali/kiali/issues/4788)
* [Namespace with External Registry Service only - UI Error Loading services](https://github.com/kiali/kiali/issues/4720)
* [Service List - Missing Configuration status](https://github.com/kiali/kiali/issues/4795)
* ["Could not fetch services list" Error](https://github.com/kiali/kiali/issues/4793)
* [KIA0003 for multiple Request Authentication](https://github.com/kiali/kiali/issues/4640)
* [Duration dropdown showing invalid durations](https://github.com/kiali/kiali/issues/4784)
* [Kiali shows KIA0701 for istio-system debug ports - but should not](https://github.com/kiali/kiali/issues/4764)
* [Istio Config List - Configuration icon load inconsistency](https://github.com/kiali/kiali/issues/4766)
* [cannot use a custom secret for Kiali identity](https://github.com/kiali/kiali/issues/4761)
* [Improve protection against graph numbers that are actually string variables](https://github.com/kiali/kiali-ui/pull/2321)
* [Fix time selection issue in replay custom startTime picker](https://github.com/kiali/kiali-ui/pull/2320)

## 1.47.0
Sprint Release: February 25th, 2022

Features:

* [Allow dynamic markers on editor according to Istio config object](https://github.com/kiali/kiali/issues/4552)
* [Introduce "preview" mode in Istio Config actions](https://github.com/kiali/kiali/issues/3577)
* [Add Istio Config Preview under wizard actions under istio config page](https://github.com/kiali/kiali/issues/4733)
* [Refactor Kiali Validations to better use the Istio registry information](https://github.com/kiali/kiali/issues/4382)
* [Refactor Kiali Validations according to Istio Registry usage model for listing Configs and Services](https://github.com/kiali/kiali/issues/4528)
* [Add Istio Config Preview under wizard actions under service details page](https://github.com/kiali/kiali/issues/4681)
* [Add graph generator for creating mock graph data](https://github.com/kiali/kiali/pull/4658)

Fixes:

* [(operator) CSV should define skipRange](https://github.com/kiali/kiali/issues/4715)
* [namespace excludes default regexes should only filter out namespaces that "starts-with" the patterns.](https://github.com/kiali/kiali/issues/4714)
* [Fix "xxx is not found as xxx" issue](https://github.com/kiali/kiali/pull/4676)

## 1.46.0
Sprint Release: February 4th, 2022

Features:

* [Add prerequisites in quick-start kiali.io to try kiali](https://github.com/kiali/kiali/issues/4703)
* [Create and sync namespace caches on startup](https://github.com/kiali/kiali/issues/4502)
* [publish the auto-generated docs for the kiali cr](https://github.com/kiali/kiali/issues/4684)
* [Instrument Kiali server with Jaeger](https://github.com/kiali/kiali/issues/4036)
* [Deprecate Iter8 extension in favor of a new model](https://github.com/kiali/kiali/issues/4643)
* [Validations: Support `exportTo` field](https://github.com/kiali/kiali/issues/3061)

Fixes:

* [Gateway Validation References - Contains self reference](https://github.com/kiali/kiali/issues/4675)
* [invalid link in kiali.io doc page istio.md](https://github.com/kiali/kiali/issues/4673)
* [Graph hide can hang browser when zoomed out enough to hide labels](https://github.com/kiali/kiali/issues/4666)
* [auth is broken according to molecule tests](https://github.com/kiali/kiali/issues/4682)
* [Trend lines feature broken in master](https://github.com/kiali/kiali/issues/4668)

## 1.45.0
Sprint Release: January 14th, 2022

Features:

* [Hide graph labels that are too small to read](https://github.com/kiali/kiali/issues/4521)
* [Add preview mode in overview page](https://github.com/kiali/kiali/issues/4433)
* [Graph: Correctly badge service nodes with the VS/Route icon](https://github.com/kiali/kiali/issues/4541)
* [(graph) Enable namespace and cluster boxing by default](https://github.com/kiali/kiali/issues/4547)
* [tests should use latest minikube and dex to keep up to date](https://github.com/kiali/kiali/issues/4582)
* [Support `exportTo` validation in ServicesEntries](https://github.com/kiali/kiali/issues/4316)
* [(operator) update operator to base image 1.10.1 (4.9)](https://github.com/kiali/kiali/issues/4540)

Fixes:

* [Jaeger http legacy protocol has problems in master](https://github.com/kiali/kiali/issues/4636)
* [Adjust font style in trace details comparison map](https://github.com/kiali/kiali/issues/4588)
* [fast click `Idle Nodes` (or other graph display options) can break UI](https://github.com/kiali/kiali/issues/4638)
* [Missing "KIA1106 More than one Virtual Service for same host" for cross-namespace cases](https://github.com/kiali/kiali/issues/4652)
* [Minigraph navigation broken](https://github.com/kiali/kiali/issues/4589)
* ["KIA1102 VirtualService is pointing to a non-existent gateway" shown only once.](https://github.com/kiali/kiali/issues/4645)
* [Wrong KIA1106 "More than one Virtual Service for same host"](https://github.com/kiali/kiali/issues/4641)
* [Number of regex.Compile() calls in multi_match_checker scales quadratically with hosts checked](https://github.com/kiali/kiali/issues/4592)
* ["Could not fetch services list" Error in Service view when selecting some namespaces](https://github.com/kiali/kiali/issues/4570)
* [Molecule "api-test" failure in graph generation on ossm 2.1](https://github.com/kiali/kiali/issues/4246)
* [Validations and TLS Endpoints Very Slow](https://github.com/kiali/kiali/issues/4224)
* [Reconciliation may fail when removing a namespace from a cluster immediately after removing it from spec.deployment.accessible_namespaces](https://github.com/kiali/kiali/issues/3949)
* [k8s service appProtocol is no reflected in config checks](https://github.com/kiali/kiali/issues/4486)

## 1.44.0
Sprint Release: December 3rd, 2021

Features:

* [Correct graph edge for Pod to Pod communication using destination_workload](https://github.com/kiali/kiali/issues/4488)
* [Make istiod ports configurable in kiali](https://github.com/kiali/kiali/issues/4462)
* [Support rootNamespace: administrative namespace for istio config](https://github.com/kiali/kiali/issues/3062)
* [Support rootNamespace in Peer Authentication validations](https://github.com/kiali/kiali/issues/4450)
* [Support rootNamespace in Sidecar validations](https://github.com/kiali/kiali/issues/4449)
* [access ingress_enabled for now to support older CRs](https://github.com/kiali/kiali/issues/4510)
* [Include an explanation about the lack of health information for TCP services (like a database)](https://github.com/kiali/kiali/issues/3786)
* [(operator) implement best practice guidelines to support multi-tenant installations](https://github.com/kiali/kiali/issues/4485)
* [Upgrade kubernetes/client-go version and update beta interfaces for workloads](https://github.com/kiali/kiali/issues/4042)

Fixes:

* [KIA1105: Virtual service routes may not point to any subset](https://github.com/kiali/kiali/issues/4458)
* [Possible memory leak in /api/istio/status endpoint](https://github.com/kiali/kiali/issues/4527)
* [Documentation doesn't show how to configure Kiali](https://github.com/kiali/kiali/issues/3858)

## 1.43.0
Sprint Release: November 12nd, 2021

Features:

* [Allow Kiali Graphs to show EgressGateway traffic to ServiceEntry](https://github.com/kiali/kiali/issues/3765)
* [(Feature Request) Support mounting existing secret into Kiali Pod](https://github.com/kiali/kiali/issues/4468)
* [Calculate graph importance score](https://github.com/kiali/kiali/issues/2888)
* [Validations - Ensure ServiceEntry has WorkloadEntry addresses](https://github.com/kiali/kiali/issues/4339)
* [Support getting the root namespace from Istio configuration](https://github.com/kiali/kiali/issues/4448)
* [ingress created by Kiali CR does not include ingress class - need new deployment.ingress setting](https://github.com/kiali/kiali/issues/4342)

Please note this introduces a backward-incompatible change. Users with the prior ingress settings defined in their Kiali CR will need to make an update.  Other users are not affected. The previous ingress settings were:

```yaml
deployment:
  ingress_enabled: <true|false>
  override_ingress_yaml:
    ...the override yaml here...
```

This has been changed to the following:

```yaml
deployment:
  ingress:
    enabled: <true|false>
    override_yaml:
      ...the override yaml here...
```

* [Update kiali.io docs to Kiali 1.36+](https://github.com/kiali/kiali/issues/4118)
* [Google OIDC allowed domains](https://github.com/kiali/kiali/issues/4288)
* [Include ServiceAccount info across console](https://github.com/kiali/kiali/issues/2201)
* [Add information about Istio overhead ](https://github.com/kiali/kiali/issues/3703)

Fixes:

* [Workload Entry graph nodes display only "latest" version](https://github.com/kiali/kiali/issues/4206)
* [Kiali Documentation link from Master Head seems broken](https://github.com/kiali/kiali/issues/4478)
* [Crash in onCopy button in Envoy tab editors](https://github.com/kiali/kiali/issues/4445)
* ["More than one Gateway for the same host port combination" even with different ports](https://github.com/kiali/kiali/issues/4466)
* [Workload pod proxy logs shows details for Envoy app logging](https://github.com/kiali/kiali/issues/4356)

## 1.42.0
Sprint Release: October 22nd, 2021

Features:

* [Migrate to Docsy for kiali.io theme](https://github.com/kiali/kiali/issues/4395)
* [Add strong type mapping in Istio Kiali model](https://github.com/kiali/kiali/issues/1372)
* [Show mirroring info or badge on the graph](https://github.com/kiali/kiali/issues/4383)
* [Add a "Trendlines" option in the metrics tab](https://github.com/kiali/kiali/issues/2997)
* [Show gateway in istio config](https://github.com/kiali/kiali/issues/4326)
* [Add Sidecars on  "Create Traffic Policies" namespace action](https://github.com/kiali/kiali/issues/3394)
* [Ability to pass custom headers to httputil.Post](https://github.com/kiali/kiali/issues/4377)
* [Add hostAliases field to kiali deployment manifests](https://github.com/kiali/kiali/issues/4403)
* [Kiali Istio dashboards incompatible with thanos-query](https://github.com/kiali/kiali/issues/4303)

Fixes:

* [URL parameters not persisted in inbound/outbound metric tabs](https://github.com/kiali/kiali/issues/4420)
* [Include Mesh Gateway in Create Traffic Routing - causes failure](https://github.com/kiali/kiali/issues/4416)
* [Potential Memory Leak in UI AuthenticationController](https://github.com/kiali/kiali/issues/4265)
* [More Sidecars on Configuration](https://github.com/kiali/kiali/issues/4437)
* [ "missing span root" in graph side panel ](https://github.com/kiali/kiali/issues/4407)

## 1.41.0
Sprint Release: October 1st, 2021

Features:

* [Add help for Graph shortcuts](https://github.com/kiali/kiali/issues/4133)
* [Add custom label aggregation in metrics tab](https://github.com/kiali/kiali/issues/2911)
* [Kiali Operator - Add ability to specify image SHA in Kiali CRs](https://github.com/kiali/kiali/issues/4392)
* [Improve discovery matcher process for Custom Dashboards](https://github.com/kiali/kiali/issues/3704)
* [Add SRE style metrics in the Overview namespace chart](https://github.com/kiali/kiali/issues/2947)
* [Be able to set the logging level for istio and envoy logs from Kiali UI](https://github.com/kiali/kiali/issues/1525)
* [Custom HTTP headers when connecting to Prometheus](https://github.com/kiali/kiali/issues/4323)
* [Display Envoy tab for workloads running Istio Proxy without Sidecar](https://github.com/kiali/kiali/issues/4165)

Fixes:

* [Workload page displays an error when accessing VirtualMachineInstance resource](https://github.com/kiali/kiali/issues/3733)
* [WorkloadEntry workload graph nodes have broken link](https://github.com/kiali/kiali/issues/4219)
* [Mesh internal ServiceEntry should be grouped in app box with workloads](https://github.com/kiali/kiali/issues/4295)
* [Error loading Graph - Namespace (kube-state-metrics) is excluded for Kiali](https://github.com/kiali/kiali/issues/4384)
* [Workloads flap between OK and Not Ready w/ Argo Rollout CR](https://github.com/kiali/kiali/issues/4141)
* [Unable to edit IstioConfig](https://github.com/kiali/kiali/issues/4371)
* [Kiali loading icon seems broken](https://github.com/kiali/kiali/issues/4363)
* [seg fault in IsMaistra status (found in Kiali v1.40.0)](https://github.com/kiali/kiali/issues/4351)
* [ansible option we use in operator code is being renamed](https://github.com/kiali/kiali/issues/4338)

## 1.40.0
Sprint Release: September 10th, 2021

Features:

* [Support exportTo validation in VirtualServices](https://github.com/kiali/kiali/issues/4314)
* [Add graph Factory Reset button](https://github.com/kiali/kiali/issues/4184)
* [Add help tooltip in the metrics tab](https://github.com/kiali/kiali/issues/1433)
* [Add info/tooltip on virtual service that doesn't have a gateways section](https://github.com/kiali/kiali/issues/1440)
* [Support the new istio injection label](https://github.com/kiali/kiali/issues/4268)
* [Add indication if certificates are managed by Citadel or external tool](https://github.com/kiali/kiali/issues/1577)
* [Distinguish between VM based workloads and pod based workloads on the graph](https://github.com/kiali/kiali/issues/4220)
* [Identify and label WorkloadEntry graph nodes](https://github.com/kiali/kiali/issues/4223)
* [ci-kind-molecule-tests.sh should support installing OLM and testing with OLM-installed operator](https://github.com/kiali/kiali/issues/4196)
* [Docs and scripts regarding secrets and service accounts might need to be updated](https://github.com/kiali/kiali/issues/4259)

Fixes:

* [(validations) Don't show KIA0203 when there are no VS referencing the DR subset](https://github.com/kiali/kiali/issues/4218)
* [Kiali Operator: Pods attempt to use auth secret when external service disabled](https://github.com/kiali/kiali/issues/4298)
* [Not able to build Molecule image](https://github.com/kiali/kiali/issues/4302)
* [Metrics charts can be too thin](https://github.com/kiali/kiali/issues/4325)
* [Some graph settings do not have query parms - can't bookmark pages](https://github.com/kiali/kiali/issues/3840)
* [Workload's page Actions dropdown is clickable in view_only_mode ](https://github.com/kiali/kiali/issues/4202)
* [CRUD Permissions on events](https://github.com/kiali/kiali/issues/4290)
* [Kiali Login error when Prometheus fails to start](https://github.com/kiali/kiali/issues/3927)

## 1.39.0
Sprint Release: August 20th, 2021

Features:

* [generate metrics for validators](https://github.com/kiali/kiali/issues/4230)
* [(molecule) run molecule tests using a KinD cluster](https://github.com/kiali/kiali/issues/3895)
* [Remote cluster functionality should be configurable](https://github.com/kiali/kiali/issues/4147)
* [Update Kiali UI to latest Node.js LTS version](https://github.com/kiali/kiali/issues/2596)
* [Add a Molecule test to verify Grafana integration](https://github.com/kiali/kiali/issues/4195)
* [(operator) perform true "can_i" check to confirm the operator has correct permissions](https://github.com/kiali/kiali/issues/3241)

Fixes:

* [grafana-test fails - cannot look up grafana url successfully](https://github.com/kiali/kiali/issues/4289)
* [route created by operator doesn't seem right](https://github.com/kiali/kiali/issues/4255)
* [Jaeger traces & spans fetching error](https://github.com/kiali/kiali/issues/4238)

## 1.38

### 1.38.1
Mid-Sprint Release: August 6th, 2021

Fixes:

* [Issues with clustering discovery](https://github.com/kiali/kiali/issues/4221)
* [Scripts not loading (404) on openid_error when Kiali is hosted in a subfolder (web_root: /kiali)](https://github.com/kiali/kiali/issues/4215)
* [Jaeger traces & spans fetching error](https://github.com/kiali/kiali/issues/4238)
* [helm-charts and istio addons doesn't have default grafana in_cluster_url defined](https://github.com/kiali/kiali/issues/4261)

### 1.38.0
Sprint Release: July 30th, 2021

Features:

* [New badge/visualization for hostnames in Graph](https://github.com/kiali/kiali/issues/4068)
* [Enhanced logs viewing and correlation](https://github.com/kiali/kiali/issues/3499)
* [bump operator to newer minor-release of base image](https://github.com/kiali/kiali/issues/4094)
* [Add validation for "exportTo" fields of VirtualService, ServiceEntry](https://github.com/kiali/kiali/issues/1370)
* [Feature Request: Disable certain validations](https://github.com/kiali/kiali/issues/4197)
* [Display traffic scenario badges when present](https://github.com/kiali/kiali/issues/4090)
* [gRPC Streaming traffic](https://github.com/kiali/kiali/issues/4070)
* [Consider using tcp_received telemetry for graph generation](https://github.com/kiali/kiali/issues/3730)
* [community OLM metadata moving to new repos](https://github.com/kiali/kiali/issues/4190)
* [trivial case change to disconnected annotation value in operator metadata](https://github.com/kiali/kiali/issues/4163)
* [document the new dashboard annotations](https://github.com/kiali/kiali/issues/4182)
* [clean up upstream istio kiali addon install doc](https://github.com/kiali/kiali/issues/4111)
* [Display custom dashboards with more than two rows of graphs inside the card](https://github.com/kiali/kiali/issues/4156)
* [test custom dashboard overrides](https://github.com/kiali/kiali/issues/4160)
* [Use annotations to personalize CustomDashboards](https://github.com/kiali/kiali/issues/4145)

Fixes:

* [Scripts not loading (404) on openid_error when Kiali is hosted in a subfolder (web_root: /kiali)](https://github.com/kiali/kiali/issues/4215)
* [Issues with clustering discovery](https://github.com/kiali/kiali/issues/4221)
* [(operator) Playbook "create additional kiali labels..." fails due to unquoted string in label](https://github.com/kiali/kiali/issues/4157)
* [grafana links missing](https://github.com/kiali/kiali/issues/4226)
* [ERR GetAppTraces, Jaeger GRPC client error: rpc error: code = Unavailable desc = connection closed](https://github.com/kiali/kiali/issues/4207)
* [molecule tests need to wait for CRD to be established](https://github.com/kiali/kiali/issues/4216)
* [Add missing warning on VirtualService "exportTo" field](https://github.com/kiali/kiali/issues/4203)
* [Exposing workloads with ServiceEntries makes Kiali show non-existing Services](https://github.com/kiali/kiali/issues/4072)
* [Cannot fetch proxy status on Istio master (1.11)](https://github.com/kiali/kiali/issues/4132)

## 1.37.0
Sprint Release: July 9th, 2021

Features:

* [Support for custom istio injection labels and values](https://github.com/kiali/kiali/issues/3988)
* [Metrics page: select all/none filter](https://github.com/kiali/kiali/issues/3596)
* [Add Gateway/VirtualService hostnames in Service details](https://github.com/kiali/kiali/issues/4067)
* [Add gateway validation to VirtualServices](https://github.com/kiali/kiali/issues/2932)
* [Services list should show when a VirtualService/DestinationRule is applied](https://github.com/kiali/kiali/issues/1446)
* [Unify style attribute for config validation icons](https://github.com/kiali/kiali/issues/1952)
* [(multi-cluster) Enhance support for mesh deployment models](https://github.com/kiali/kiali/issues/1833)
* [Add help icon in Wizards](https://github.com/kiali/kiali/issues/1369)
* [Support for custom CA certificates in OpenID authentication](https://github.com/kiali/kiali/issues/4050)

Fixes:

* [The namespaces that begins with `kube` are hidden but those should be OK](https://github.com/kiali/kiali/issues/4162)
* [Repeated queries on CustomMetrics](https://github.com/kiali/kiali/issues/4134)
* [kiali Cannot load the graph "invalid character 'd' looking for beginning of value"](https://github.com/kiali/kiali/issues/4131)
* [Duplicated application container on Workload Logs tab](https://github.com/kiali/kiali/issues/4130)
* [Metrics Settings are kept but not applied when switching metrics tabs](https://github.com/kiali/kiali/issues/4106)
* [(perf) pr #3975 introduced perf regression for /api/namespaces/bookinfo/services/details/graph endpoint](https://github.com/kiali/kiali/issues/4120)
* [Tooltip span not available](https://github.com/kiali/kiali/issues/3221)

## 1.36.0
Sprint Release: June 18th, 2021

Features:

* [Connect Listeners and Routes in the Envoy Config modal](https://github.com/kiali/kiali/issues/4005)
* [remove istio_component_namespaces config](https://github.com/kiali/kiali/issues/4109)
* [Research Metrics tab main layout](https://github.com/kiali/kiali/issues/3948)
* [Display throughput on the graph edges](https://github.com/kiali/kiali/issues/2897)
* [Move Envoy Details to Workload Details](https://github.com/kiali/kiali/issues/4008)
* [Pod table should reflect any container crash](https://github.com/kiali/kiali/issues/3529)
* [Consolidate Dashboards CRDs into main Kiali config, also handled via Kiali Operator](https://github.com/kiali/kiali/issues/4057)
* [convert community OLM metadata to new bundle format](https://github.com/kiali/kiali/issues/4069)
* [Add to graph indicator for Kiali scenarios](https://github.com/kiali/kiali/issues/1477)
* [move the support for old versions to CRD v1 when appropriate](https://github.com/kiali/kiali/issues/3912)
* [Internal metrics revisit](https://github.com/kiali/kiali/issues/3244)

Fixes:

* [Difference between App and Workload healths - causing inconsistency in Overview](https://github.com/kiali/kiali/issues/4009)
* [Wrong Health info at Service level](https://github.com/kiali/kiali/issues/3904)
* [Trace graph tooltip truncates long hostnames](https://github.com/kiali/kiali/issues/4087)
* [Circuit Breaker Badge is missing in the Graph](https://github.com/kiali/kiali/issues/4076)
* [clean up hack/istio/bookinfo* resources](https://github.com/kiali/kiali/issues/4079)
* [Health popover disappearing](https://github.com/kiali/kiali/issues/3583)
* [(helm)(operator) do not use deprecated Ingress kind - update to latest apiVersion](https://github.com/kiali/kiali/issues/3706)
* [Graph replay health is not correct](https://github.com/kiali/kiali/issues/4058)
* [Molecule tests broken for podman 3](https://github.com/kiali/kiali/issues/4062)
* [Possible false positive reported as violating KIA0202](https://github.com/kiali/kiali/issues/4049)
* [horizontal scroll problem on graph side panel trace tab detail](https://github.com/kiali/kiali/issues/3586)

