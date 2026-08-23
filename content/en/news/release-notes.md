---
title: "Release Notes"
type: docs
weight: 1
---

For additional information check our [sprint demo videos](https://www.youtube.com/channel/UCcm2NzDN_UCZKk2yYmOpc5w) and [blogs](https://medium.com/kialiproject).

## 2.31.0
Release: August 21, 2026

Features:

* [AI: Automate MCP pin compatibility validation (replace manual contract tests)](https://github.com/kiali/kiali/issues/10139)
* [API: Perform robust and consistent query param validation](https://github.com/kiali/kiali/issues/9193)
* [OSSMC: Add fleet mesh and multi-mesh capabilities](https://github.com/kiali/openshift-servicemesh-plugin/issues/808)
* [OSSMC: Monaco editor loads worker scripts from external CDN instead of local bundle](https://github.com/kiali/openshift-servicemesh-plugin/issues/790)
* [UI: Show the message only once in Messaging center](https://github.com/kiali/kiali/issues/6817)
* [UI: Support glass and high contrast themes for OSSMC/OpenShift 5.0](https://github.com/kiali/kiali/issues/9711)
* [UI: Hide inbound traffic data when inspecting ingress gateway nodes](https://github.com/kiali/kiali/issues/6091)
* [Validations: ignore Sidecar egress import scope (false positives under locked-down Sidecar)](https://github.com/kiali/kiali/issues/10124)
* [Operator: Make the operator pod's probe timings configurable in the helm chart](https://github.com/kiali/kiali/issues/10132)

Fixes:

* [Ambient: KIA1313 false positive never clears: validation change detection does not track waypoint resolution, leaving stale results in the validations store](https://github.com/kiali/kiali/issues/10144)
* [Auth: OpenID strategy with Keycloak never logout from Kiali UI](https://github.com/kiali/kiali/issues/10095)
* [OSSMC: Local dev fails to load OverviewPage after Kiali 2.31 sync (GraphShortcuts setExtraStackFrame)](https://github.com/kiali/openshift-servicemesh-plugin/issues/803)
* [UI: Several small UI/navigation bugs in the Kiali frontend](https://github.com/kiali/kiali/issues/10151)
* [UI: Fix Grafana Explore deep-link](https://github.com/kiali/kiali/issues/10155)
* [Validations: KIA0102 false positive with wildcard methods](https://github.com/kiali/kiali/issues/10183)
* [Validations: Istio validation false positives (P0): AuthZ hosts, auto-mTLS, appProtocol, Gateway API](https://github.com/kiali/kiali/issues/10188)
* [Validations: Istio validation false positives (P1): AuthZ namespaces, RequestAuth merge, selectors, subsets](https://github.com/kiali/kiali/issues/10189)

## 2.30.0
Release: August 03, 2026

Features:

* [AI: Enhance AI Chatbot: Context Awareness & UX Improvements](https://github.com/kiali/kiali/issues/9135)
* [AI: Implement Streaming Responses for Chatbot to Display Real-Time MCP Tool Execution Status](https://github.com/kiali/kiali/issues/9149)
* [AI: Reduce Output Payload Size](https://github.com/kiali/kiali/issues/9371)
* [AI: Multi-cluster eval test suite for Kiali MCP](https://github.com/kiali/kiali/issues/9976)
* [Ambient: Disable L7 istio configs for services that are in Ambient but doesn't have a waypoint proxy](https://github.com/kiali/kiali/issues/7900)
* [K8s GW API v1.6.0 support](https://github.com/kiali/kiali/issues/9859)
* [OpenShift: OpenShift Impersonation for Multi-Cluster Auth](https://github.com/kiali/kiali/issues/10038)
* [UX: Remove refresh interval from Istio Config editor page](https://github.com/kiali/kiali/issues/10016)
* [Validation: Annotations for ignoring Kiali Errors/Warnings in the console?](https://github.com/kiali/kiali/issues/5309)

Fixes:

* [Health: Custom config: failure: 0 does not trigger Failure status despite docs saying it should](https://github.com/kiali/kiali/issues/10072)
* [UI: Annotation editor: follow-up fixes from #10010 review](https://github.com/kiali/kiali/issues/10041)
* [UI: Pods not shown for Argo Rollouts configured via custom_workload_types](https://github.com/kiali/kiali/issues/10008)
* [Validation: Istio configs per namespace returns validations for all the cluster](https://github.com/kiali/kiali/issues/10098)

#### Upgrade Change Notes:

The fix for custom health status configuration could affect existing users. Degraded health status could now be reported
as Failure. The behavior is correct, but could be unexepected. If affected, ensure proper setting of the failure threshold
in your custom health configuration.


## 2.29.0
Release: July 13, 2026

Features:

* [Ambient: v1.30 support](https://github.com/kiali/kiali/issues/9622)
* [AI: Enhance support for multi cluster](https://github.com/kiali/kiali/issues/9895)
* [AI: Implement Ask/Troubleshooting Mode Selection with Provider-Specific Prompts](https://github.com/kiali/kiali/issues/9910)
* [AI: Token reduction](https://github.com/kiali/kiali/issues/9945)
* [AI: Add Gateway API support to MCP tools](https://github.com/kiali/kiali/issues/9946)
* [AI: Improve error handling in multiple tool calls](https://github.com/kiali/kiali/issues/9941)
* [AI: Make the AI MCP max tool iterations configurable](https://github.com/kiali/kiali/issues/9974)
* [AI: Enhance MCP Server with Istio Ambient Mesh Discovery and Debugging Capabilities](https://github.com/kiali/kiali/issues/9977)
* [API: Remove includeAmbient from metrics options and use reporter](https://github.com/kiali/kiali/issues/9722)
* [UX: Improve workload annotation editing by handling controller and tempate annotaions](https://github.com/kiali/kiali/issues/10009)
* [UX: Improve Istio Config side panel](https://github.com/kiali/kiali/issues/9912)
* [UX: Replace react-ace with PatternFly CodeEditor (Monaco)](https://github.com/kiali/kiali/issues/9709)

Fixes:

* [AI: "Confirm chat deletion" modal does not appear when switching from a disconnected AI provider](https://github.com/kiali/kiali/issues/9921)
* [AI: MCP regression](https://github.com/kiali/kiali/issues/9942)
* [AI: Log debugs with chatgpt](https://github.com/kiali/kiali/issues/9961)
* [CI: Error in Test Perses link](https://github.com/kiali/kiali/issues/9929)
* [Graph: Find unhealthy workloads — graph find hide](https://github.com/kiali/kiali/issues/9948)
* [Graph: Fix issue with faint trace overlay](https://github.com/kiali/kiali/pull/10015)
* [Operator: OSSMC plugin installation fails with 401 when server.require_auth: true is set in the Kiali CR](https://github.com/kiali/kiali/issues/9964)
* [OSSMC: Crashes in Namespace detail tab](https://github.com/kiali/kiali/issues/9953)
* [Validations: KIA1401 false positive for HTTPRoutes whose namespace is enrolled in Ambient mesh](https://github.com/kiali/kiali/issues/9937)
* [Validations: KIA1317 should be excluded from waypoint proxies](https://github.com/kiali/kiali/issues/9986)

## 2.28.0
Release: June 22, 2026

Features:

* [AI: Make LightSpeed TLS verification configurable](https://github.com/kiali/kiali/issues/9736)
* [AI: Built-in MCP prompts](https://github.com/kiali/kiali/issues/9744)
* [AI: Use MCP Checker actions instead of the binary](https://github.com/kiali/kiali/issues/9753)
* [Ambient: Validate Kiali with Ambient 1.30](https://github.com/kiali/kiali/issues/9623)
* [API: GW API IE v1.5.0 Support](https://github.com/kiali/kiali/issues/9574)
* [Auth: OAuth2 client_credentials: follow-up fixes and improvements across kiali, operator, and helm-charts](https://github.com/kiali/kiali/issues/9787)
* [I18N: Create i18n conventions file](https://github.com/kiali/kiali/issues/9728)
* [Operator: RBAC permission cleanup](https://github.com/kiali/kiali/issues/9836)
* [UX: Use filter columns in list pages as in the namespace list page](https://github.com/kiali/kiali/issues/9723)
* [Validation: Add Kiali Validation for Conflicting ServiceEntries with Same Host and Port but Different Protocols](https://github.com/kiali/kiali/issues/9800)

Fixes:

* [Ambient: Ambient Traffic dropdown hidden when home cluster has no ztunnel](https://github.com/kiali/kiali/issues/9784)
* [Multicluster: Workloads list fails with "namespace not accessible" when ignore_home_cluster=true](https://github.com/kiali/kiali/issues/9790)
* [Validation: KIA1401 false positive when Gateway allowedRoutes selector uses matchExpressions](https://github.com/kiali/kiali/issues/9819)


## 2.27.0
Release: June 01, 2026

Features:

* [AI: Support anthropic provider](https://github.com/kiali/kiali/issues/9148)
* [AI: Implement background job to clean stale store data.](https://github.com/kiali/kiali/issues/9143)
* [AI: Extend resource_details tool to support Application-level resources](https://github.com/kiali/kiali/issues/9137)
* [AI: Token Usage Analytics](https://github.com/kiali/kiali/issues/9142)
* [AI: Harden System Prompt Against Injection](https://github.com/kiali/kiali/issues/9141)
* [Kiali.io: Update Istio Configuration Section](https://github.com/kiali/kiali/issues/6895)
* [Mesh page: Multi-mesh Control Plane Donut chart support](https://github.com/kiali/kiali/issues/9040)
* [Perf: Improve in point traffic animation](https://github.com/kiali/kiali/issues/9701)
* [Perf: Improve "istio" graph appender performance](https://github.com/kiali/kiali/issues/8524)
* [Perf: Improve health cache memory utilizion](https://github.com/kiali/kiali/pull/9765)
* [Perf: Improve workload fetching for single namespaces](https://github.com/kiali/kiali/pull/9766)
* [Server: Re-enable Prometheus after initial health check failure](https://github.com/kiali/kiali/issues/9716)
* [UX: Improve wizard buttons in view-only mode](https://github.com/kiali/kiali/issues/9655)
* [UX: Update detail pages in the style of the new Namespace detail page](https://github.com/kiali/kiali/issues/9646)

Fixes:

* [UI: Clicking chart data points throws TypeError](https://github.com/kiali/kiali/issues/9624)
* [UI: No heatmap in some Ambient tracing namespace](https://github.com/kiali/kiali/issues/9685)
* [UI: Show "No related resources" message in the Related card when empty](https://github.com/kiali/kiali/issues/9691)
* [UI: (Mesh page) ztunnel not connected with the control plane](https://github.com/kiali/kiali/issues/9714)
* [Validation: (Ambient) False positive in KIA1313](https://github.com/kiali/kiali/issues/9674)

**The following fields are no longer used by the Kiali CR and will be ignored if currently set. The standard constant values are now used.**

* `spec.istio_labels.egress_gateway_label`
* `spec.istio_labels.ingress_gateway_label`
* `spec.istio_labels.injection_label_name`
* `spec.istio_labels.injection_label_rev`


## 2.26.0
Release: May 29, 2026

Features:

* [AI: Support anthropic provider](https://github.com/kiali/kiali/issues/9148)
* [AI: Support Google Model Provider](https://github.com/kiali/kiali/issues/9144)
* [AI: Implement background job to clean stale store data](https://github.com/kiali/kiali/issues/9143)
* [Ambient: Trace overlay](https://github.com/kiali/kiali/issues/9504)
* [Config: identity domain](https://github.com/kiali/kiali/issues/7514)
* [Config: Add pod disruption budget template to kiali chart](https://github.com/kiali/kiali/issues/9590)
* [Deployment: Add ability to enable/disable prometheus](https://github.com/kiali/kiali/issues/8654)
* [Overview Page: Follow-up UX improvements](https://github.com/kiali/kiali/issues/9162)
* [OSSMC: Add Namespace and Application list pages to OSSMC](https://github.com/kiali/openshift-servicemesh-plugin/issues/631)
* [OSSMC: Replace native Istio Config list page with Kiali's IstioConfigListPage](https://github.com/kiali/openshift-servicemesh-plugin/issues/654)
* [Perf: trace hover tooltip performance boost](https://github.com/kiali/kiali/issues/6915)
* [UI: Replace height magic numbers with CSS flex layout](https://github.com/kiali/kiali/issues/9575)
* [UI: Traffic menu design iteration](https://github.com/kiali/kiali/issues/9588)
* [UI: Add Namespace Detail page](https://github.com/kiali/kiali/issues/9610)
* [UI: Better support for annotation and label editing](https://github.com/kiali/kiali/issues/5688)

Fixes:

* [AI: Fix Hallucinated/Broken Text Links in Chatbot Navigation Responses](https://github.com/kiali/kiali/issues/9150)
* [AI: Return in MCPtools error type when token is not valid](https://github.com/kiali/kiali/issues/9582)
* [Ambient: ztunnel dump error](https://github.com/kiali/kiali/issues/9658)
* [OSSMC: Cluster name not shown on Istio Config Details page in OSSMC](https://github.com/kiali/openshift-servicemesh-plugin/issues/638)
* [OSSMC: MTLS icon is not working](https://github.com/kiali/kiali/issues/9647)
* [UI: Chart legend toggle stops responding after two clicks](https://github.com/kiali/kiali/issues/9586)
* [UI: Unreadable Text for Istio Validations](https://github.com/kiali/kiali/issues/9581)
* [UI: tracing: Incorrect visualization of tooltip](https://github.com/kiali/kiali/issues/9631)

## 2.25.0
Release: April 20, 2026

Features:

* [Ambient: Improve inter-cluster telemetry](https://github.com/kiali/kiali/issues/9507)
* [AI: Implement Unit and Integration tests for Backend API](https://github.com/kiali/kiali/issues/9145)
* [Graph: Include inbound and outbound edges when automatically activating rank](https://github.com/kiali/kiali/issues/5915)
* [Validation: Multi-primary support](https://github.com/kiali/kiali/issues/7725)
* [Validations: Multi-primary support for MeshConfig](https://github.com/kiali/kiali/issues/7727)
* [UI: Improve Duration handling for fixed-duration pages (lists, overview)](https://github.com/kiali/kiali/issues/9474)

Fixes:

* [AI: manage_istio_config returns UI-only actions payload to MCP clients that cannot handle it](https://github.com/kiali/kiali/issues/9521)
* [Auth: Kiali uses static bearer token for Prometheus/Tracing auth, breaks with short-lived projected SA tokens](https://github.com/kiali/kiali/issues/9488)
* [Server: Kiali Fails to Startup With Health Cache Enabled](https://github.com/kiali/kiali/issues/9476)
* [UI: Application link can navigate to workload detail](https://github.com/kiali/kiali/issues/9468)
* [UI: workload list health status tooltip always showing 0 pods](https://github.com/kiali/kiali/issues/9471)

## 2.24.0
Release: March 30, 2026

Features:

* [AI: Optimize get_istio_config tool for better parsing and token efficiency](https://github.com/kiali/kiali/issues/9136)
* [AI: Handle impact of new Namespaces page.](https://github.com/kiali/kiali/issues/9250)
* [Build: Upgrade Node.js from v20 to v24](https://github.com/kiali/kiali/issues/9328)
* [Build: Migrate from Yarn v1 to Yarn v4](https://github.com/kiali/kiali/issues/9111)
* [Build: Upgrade Golang from v1.24 to v1.25](https://github.com/kiali/kiali/issues/)
* [Kiali.io: Update docs with changes related to new overview page](https://github.com/kiali/kiali/issues/9294)
* [Server: Automatically set GOMEMLIMIT based on available memory (container cgroups / system)](https://github.com/kiali/kiali/issues/8987)
* [UI: Ambient and sidecars badges in the overview/namespaces pages](https://github.com/kiali/kiali/issues/9306)
* [UI: Overview Page Service Insights should incorporate L4 metrics](https://github.com/kiali/kiali/issues/9281)
* [UI: Overview Page re-order top row cards to group infrastructure](https://github.com/kiali/kiali/issues/9360)
* [UI: Improve UX for Graph Display menu](https://github.com/kiali/kiali/pull/9355)

Fixes:

* [PF6 misalignment issues](https://github.com/kiali/kiali/issues/9099)
* [K8s Client (cluster2) is not found or is not accessible for Kiali, when attempting multi-cluster configuration feature](https://github.com/kiali/kiali/issues/8500)
* [(AI)(Tool) get_resource_detail: Remove 'istio' and 'app' from allowed resourceTypes](https://github.com/kiali/kiali/issues/9359)
* [(AI)(Tool)(Panic) get_mesh_graph throw panic when the namespace not exist](https://github.com/kiali/kiali/issues/9363)

#### Upgrade Change Notes:

**kiali_health_status metric**

Starting in v2.22, when the health cache and kiali metrics are both enabled (true by default) Kiali would also write a new metric, `kiali_health_status`. The initial implementation proved to be too heavy from a cardinality perspective. This metric has been redefined in v2.24 and will now generate a much lower cardinality of time series. Also, it is now opt-in, controlled by `spec.server.observability.metrics.health_status.enabled`. So, by default in v2.24, this metric will be disabled. The metric name remains the same, although attributes have been altered. Unless manually manipulated, existing series will remain in Prometheus until they naturally expire.

## 2.23.0
Release: March 09, 2026

Features:

* [AI: Implement get_resource_metrics tool for CPU and Memory monitoring.](https://github.com/kiali/kiali/issues/9138)
* [AI: Implement get_logs tool for retrieving pod/container logs.](https://github.com/kiali/kiali/issues/9140)
* [AI: Comprehensive documentation for features.](https://github.com/kiali/kiali/issues/9147)
* [AI: Integrate Chatbot AI into new Overview and Namespace pages](https://github.com/kiali/kiali/issues/9153)
* [API: K8s GW API to v1.5.0](https://github.com/kiali/kiali/issues/9275)
* [OSSMC: New Overview page](https://github.com/kiali/kiali/issues/9189)
* [Security: Update to Go v1.24.13](https://github.com/kiali/kiali/issues/9261)
* [Server: Remove Istio Service Registry dependency on Validations](https://github.com/kiali/kiali/issues/6922)
* [UI: New Overview and Namespaces Pages](https://github.com/kiali/kiali/issues/8845)

Fixes:

* [Multiple Kiali metric-calculation defects produce incorrect user-visible values](https://github.com/kiali/kiali/issues/9297)
* [remove root_namespace section in docs](https://github.com/kiali/kiali/issues/9236)
* [Nil pointer dereference in SubsetPresenceChecker when VirtualService has nil route destinations](https://github.com/kiali/kiali/issues/9276)

## 2.22.0
Release: February 16, 2026

Features:

* [AI: Implement AI Chatbot Widget & MCP Integration (Dev Preview)](https://github.com/kiali/kiali/issues/9079)
* [Perf: Introduce health pre-compute](https://github.com/kiali/kiali/issues/8900)
* [Tracing: new use_waypoint_name config option (incorrect service name in Jaeger link)](https://github.com/kiali/kiali/issues/9158)
* [UI: SPIRE support](https://github.com/kiali/kiali/pull/9067)
* [UI: Replace react-datepicker with PatternFly 6 components](https://github.com/kiali/kiali/issues/9098)

Fixes:

* [UI: Slow loading of workloads](https://github.com/kiali/kiali/issues/9070)
* [UI: PF6 Wizard Migration Issues](https://github.com/kiali/kiali/issues/9091)
* [UI: Offline mode does not display Istio Config page](https://github.com/kiali/kiali/issues/9171)

#### Upgrade Change Notes:

**Health Status Pre-Compute and Caching**

Kiali v2.22 introduces health status pre-compute and caching which is enabled by default. Production mesh sizes are growing and Kiali render times have been increasing, particularly for the Overview and List pages. In response, Kiali v2.22 changes its approach to health status calculation. In prior versions Kiali calculated health "on-demand", based on the user's selected duration, configuration settings, and other information, such as pod status. Starting in v2.22 Kiali will pre-calculate health status using a single, configurable duration, 5 minutes by default. The cached values increase the responsiveness of the Overview and List pages. Other pages, such as the Traffic graph and Detail pages will continue to calculate health status on-demand, and is based on the user's selected duration. Users may notice that the Duration Dropdown selector has been removed from the Overview and List pages.

Users may notice an increase in backend resource utilization, as the Kiali server will now be calculating and refreshing health status, independent of user sessions. The Kiali CR introduces the following new configuration:

`spec.health_config.compute.duration: 5m`
`spec.health_config.compute.refresh_interval: 3m`
`spec.health_config.compute.timeout: 10m`

`spec.kiali_internal.health_cache.enabled: false`

It is recommended to keep the health cache enabled, as not all features will fall back to on-demand calculation.

Any questions, comments or feedback appreciated. Visit `#kiali` on Istio Slack or start a Discussion in Github at `https://github.com/kiali/kiali`.

## 2.21.0
Release: January 26, 2026

Features:

* [Auth: Provide explicit OIDC config if .well-known/openid-configuration is locked down](https://github.com/kiali/kiali/issues/8777)
* [Auth: Use auto-rotated certificates for external service (e.g. prometheus) connectivity](https://github.com/kiali/kiali/issues/8888)
* [Auth: Support OpenID Authorization Code Flow with PKCE (SSO)](https://github.com/kiali/kiali/issues/8421)
* [Perf: Introduce background graph refresh and caching](https://github.com/kiali/kiali/issues/8871)
* [Perf: Improve traffic graph client-side rendering, particularly when displaying many service nodes](https://github.com/kiali/kiali/pull/9005)
* [Security: Enforce platform TLS profiles in Kiali via OpenShift-aware auto mode and kiali config fallback](https://github.com/kiali/kiali/issues/9033)
* [UI: Masthead status improved layout and multi-mesh handling](https://github.com/kiali/kiali/issues/8710)
* [UI: Notification center improvements for message detail handling](https://github.com/kiali/kiali/issues/8979)

Fixes:

* [Ambient: Fix missing Idle Node display in traffic graph, when not showing Waypoints](https://github.com/kiali/kiali/issues/9009)
* [Auth: Session persistor fixes re: chunked sessions and multi-session scenarios](https://github.com/kiali/kiali/issues/8990)
* [Perses: Validate OpenShift dashboards](https://github.com/kiali/kiali/issues/9014)

#### Upgrade Change Notes:

**Traffic Graph Caching**

Kiali v2.21 introduces traffic graph caching. Enabled by default. When a user navigates to the Traffic Graph and renders the initial graph, Kiali will start a background job to regenerate the graph periodically, based on the refresh interval set in the UI. The background job will cache the resulting graph and return it on subsequent UI requests. This can greatly improve re-render times, especially for larger graphs. Note that the initial graph render time will be unchanged. It is still recommended to use "Manual" refresh when working with large meshes, in order to fully define the desired graph before performing the initial request. Any fundamental change to the graph definition will invalidate the cache and restart a new refresh job. Users can navigate away and then back to the traffic graph, and resume with the latest cached graph, within the timeout period (10m by default).

Backend resource utilization may be affected, although is not anticipated to change significantly. The caching can be disabled in the Kiali config via:

`spec.kiali_internal.graph_cache.enabled: false`

Any questions, comments or feedback appreciated. Visit `#kiali` on Istio Slack or start a Discussion in Github at `https://github.com/kiali/kiali`.

## 2.20.0
Release: December 22, 2025

Features:

* [Maintenance: Upgrade to TypeScript 5](https://github.com/kiali/kiali/issues/8539)
* [OSSMC: Upgrade to Patternfly 6](https://github.com/kiali/openshift-servicemesh-plugin/issues/518)
* [UI: Upgrade to PatternFly 6](https://github.com/kiali/kiali/issues/8022)
* [UI: Replace legacy message center](https://github.com/kiali/kiali/issues/8911)

Fixes:

* [GWAPI IE: Errors in Kiali logs when namespace stack](https://github.com/kiali/kiali/issues/8918)
* [Mesh Page: sporadic null reference in SummaryPanelClusterBox](https://github.com/kiali/kiali/issues/8903)
* [UI: Could not fetch workloads list](https://github.com/kiali/kiali/issues/8908)

## 2.19.0
Release: November 24, 2025

Features:

* [AI: Kiali now has AI and Agent Policy and Contribution guidelines](https://github.com/kiali/kiali/issues/8872)
* [Config: Kiali CR now supports adding custom initContainers to the Kiali deployment](https://github.com/kiali/kiali/issues/8616)
* [Helm Charts: Server helm chart now supports cluster_wide_access=false](https://github.com/kiali/kiali/issues/8854)
* [K8s GW API: v1.4.0 support](https://github.com/kiali/kiali/issues/8791)

Fixes:

* [Ambient: Fix "isAmbient" CP identification and Overview page badging](https://github.com/kiali/kiali/issues/8867)
* [Mesh Page: Fix missing validations for Data Plane side-panel](https://github.com/kiali/kiali/issues/8863)
* [UI: Masthead tooltip fixes for status and duplication](https://github.com/kiali/kiali/issues/8830)

## 2.18.0
Release: November 03, 2025

Features:

* [Mesh Page: improvements for multiple controlplanes](https://github.com/kiali/kiali/issues/8684)
* [Perses: 'openshift' URL format](https://github.com/kiali/kiali/issues/8806)
* [Operator: Sidecar usage extension](https://github.com/kiali/kiali/issues/5028)
* [Operator: NetworkPolicy for OLM-installed operator](https://github.com/kiali/kiali/issues/8813)
* [OSSMC: Add Netobserv Navigation traffic graph side-panel](https://github.com/kiali/openshift-servicemesh-plugin/issues/507)

Fixes:

* [URI too large](https://github.com/kiali/kiali/issues/8827)
* [Making cluster-wide namespace query when cluster-wide-access is false](https://github.com/kiali/kiali/issues/8826)

## 2.17.0
Release: October 13, 2025

Features:

* [Auth: Support of multiple audiences in OIDC](https://github.com/kiali/kiali/issues/8717)
* [Config: Remove use of conf.ExternalServices.Istio.Registry](https://github.com/kiali/kiali/issues/8692)
* [Dependencies: Update GoLang to 1.24.4](https://github.com/kiali/kiali/issues/8755)
* [GW API: Support Inference Extension v1](https://github.com/kiali/kiali/issues/8782)
* [Mesh Page: Show Kiali when in Local mode](https://github.com/kiali/kiali/issues/8668)
* [OSSMC: New "openshift" url_format for Tracing configuration](https://github.com/kiali/kiali/issues/8762)
* [Security: Allow configuration of NetworkPolicy to restrict Kiali ingress traffic](https://github.com/kiali/kiali/issues/8536)
* [Troubleshooting: Improve Kiali tracing by forwarding `x-request-id` header to prometheus calls](https://github.com/kiali/kiali/issues/8468)

Fixes:

* [OSSMC: Handle correctly pods page with no controller](https://github.com/kiali/kiali/issues/8749)
* [OSSMC: Distributed tracing plugin not doing redirection](https://github.com/kiali/kiali/issues/8765)
* [Server: Fix potential crash in Mesh Discovery](https://github.com/kiali/kiali/issues/8759)
* [UI: Scroll issue in Istio Config page](https://github.com/kiali/kiali/issues/8751)
* [UI: Kiali observability detail views not available to custom GVKs](https://github.com/kiali/kiali/issues/8781)

#### Upgrade Change Notes:

**The following fields are no longer used by the Kiali CR and MUST be removed, if currently set.**

* `spec.external_services.istio.registry`

## 2.16.0
Release: September 22, 2025

Features:

* [CRD: Autodetect `RootNamespace`](https://github.com/kiali/kiali/issues/8674)
* [GatewayAPI: Support clusters that only have Gateway API gateways but no Istio gateways](https://github.com/kiali/kiali/issues/8655)
* [Perf: graph "Show Virtual Services" option controls "istio_detail" appender execution](https://github.com/kiali/kiali/issues/8732)
* [Perf: optimizations for the istio_detail graph appender](https://github.com/kiali/kiali/issues/8731)

Fixes:

* [Ambient: Fix validations in KIA1312, KIA1313 and KIA1316](https://github.com/kiali/kiali/issues/8678)
* [UI: Fix missing version info in About box](https://github.com/kiali/kiali/issues/8700)

#### Upgrade Change Notes:

**Discovery Selectors**

Kiali now properly supports Istio control planes deployed into different namespaces. As part of this
support both the `spec.istio_namespace` and `spec.external_services.istio.root_namespace` configuration
fields have been removed. As such, Kiali Discovery Selectors, when defined, must include Istio's
control plane namespace(s). If you are using Kiali Discovery Selectors, please ensure that this
new requirement is met. Note that Kiali's deployment namespace is always included, and so co-located
Istio control planes will be discovered.

**The following fields are no longer used by the Kiali CR and MUST be removed, if currently set.**

* `spec.external_services.istio.root_namespace`


## 2.15.0
Release: September 02, 2025

Features:

* [Ambient: Improvements to Ambient workload validation](https://github.com/kiali/kiali/issues/6041)
* [CI: Run all cypress tests from tags](https://github.com/kiali/kiali/issues/8607)
* [CI: Add tests for kiali server/operator helm-charts](https://github.com/kiali/kiali/issues/8659)
* [CI: Validate CRDs are synced during release](https://github.com/kiali/kiali/issues/8681)
* [Deployment: Add support for "local" mode](https://github.com/kiali/kiali/issues/8632)
* [Deployment: Provide a schema for the Kiali CRD](https://github.com/kiali/kiali/issues/8237)
* [Deployment: Support multiple control planes in different namespaces on the same cluster](https://github.com/kiali/kiali/issues/8606)
* [Operator: provide a way to verify operator permissions are correct](https://github.com/kiali/kiali/issues/8643)
* [Perf: Only cache ConfigMaps in namespaces with controlplanes](https://github.com/kiali/kiali/issues/8394)
* [Perses: Add support for Perses Dashboard](https://github.com/kiali/kiali/issues/8578)

Fixes:

* [Ambient: fix startup OOM in ambient environments](https://github.com/kiali/kiali/issues/8657)
* [Operator: operator-sdk is now gone - operator release needs another way to verify bundle](https://github.com/kiali/kiali/issues/8621)
* [Operator: missing permission in CSV for OLM installs](https://github.com/kiali/kiali/issues/8639)
* [UI: Multicluster Workload Validations icon padding](https://github.com/kiali/kiali/issues/8648)

#### Upgrade Change Notes:

Version 2.15.0 introduces a CRD schema for Kiali. The CRD version has not changed. But, validation will now occur on the cluster when the Kiali CRs are created or modified.

## 2.14.0
Release: August 08, 2025

Features:

* [Ambient: UI support to add namespace to Ambient mesh](https://github.com/kiali/kiali/issues/7901)
* [Deployment: Support for external kiali deployment option](https://github.com/kiali/kiali/issues/8470)
* [Gateway API: Upgrade K8s Gateway API to v1.3.0](https://github.com/kiali/kiali/issues/8272)
* [Gateway API: Support Gateway API Inference Extension](https://github.com/kiali/kiali/issues/8555)

Fixes:

* [Authorization: do not perform cluster-wide query when cluster wide access is disabled](https://github.com/kiali/kiali/issues/8585)
* [Multi-cluster: Detect monitoring port for each controlplane](https://github.com/kiali/kiali/issues/8553)
* [Validation: Kiali does not recognize `istio-remote` gateway class](https://github.com/kiali/kiali/issues/8590)

#### Upgrade Change Notes:

**The following fields are no longer used by the Kiali CR and MUST be removed, if currently set.**

* no longer used
  * `spec.istio_namespace`
  * `spec.in_cluster`
  * `spec.deployment.remote_secret_path`
* now auto-discovered
  * `spec.external_services.istio.config_map_name`
  * `spec.external_services.istio.istiod_pod_monitoring_port`
  * `spec.external_services.istio.envoy_admin_local_port`
  * `spec.external_services.istio.istio_canary_version`
  * `spec.external_services.istio.istio_injection_annotation`
  * `spec.external_services.istio.istio_sidecar_annotation`
  * `spec.external_services.istio.istiod_deployment_name`
  * `spec.external_services.istio.istiod_pod_monitoring_port`
  * `spec.external_services.istio.url_service_version`

## 2.13.0
Release: July 21, 2025

Features:

* [I18N: Spanish localization (partial)](https://github.com/kiali/kiali/pull/8567)
* [Istio Config: Initial support for GW API Inference extension](https://github.com/kiali/kiali/issues/8555)
* [Mesh Page: Unify config format](https://github.com/kiali/kiali/issues/8493)
* [Mesh Page: Consistent istio Metrics](https://github.com/kiali/kiali/issues/8552)

Fixes:

* [MeshPage: Fix dataplane namespace count](https://github.com/kiali/kiali/pull/8573)

## 2.12.0
Release: Jun 30, 2025

Features:

* [Usability: Cleanup logs](https://github.com/kiali/kiali/issues/8347)
* [Usability: Easy configuration/export of diagnostics](https://github.com/kiali/kiali/issues/8349)
* [Usability: Show json logs in a more human readable format](https://github.com/kiali/kiali/issues/7066)
* [Usability: Improve diagnostics for measuring performance](https://github.com/kiali/kiali/issues/8345)
* [Usability: Improve tracing tool](https://github.com/kiali/kiali/issues/8472)
* [Helm: be able to tell helm to skip creation of some resources](https://github.com/kiali/kiali/issues/8491)
* [Operator: Adapt bundle CSV to FBC](https://github.com/kiali/kiali/issues/8507)
* [Tracing: Be able to change the Trace limit default](https://github.com/kiali/kiali/issues/8517)
* [Molecule: try to workaround another transient ansible galaxy error](https://github.com/kiali/kiali/issues/8527)
* [Kiali.io: Features update](https://github.com/kiali/kiali/issues/8531)
* [CI: Grafana Test Flake in OSSMC](https://github.com/kiali/kiali/issues/8503)
* [CI: Shared Mesh page flaky test](https://github.com/kiali/kiali/issues/8518)
* [CI: Add test coverage for the tracing tool](https://github.com/kiali/kiali/issues/8528)

Fixes:

* [Tracing: Improve coverage when auth is specified but not required](https://github.com/kiali/kiali/issues/8494)
* [Operator: change of kiali version produces error in op logs](https://github.com/kiali/kiali/issues/8505)
* [OSSMC (CI): Adapt OSSMC cypress tests to OCP 4.19](https://github.com/kiali/openshift-servicemesh-plugin/issues/455)
* [OSSMC (CI): Cannot create property 'url' on string 'GET'](https://github.com/kiali/kiali/issues/8495)
* [OSSMC (CI): failure in Workload logs tab](https://github.com/kiali/kiali/issues/8540)

## 2.11.0
Release: Jun 09, 2025

Features:

* [Ambient: Support for ingress-use-waypoint](https://github.com/kiali/kiali/issues/8338)
* [Grafana: support datasource_uid parameter for Grafana dashboards links](https://github.com/kiali/kiali/issues/7760)
* [Istio: Support merging of multiple Istio configmaps](https://github.com/kiali/kiali/issues/8248)
* [Kiali.io: document how to test a remote cluster secret / kubeconfig](https://github.com/kiali/kiali/issues/8358)
* [Kiali.io: document how to use Kiali diagnostics for measuring performance](https://github.com/kiali/kiali/issues/8449)
* [Operator: Refactor to not use kubernetes.core.k8s_cluster_info task](https://github.com/kiali/kiali/issues/8459)
* [Perf: Remove Endpoints caching](https://github.com/kiali/kiali/issues/8396)
* [Tracing: Mesh page "Check Status" option to help troubleshooting](https://github.com/kiali/kiali/issues/8361)
* [Usability: Improve Kiali Logs and metrics for timing of a request](https://github.com/kiali/kiali/issues/8348)

Fixes:

* [Ambient: Mode detection fix - DaemonSet filtering label matching assumes exact map match, uses wrong source of data](https://github.com/kiali/kiali/issues/8464)
* [Ambient: Fix runtime error starting Kiali outside the cluster with Istio Ambient](https://github.com/kiali/kiali/issues/8480)
* [UI: Show GW API Icon for GWs in the graph](https://github.com/kiali/kiali/issues/8442)
* [UI: Fix internal server error when editing a workload](https://github.com/kiali/kiali/issues/8478)
* [Usability: Fix missing Kiali metrics](https://github.com/kiali/kiali/issues/8458)

## 2.10.0
Release: May 18, 2025

Features:

* [Ambient: Include ztunnel table filters](https://github.com/kiali/kiali/issues/7996)
* [Code: Adopt controller-runtime client](https://github.com/kiali/kiali/issues/8355)
* [Code: Adopt github.com/go-jose/go-jose/v3 instead of github.com/go-jose/go-jose](https://github.com/kiali/kiali/issues/8373)
* [Gateway API: Load all k8s gateway API classes that use Istio as a controller](https://github.com/kiali/kiali/issues/8220)
* [Kiali.io: Document features that enable you to more easily view a large graph](https://github.com/kiali/kiali/issues/5043)
* [Mesh Page: Load user config, if configured, and show on mesh page for istiod](https://github.com/kiali/kiali/pull/8330)
* [Support: Add structured logging](https://github.com/kiali/kiali/issues/8346)
* [Validation: Allow disabling validations](https://github.com/kiali/kiali/issues/8317)

Fixes:

* [Ambient: Error Unmarshalling the config_dump in Istio Ambient 1.26](https://github.com/kiali/kiali/issues/8381)
* [Build: Not able to build v1.73 integration test image + runtime GLIBC error from `oc`](https://github.com/kiali/kiali/issues/8376)
* [OSSMC: Trying to show traffic animation in OpenShift console leads to error](https://github.com/kiali/kiali/issues/8417)
* [Tempo: Does not return traces with error](https://github.com/kiali/kiali/issues/8406)

## 2.9.0
Release: Apr 25, 2025

Features:

* [CI: Use the sail operator instead of istioctl to deploy istio](https://github.com/kiali/kiali/issues/7830)
* [CI: Update primary-remote (multicluster) pipeline to use Sail Operator](https://github.com/kiali/kiali/issues/8097)
* [CI: Update external control plane pipeline to use Sail Operator](https://github.com/kiali/kiali/issues/8098)
* [CI: Update workflows /test-istio-version.yml to use sail operator](https://github.com/kiali/kiali/issues/8289)
* [Kiali.io: document the features that are supported by the operator but not by the server helm chart](https://github.com/kiali/kiali/issues/8314)
* [Operator: Allow providing extra labels for server and operator](https://github.com/kiali/kiali/issues/8315)
* [UI: Add "Manual" refresh interval](https://github.com/kiali/kiali/issues/8344)
* [UI: Scroll in tables with sticky headers](https://github.com/kiali/kiali/issues/8197)

Fixes:

* [Demos: Service Spawner demo not generating traffic ](https://github.com/kiali/kiali/issues/6357)
* [Perf: Kiali uses a lot of CPU (in validations)](https://github.com/kiali/kiali/issues/8007)
* [Perf: Mesh page hangs for a long time when a component status is unhealthy](https://github.com/kiali/kiali/issues/8304)
* [Server: Kiali not working when Istio native sidecars feature is disabled](https://github.com/kiali/kiali/issues/8259)
* [Server: Difference in Istio and Kiali Workload Name for Argo Rollouts](https://github.com/kiali/kiali/issues/8284)
* [Operator: defining an inaccessible cluster in Kiali CR breaks the operator](https://github.com/kiali/kiali/issues/8321)
* [UI: Node selection not working when navigating to graph from trace detail](https://github.com/kiali/kiali/issues/8258)

## 2.8.0
Release: Apr 07, 2025

Features:

* [Ambient: Include ztunnel specific metrics](https://github.com/kiali/kiali/issues/8024)
* [Hack scripts: Support for auto-injection-label in all install scripts](https://github.com/kiali/kiali/issues/7952)
* [Mesh page: Include Kiali resource metrics in side-panel](https://github.com/kiali/kiali/issues/8196)
* [Operator: Watch for changes to remote cluster secrets](https://github.com/kiali/kiali/issues/6941)
* [OSSMC: Integrate console tracing  with Kiali plugin](https://github.com/kiali/kiali/issues/7904)
* [Perf: Ambient graph generation optimization](https://github.com/kiali/kiali/pull/8277)
* [Perf: Validation MultiMatchChecker optimization](https://github.com/kiali/kiali/issues/8211)
* [Perf: Validation VirtualServices SubsetPresenceChecker optimization](https://github.com/kiali/kiali/issues/8210)
* [Security: Use multi-cluster secret if it exists in the namespace](https://github.com/kiali/kiali/issues/7877)
* [UI: Enhance masthead Istio Status with multi-cluster support and improved UX](https://github.com/kiali/kiali/issues/7724)
* [UI: Workload detail Pod listing now shows the revision annotation](https://github.com/kiali/kiali/issues/8154)

Fixes:

* [Health: Service Health calculation wrongly](https://github.com/kiali/kiali/issues/8203)
* [Health: Ambient Inconsistency of Service Health between pages](https://github.com/kiali/kiali/issues/8189)
* [K8s Gateway: API CRD check improvement](https://github.com/kiali/kiali/issues/8271)

Deprecations:

* [Remove Cytoscape graph implementation](https://github.com/kiali/kiali/issues/8053)

After a 4 month deprecation period the support for Kiali's original, Cytoscape-based, graph implementation has ended.
The 'spec.kiali_feature_flags.ui_defaults.graph.impl' configuration setting is no longer supported, and the sole
implementation going forward uses PatternFly Topology. This has allowed for a significant cleanup of the Kiali
code base, and removal of several dated dependencies. We'd like to thank the [Cytoscape project](https://cytoscape.org/),
without which Kiali would not have existed. It is an excellent library, and our migration to PatternFly was motivated
by a need to settle on a uniform component library.

## 2.7.0
Release: Mar 17, 2025

Features:

* [Ambient: Add metrics to ztunnel tab for workload detail](https://github.com/kiali/kiali/issues/8145)
* [Ambient: Add ztunnel resource consumption metrics to Mesh page side panel](https://github.com/kiali/kiali/issues/8144)
* [Perf: Validation and other perf enhancements](https://github.com/kiali/kiali/issues/8007)


Fixes:

* [Code: Fix data race in GetKialiTokenForHomeCluster](https://github.com/kiali/kiali/issues/6641)
* [Graph: PFT graph find/hide broken for "label:" operand](https://github.com/kiali/kiali/issues/8232)
* [Validation: Inconsistency between Service list validation and service details](https://github.com/kiali/kiali/issues/8139)
* [Validation: Service Details Config Validations Inconsistency](https://github.com/kiali/kiali/issues/8228)

## 2.6.0
Release: Feb 21, 2025

Features:

* [Ambient: Waypoint proxy log improvement](https://github.com/kiali/kiali/issues/7899)
* [Ambient: Add ztunnel to mesh topology](https://github.com/kiali/kiali/issues/8143)
* [Ambient: Recognize any gateway as a Waypoint if "waypoint" is in the name](https://github.com/kiali/kiali/issues/8050)
* [Config: Allow mixed app and verion labeling schemes](https://github.com/kiali/kiali/issues/7603)

Fixes:

* [Ambient: No ztunnel logs with waypoint in Istio 1.23](https://github.com/kiali/kiali/issues/8146)
* [Ambient: Some Waypoint proxies are reported incorrectly](https://github.com/kiali/kiali/issues/8157)
* [Authz: Fix access to DeploymentConfig (and some others)](https://github.com/kiali/kiali/issues/8084)
* [GW API: Wrong ReferenceGrant apiVersion from Kiali server](https://github.com/kiali/kiali/issues/8133)
* [Logging: Istio sidecar logs missing with k8s native sidecar enabled](https://github.com/kiali/kiali/issues/7909)
* [Mesh page: side panel does not stay in sync with mesh graph](https://github.com/kiali/kiali/issues/8159)
* [Perf: Jaeger version check leads to delayed Kiali login screen until timeout occur](https://github.com/kiali/kiali/issues/8100)
* [Tracing: Spans missing References values when Tempo is used](https://github.com/kiali/kiali/issues/8112)
* [Tracing: Kiali does not report trace connectivity error](https://github.com/kiali/kiali/issues/8106)
* [UI: Istio-system applications shown as out of mesh](https://github.com/kiali/kiali/issues/8172)

Upgrade Notes:

The default values for the following Kiali CR fields have changed:

* spec.istio_labels.app_label_name
  * previous default: "app"
  * new default:      unset
* spec.istio_labels.version_label_name
  * previous default: "version"
  * new default:      unset

The change is related to the work done for [Kiali issue 7603](https://github.com/kiali/kiali/issues/7603), included with this release. By default Kiali now allows for a mixing app labeling schemes, using the same set of app and version label pairings recognized by Istio:

* service.istio.io/canonical-name, service.istio.io/canonical-revision
* app.kubernetes.io/name, app.kubernetes.io/version
* app, version

Users can configure a single labeling scheme by setting the existing CR fields, or leaving them set when upgrading.


## 2.5.0
Release: Feb 03, 2025

Features:

* [Ambient: Trace support](https://github.com/kiali/kiali/issues/5979)
* [Istio: Workload Entry and Workload Group support for VMs](https://github.com/kiali/kiali/issues/7107)
* [Istio: WorkloadGroup Validations](https://github.com/kiali/kiali/issues/8058)
* [Mesh Page: visualize gateways and waypoints](https://github.com/kiali/kiali/issues/8054)
* [Multicluster: When login to remote cluster fails, no visible error appears](https://github.com/kiali/kiali/issues/7925)
* [Operator: Add topologySpreadConstraints](https://github.com/kiali/kiali/issues/5614)
* [Security: configure /api endpoint to require authentication](https://github.com/kiali/kiali/issues/8057)
* [Istio: show configurations for K8sGateways](https://github.com/kiali/kiali/issues/8075)

Fixes:

* [Ambient: Error reading logs when user doesn't have permissions for ztunnel](https://github.com/kiali/kiali/issues/8033)
* [Misc: Fix mixed object references with the same name for k8s gw](https://github.com/kiali/kiali/issues/8101)
* [Multicluster: Error namespace not found in Multi Cluster](https://github.com/kiali/kiali/issues/8081)
* [UI: Fix color-scheme cached value handling](https://github.com/kiali/kiali/issues/8069)

## 2.4.0
Release: Jan 13, 2025

Features:

* [Ambient: Improve waypoint visualization](https://github.com/kiali/kiali/issues/7999)
* [Config: Support Workload Group workload in list view](https://github.com/kiali/kiali/issues/7107)
* [Misc: Formally support previous versions of Istio in Kiali releases](https://github.com/kiali/kiali/issues/7932)
* [Misc: dual stack ipv6 support](https://github.com/kiali/kiali/issues/7902)

Fixes:

* [Operator: when on openshift, if ingress is disabled, skip some things that require the Route and abort if using openshift auth strategy](https://github.com/kiali/kiali/issues/8023)
* [Tracing: GRPC Jaeger client using old tag for istio multi cluster](https://github.com/kiali/kiali/issues/7997)
* [Tracing: Tempo Version url doesn't work with TLS](https://github.com/kiali/kiali/issues/8036)
* [UI: Workload Traffic tab navigation leaves Overview tab confused](https://github.com/kiali/kiali/issues/8034)
* [UI: Irregular metrics loading error ](https://github.com/kiali/kiali/issues/8025)

## 2.3.0
Release: Dec 23, 2024

Features:

* [Ambient - Several troubleshooting additions](https://github.com/kiali/kiali/pull/7970)
* [Maintenance - Go version 1.23.2](https://github.com/kiali/kiali/issues/7977)
* [Tempo - Performance review and cache introduced](https://github.com/kiali/kiali/issues/7769)
* [Traffic Graph - New "point-style" traffic animation](https://github.com/kiali/kiali/issues/7934)
* [UI - Show dual stack IPs in service details](https://github.com/kiali/kiali/issues/8004)

Fixes:

* [Traffic graph - In ambient mode, graph missed some gateway traffic](https://github.com/kiali/kiali/issues/7937)
* [UI - Kiosk mode Time duration component does not handle the URL correctly](https://github.com/kiali/kiali/issues/7958)
* [Validations - KIA1104 should only show when there is one route destination but has explicit weight assigned and less than 100 on tcp/tls route](https://github.com/kiali/kiali/issues/8000)

## 2.2.0
Release: Dec 02, 2024

Features:

* [Core, UI - Alternative Workload controllers support](https://github.com/kiali/kiali/issues/7820)
* [Multicluster - Pull the CA from the cluster and add that to the remote secret](https://github.com/kiali/kiali/issues/7926)
* [Operator, Core - Adjustable readiness and liveness probes delay](https://github.com/kiali/kiali/issues/7832)
* [Operator, Multicluster - allow multiple Kiali Servers in the same cluster each have cluster-wide-access enabled](https://github.com/kiali/kiali/issues/7922)
* [Tempo - Optimize Tempo query](https://github.com/kiali/kiali/issues/7903)
* [UI - Enable the Selection-based zoom in PFT](https://github.com/kiali/kiali/issues/7929)
* [Validation, UI - Make gateways optional in istio status](https://github.com/kiali/kiali/issues/7882)

Fixes:

* [UI - Traffic graph Zoomed-in "reset view" not resizing correctly](https://github.com/kiali/kiali/issues/7935)
* [UI - Workload detail missing envoy tab when Istio working with native sidecars](https://github.com/kiali/kiali/issues/7940)

## 2.1.0
Release: Nov 11, 2024

Features:

* [Mesh Page - Consistent display format for configuration values on the Mesh page](https://github.com/kiali/kiali/issues/7623)
* [Mesh Page - Canary upgrade status only uses home cluster](https://github.com/kiali/kiali/issues/7726)
* [Operator - Operator should look for OpenShiftAPIServer to determine if its running on OCP](https://github.com/kiali/kiali/issues/7841)
* [Operator - Bump base image to 4.17 / 1.35.0](https://github.com/kiali/kiali/issues/7856)
* [Security - Move base image of Kiali Server to UBI9 / RHEL9](https://github.com/kiali/kiali/issues/7896)
* [UI - Config list items should properly use Group + Version + Kind for kube resources](https://github.com/kiali/kiali/issues/7457)
* [UI - Improve color choice for "Not Ready" icon in dark-mode](https://github.com/kiali/kiali/issues/7317)

Fixes:

* [Ambient - External service shown as unknown](https://github.com/kiali/kiali/issues/7875)
* [Ambient - When the graph nodes are inaccesible, the graph has duplicated edges (From L4 and L7)](https://github.com/kiali/kiali/issues/7843)
* [Ambient - Kiali doesn't show connection from ambient to sidecar injected namespace as mTLS](https://github.com/kiali/kiali/issues/7811)
* [Mesh Page - Failed to get istio deployment status when using IP in external services URLs](https://github.com/kiali/kiali/issues/7844)
* [Minigraph - Unable to navigate between workloads using the minigraph](https://github.com/kiali/kiali/issues/7839)
* [Traffic Graph - Graph hide can leave orphan edges](https://github.com/kiali/kiali/issues/7878)
* [Traffic Graph - PFT graph page throws a console error when the user navigates to the graph from a details page](https://github.com/kiali/kiali/issues/7802)
* [UI - Config list items must include apiVersion value when the Istio object is created outside of Kiali](https://github.com/kiali/kiali/issues/7452)
* [Validation - Istio validations inconsisteny - exported to other namespace](https://github.com/kiali/kiali/issues/7690)
* [Validation - Kiali states pod has no Istio sidecar under Workloads even though Istio has native sidecar support enabled](https://github.com/kiali/kiali/issues/7789)

Deprecations:
- RedHat Community Operator
  - The community operator created confusion as to which operator to use on OpenShift. It will no longer be updated and will eventually be
    removed. OpenShift users are encouraged to use the productized operator, which is included with licensed copies of OpenShift.

## 2.0.0
Release: Oct 21, 2024

The first major Kiali release in over 5 years!  There are two main reasons for the major version update:

1. There is a breaking change in Kiali's namespace management configuration. To limit the namespaces accessible to Kiali, or made visible to users, Kiali v2.0 users will configure Discovery Selectors.

There is no longer support for the following deprecated configuration settings:

  * spec.deployment.accessible_namespaces
  * api.namespaces.exclude
  * api.namespaces.include
  * api.namespaces.label_selector_exclude
  * api.namespaces.label_selector_include

2. Kiali has a new traffic graph implementation.

The Cytoscape implementation has been deprecated and is no longer the default. Kiali has moved to PatternFly Topology to align with the rest of the Kiali interface, which is already implemented using PatternFly components.  The old graph implementation will be removed as soon as the Kiali maintainers believe the new implementation has proven itself in the field. Until that time, it can still be accessed by setting:

```yaml
spec:
  kiali_feature_flags:
    ui_defaults:
      graph:
        impl: "cy"
```

Features:

* [Ambient Graph - Improve Ambient Graph](https://github.com/kiali/kiali/issues/7445)
* [Ambient Graph - Better visualize ztunnel](https://github.com/kiali/kiali/issues/6900)
* [Ambient Graph - Treat waypoint nodes as workloads, not apps](https://github.com/kiali/kiali/issues/7702)
* [Ambient Graph - Use bidirectional edges between workloads and waypoints](https://github.com/kiali/kiali/issues/7706)
* [Configuration - Discovery Selectors, enhance namespace accessibility per Discovery KEP](https://github.com/kiali/kiali/issues/7546)
* [Configuration - change names of url / in_cluster_url to better reflect what they are](https://github.com/kiali/kiali/issues/7745)
* [Configuration - Auto-detect more Istio config for ease-of-configuration](https://github.com/kiali/kiali/issues/7177)
* [Configuration - Be able to specify auth.username and custom dashboards auth via secrets](https://github.com/kiali/kiali/issues/7795)
* [Configuration - Support for additional environment variables in deployment](https://github.com/kiali/kiali/issues/7569)
* [Extensions - Support 3rd party traffic metrics per Extensions KEP](https://github.com/kiali/kiali/issues/7485)
* [Gateway API - K8s GW API v1.2.0 support](https://github.com/kiali/kiali/issues/7814)
* [Graph - Patternfly topology for Kiali graph](https://github.com/kiali/openshift-servicemesh-plugin/issues/99)
* [Mesh Page - Improve istio canary handling](https://github.com/kiali/kiali/issues/7515)
* [Mesh Page - Ensure per-control-plane Istio settings](https://github.com/kiali/kiali/issues/7203)
* [Perf - Kiali Performance and Scalability testing](https://github.com/kiali/kiali/issues/7058)
* [UI - Upgrade Patternfly to version 5.4](https://github.com/kiali/kiali/issues/7674)

Fixes:

* [Kiali federation with multiple Kubernetes flavors not able to access none OpenShift workloads/applications when running on OCP](https://github.com/kiali/kiali/issues/7665)
* [K8s Gateways: Out of mesh error when not in 'istio-system'](https://github.com/kiali/kiali/issues/7720)
* [bearer token auth with external Grafana](https://github.com/kiali/kiali/issues/7717)
* [Config: grafana and tracing versions should be obtained over in_cluster_url](https://github.com/kiali/kiali/issues/7758)
* [Auth: Fix issue with bearer token auth with external Grafana](https://github.com/kiali/kiali/issues/7717)
* [Auth: Fix URL-choice issue when fetching Grafana and tracing versions](https://github.com/kiali/kiali/issues/7758)
* [Mesh page - controlplanes not mapped to their dataplanes when using stable revision labels](https://github.com/kiali/kiali/issues/7598)
* [Mesh page: Fix issue for controlplanes not mapped to their dataplanes, when using stable revision labels](https://github.com/kiali/kiali/issues/7598)
* [Mesh page: Memory consumption chart for istiod container isn't getting created](https://github.com/kiali/kiali/issues/7441)
* [Mesh page: istiod with no proxies synced yet throws error](https://github.com/kiali/kiali/issues/7829)
* [Multicluster: Fix issue federating Kiali instances on different Kubernetes' impls](https://github.com/kiali/kiali/issues/7665)
* [OSSMC: Toggle menu of the workload minigraph does not load the action list](https://github.com/kiali/openshift-servicemesh-plugin/issues/375)
* [Tempo: View in Tracing link](https://github.com/kiali/kiali/issues/7822)
* [UI: Toggle menu of the workload minigraph does not load the action list](https://github.com/kiali/openshift-servicemesh-plugin/issues/375)
* [UI: Broken Breadcrumb for Details pages](https://github.com/kiali/kiali/issues/7817)
* [Validations - Inconsistency between List and Details pages](https://github.com/kiali/kiali/issues/7685)

## 1.89.4
Release: Sep 30, 2024

Features:

The next feature release will be Kiali v 2.0.0

Fixes:

* [K8s Gateways: Fix "Out of mesh" error when not in 'istio-system'](https://github.com/kiali/kiali/issues/7720)
* [Operator: Fix support of namespaces that just have numbers in their name](https://github.com/kiali/kiali/issues/7773)
* [Validations - Fix “exportTo” validation inconsistency between List and Detail pages](https://github.com/kiali/kiali/issues/7685)

## 1.89.3
Release: Sep 09, 2024

Features:

The next feature release will be Kiali v 2.0.0

Fixes:

* [Custom Dashboard - External Links of Custom dashboard not visible](https://github.com/kiali/kiali/issues/7638)
* [Graph - Cannot load the graph: cluster (unknown) is not found or is not accessible for Kiali](https://github.com/kiali/kiali/issues/7672)
* [Graph - Inconsistent ServiceEntry Display in Multi-Namespace Environment](https://github.com/kiali/kiali/issues/7590)
* [Graph - Fix handling of defaultExportTo setting in serviceEntry and other components](https://github.com/kiali/kiali/issues/7589)
* [Tempo - query_scope is ignored for Tempo in single-cluster environment](https://github.com/kiali/kiali/issues/7658)

## 1.89.0
Release: Aug 19, 2024

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
Release: Jul 29, 2024

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
Release: Jul 08, 2024

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
Release: Jun 17, 2024

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
Release: May 27

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
Release: May 06, 2024

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
Release: Apr 12, 2024

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
Release: Mar 22, 2024

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
Release: Mar 01, 2024

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
Release: Feb 09, 2024

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
Release: Jan 19, 2024

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
Release: Dec 08, 2023

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
Release: Nov 17, 2023

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
Release: Oct 27, 2023

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
Release: Oct 06, 2023

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
Release: Sep 15, 2023

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

