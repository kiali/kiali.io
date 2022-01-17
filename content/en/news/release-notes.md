---
title: "Release Notes"
type: docs
weight: 1
---

For additional information check our [sprint demo videos](https://www.youtube.com/channel/UCcm2NzDN_UCZKk2yYmOpc5w) and [blogs](https://medium.com/kialiproject).

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

