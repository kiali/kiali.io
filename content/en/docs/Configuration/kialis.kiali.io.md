---
title: Kiali CR Reference
linkTitle: Kiali CR Reference
description: |
  Reference page for the Kiali CR.
  The Kiali Operator will watch for resources of this type and install Kiali according to those resources' configurations.
technical_name: kialis.kiali.io
source_repository: https://github.com/kiali/kiali-operator
source_repository_ref: master
---



<div class="crd-schema-version">


<h3 id="example-cr">Example CR</h3>
<em>(all values shown here are the defaults unless otherwise noted)</em>

```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  annotations:
    ansible.sdk.operatorframework.io/verbosity: "1"
spec:
  additional_display_details:
  - title: "API Documentation"
    annotation: "kiali.io/api-spec"
    icon_annotation: "kiali.io/api-type"

  installation_tag: ""

  istio_namespace: ""

  version: "default"

  api:
    namespaces:
      exclude:
      - "^istio-operator"
      - "^kube-.*"
      - "^openshift.*"
      - "^ibm.*"
      - "^kiali-operator"
      # default: label_selector is undefined
      label_selector: "kiali.io/member-of=istio-system"

  auth:
    strategy: ""
    openid:
      # default: additional_request_params is empty
      additional_request_params:
        openIdReqParam: "openIdReqParamValue"
      # default: allowed_domains is an empty list
      allowed_domains: ["allowed.domain"]
      api_proxy: ""
      api_proxy_ca_data: ""
      api_token: "id_token"
      authentication_timeout: 300
      authorization_endpoint: ""
      client_id: ""
      disable_rbac: false
      http_proxy: ""
      https_proxy: ""
      insecure_skip_verify_tls: false
      issuer_uri: ""
      scopes: ["openid", "profile", "email"]
      username_claim: "sub"
    openshift:
      client_id_prefix: "kiali"

  # default: custom_dashboards is an empty list
  custom_dashboards:
  - name: "envoy"

  deployment:
    accessible_namespaces: ["^((?!(istio-operator|kube-.*|openshift.*|ibm.*|kiali-operator)).)*$"]
    # default: additional_service_yaml is empty
    additional_service_yaml:
      externalName: "kiali.example.com"
    affinity:
      # default: node is empty
      node:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: kubernetes.io/e2e-az-name
              operator: In
              values:
              - e2e-az1
              - e2e-az2
      # default: pod is empty
      pod:
        requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector:
            matchExpressions:
            - key: security
              operator: In
              values:
              - S1
          topologyKey: topology.kubernetes.io/zone
      # default: pod_anti is empty
      pod_anti:
        preferredDuringSchedulingIgnoredDuringExecution:
        - weight: 100
          podAffinityTerm:
            labelSelector:
              matchExpressions:
              - key: security
                operator: In
                values:
                - S2
            topologyKey: topology.kubernetes.io/zone
    # default: configmap_annotations is empty
    configmap_annotations:
      strategy.spinnaker.io/versioned: "false"
    # default: custom_secrets is an empty list
    custom_secrets:
    - name: "a-custom-secret"
      mount: "/a-custom-secret-path"
      optional: true
    hpa:
      api_version: ""
      # default: spec is empty
      spec:
        maxReplicas: 2
        minReplicas: 1
        metrics:
        - type: Resource
          resource:
            name: cpu
            target:
              type: Utilization
              averageUtilization: 50
    # default: host_aliases is an empty list
    host_aliases:
    - ip: "192.168.1.100"
      hostnames:
      - "foo.local"
      - "bar.local"
    image_digest: ""
    image_name: ""
    image_pull_policy: "IfNotPresent"
    # default: image_pull_secrets is an empty list
    image_pull_secrets: ["image.pull.secret"]
    image_version: ""
    ingress:
      # default: additional_labels is empty
      additional_labels:
        ingressAdditionalLabel: "ingressAdditionalLabelValue"
      class_name: "nginx"
      # default: enabled is undefined
      enabled: false
      # default: override_yaml is undefined
      override_yaml:
        metadata:
          annotations:
            nginx.ingress.kubernetes.io/secure-backends: "true"
            nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
        spec:
          rules:
          - http:
              paths:
              - path: "/kiali"
                pathType: Prefix
                backend:
                  service:
                    name: "kiali"
                    port: 
                      number: 20001
    instance_name: "kiali"
    logger:
      log_level: "info"
      log_format: "text"
      sampler_rate: "1"
      time_field_format: "2006-01-02T15:04:05Z07:00"
    namespace: "istio-system"
    # default: node_selector is empty
    node_selector:
      nodeSelector: "nodeSelectorValue"
    # default: pod_annotations is empty
    pod_annotations:
      podAnnotation: "podAnnotationValue"
    # default: pod_labels is empty
    pod_labels:
      sidecar.istio.io/inject: "true"
    priority_class_name: ""
    replicas: 1
    # default: resources is undefined
    resources:
      requests:
        cpu: "10m"
        memory: "64Mi"
      limits:
        memory: "1Gi"
    secret_name: "kiali"
    # default: service_annotations is empty
    service_annotations:
      svcAnnotation: "svcAnnotationValue"
    # default: service_type is undefined
    service_type: "NodePort"
    # default: tolerations is an empty list
    tolerations:
    - key: "example-key"
      operator: "Exists"
      effect: "NoSchedule"
    verbose_mode: "3"
    version_label: ""
    view_only_mode: false

  external_services:
    custom_dashboards:
      discovery_auto_threshold: 10
      discovery_enabled: "auto"
      enabled: true
      is_core: false
      namespace_label: "namespace"
      prometheus:
        auth:
          ca_file: ""
          insecure_skip_verify: false
          password: ""
          token: ""
          type: "none"
          use_kiali_token: false
          username: ""
        cache_duration: 10
        cache_enabled: true
        cache_expiration: 300
        # default: custom_headers is empty
        custom_headers:
          customHeader1: "customHeader1Value"
        health_check_url: ""
        is_core: true
        # default: query_scope is empty
        query_scope:
          mesh_id: "mesh-1"
          cluster: "cluster-east"
        thanos_proxy:
          enabled: false
          retention_period: "7d"
          scrape_interval: "30s"
        url: ""
    grafana:
      auth:
        ca_file: ""
        insecure_skip_verify: false
        password: ""
        token: ""
        type: "none"
        use_kiali_token: false
        username: ""
      dashboards:
      - name: "Istio Service Dashboard"
        variables:
          namespace: "var-namespace"
          service: "var-service"
      - name: "Istio Workload Dashboard"
        variables:
          namespace: "var-namespace"
          workload: "var-workload"
      - name: "Istio Mesh Dashboard"
      - name: "Istio Control Plane Dashboard"
      - name: "Istio Performance Dashboard"
      - name: "Istio Wasm Extension Dashboard"
      enabled: true
      health_check_url: ""
      # default: in_cluster_url is undefined
      in_cluster_url: ""
      is_core: false
      url: ""
    istio:
      component_status:
        components:
        - app_label: "istiod"
          is_core: true
          is_proxy: false
        - app_label: "istio-ingressgateway"
          is_core: true
          is_proxy: true
          # default: namespace is undefined
          namespace: istio-system
        - app_label: "istio-egressgateway"
          is_core: false
          is_proxy: true
          # default: namespace is undefined
          namespace: istio-system
        enabled: true
      config_map_name: "istio"
      envoy_admin_local_port: 15000
      # default: istio_canary_revision is undefined
      istio_canary_revision:
        current: "1-9-9"
        upgrade: "1-10-2"
      istio_identity_domain: "svc.cluster.local"
      istio_injection_annotation: "sidecar.istio.io/inject"
      istio_sidecar_annotation: "sidecar.istio.io/status"
      istio_sidecar_injector_config_map_name: "istio-sidecar-injector"
      istiod_deployment_name: "istiod"
      istiod_pod_monitoring_port: 15014
      root_namespace: ""
      url_service_version: ""
    prometheus:
      auth:
        ca_file: ""
        insecure_skip_verify: false
        password: ""
        token: ""
        type: "none"
        use_kiali_token: false
        username: ""
      cache_duration: 10
      cache_enabled: true
      cache_expiration: 300
      # default: custom_headers is empty
      custom_headers:
        customHeader1: "customHeader1Value"
      health_check_url: ""
      is_core: true
      # default: query_scope is empty
      query_scope:
        mesh_id: "mesh-1"
        cluster: "cluster-east"
      thanos_proxy:
        enabled: false
        retention_period: "7d"
        scrape_interval: "30s"
      url: ""
    tracing:
      auth:
        ca_file: ""
        insecure_skip_verify: false
        password: ""
        token: ""
        type: "none"
        use_kiali_token: false
        username: ""
      enabled: true
      in_cluster_url: ""
      is_core: false
      namespace_selector: true
      url: ""
      use_grpc: true
      whitelist_istio_system: ["jaeger-query", "istio-ingressgateway"]

  health_config:
    # default: rate is an empty list
    rate:
    - namespace: ".*"
      kind: ".*"
      name: ".*"
      tolerance:
      - protocol: "http"
        direction: ".*"
        code: "[1234]00"
        degraded: 5
        failure: 10

  identity:
    # default: cert_file is undefined
    cert_file: ""
    # default: private_key_file is undefined
    private_key_file: ""

  istio_labels:
    app_label_name: "app"
    injection_label_name: "istio-injection"
    injection_label_rev:  "istio.io/rev"
    version_label_name: "version"

  kiali_feature_flags:
    certificates_information_indicators:
      enabled: true
      secrets:
      - "cacerts"
      - "istio-ca-secret"
    clustering:
      enabled: true
    disabled_features: []
    istio_injection_action: true
    istio_upgrade_action: false
    ui_defaults:
      graph:
        find_options:
        - description: "Find: slow edges (> 1s)"
          expression: "rt > 1000"
        - description: "Find: unhealthy nodes"
          expression:  "! healthy"
        - description: "Find: unknown nodes"
          expression:  "name = unknown"
        hide_options:
        - description: "Hide: healthy nodes"
          expression: "healthy"
        - description: "Hide: unknown nodes"
          expression:  "name = unknown"
        traffic:
          grpc: "requests"
          http: "requests"
          tcp:  "sent"
      metrics_per_refresh: "1m"
      # default: metrics_inbound is undefined
      metrics_inbound:
        aggregations:
        - display_name: "Istio Network"
          label: "topology_istio_io_network"
        - display_name: "Istio Revision"
          label: "istio_io_rev"
      # default: metrics_outbound is undefined
      metrics_outbound:
        aggregations:
        - display_name: "Istio Network"
          label: "topology_istio_io_network"
        - display_name: "Istio Revision"
          label: "istio_io_rev"
      # default: namespaces is an empty list
      namespaces: ["istio-system"]
      refresh_interval: "60s"
    validations:
      ignore: ["KIA1201"]

  kubernetes_config:
    burst: 200
    cache_duration: 300
    cache_enabled: true
    cache_istio_types:
    - "AuthorizationPolicy"
    - "DestinationRule"
    - "EnvoyFilter"
    - "Gateway"
    - "PeerAuthentication"
    - "RequestAuthentication"
    - "ServiceEntry"
    - "Sidecar"
    - "VirtualService"
    - "WorkloadEntry"
    - "WorkloadGroup"
    cache_namespaces:
    - ".*"
    cache_token_namespace_duration: 10
    excluded_workloads:
    - "CronJob"
    - "DeploymentConfig"
    - "Job"
    - "ReplicationController"
    qps: 175

  login_token:
    expiration_seconds: 86400
    signing_key: ""

  server:
    address: ""
    audit_log: true
    cors_allow_all: false
    gzip_enabled: true
    observability:
      metrics:
        enabled: true
        port: 9090
      tracing:
        collector_url: "http://jaeger-collector.istio-system:14268/api/traces"
        enabled: false
    port: 20001
    web_fqdn: ""
    web_history_mode: ""
    web_port: ""
    web_root: ""
    web_schema: ""
```


### Validating your Kiali CR

A Kiali tool is available to allow you to check your own Kiali CR to ensure it is valid. Simply download [the validation script](https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/bin/validate-kiali-cr.sh) and run it, passing in the location of the Kiali CRD you wish to validate with (e.g. the latest version is found [here](https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/crd/kiali.io_kialis.yaml)) and the location of your Kiali CR. You must be connected to/logged into a cluster for this validation tool to work.

For example, to validate a Kiali CR named `kiali` in the namespace `istio-system` using the latest version of the Kiali CRD, run the following:
<pre>
bash &lt;(curl -sL https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/bin/validate-kiali-cr.sh) \
  -crd https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/crd/kiali.io_kialis.yaml \
  --kiali-cr-name kiali \
  -n istio-system
</pre>

For additional help in using this validation tool, pass it the `--help` option.

<h3 id="property-details">Properties</h3>


<div class="property depth-0">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec">.spec</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>This is the CRD for the resources called Kiali CRs. The Kiali Operator will watch for resources of this type and when it detects a Kiali CR has been added, deleted, or modified, it will install, uninstall, and update the associated Kiali Server installation. The settings here will configure the Kiali Server as well as the Kiali Operator. All of these settings will be stored in the Kiali ConfigMap. Do not modify the ConfigMap; it will be managed by the Kiali Operator. Only modify the Kiali CR when you want to change a configuration setting.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.additional_display_details">.spec.additional_display_details</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of additional details that Kiali will look for in annotations. When found on any workload or service, Kiali will display the additional details in the respective workload or service details page. This is typically used to inject some CI metadata or documentation links into Kiali views. For example, by default, Kiali will recognize these annotations on a service or workload (e.g. a Deployment, StatefulSet, etc.):</p>

<pre><code>annotations:
  kiali.io/api-spec: http://list/to/my/api/doc
  kiali.io/api-type: rest
</code></pre>

<p>Note that if you change this setting for your own custom annotations, keep in mind that it would override the current default. So you would have to add the default setting as shown in the example CR if you want to preserve the default links.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.additional_display_details[*]">.spec.additional_display_details[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.additional_display_details[*].annotation">.spec.additional_display_details[*].annotation</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

<div class="property-description">
<p>The name of the annotation whose value is a URL to additional documentation useful to the user.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.additional_display_details[*].icon_annotation">.spec.additional_display_details[*].icon_annotation</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the annotation whose value is used to determine what icon to display. The annotation name itself can be anything, but note that the value of that annotation must be one of: <code>rest</code>, <code>grpc</code>, and <code>graphql</code> - any other value is ignored.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.additional_display_details[*].title">.spec.additional_display_details[*].title</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

<div class="property-description">
<p>The title of the link that Kiali will display. The link will go to the URL specified in the value of the configured <code>annotation</code>.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.api">.spec.api</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.api.namespaces">.spec.api.namespaces</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings that control what namespaces are returned by Kiali.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.api.namespaces.exclude">.spec.api.namespaces.exclude</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of namespaces to be excluded from the list of namespaces provided by the Kiali API and Kiali UI. Regex is supported. This does not affect explicit namespace access.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.api.namespaces.exclude[*]">.spec.api.namespaces.exclude[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.api.namespaces.label_selector">.spec.api.namespaces.label_selector</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>A Kubernetes label selector (e.g. <code>myLabel=myValue</code>) which is used when fetching the list of
available namespaces. This does not affect explicit namespace access.</p>

<p>If <code>deployment.accessible_namespaces</code> does not have the special value of <code>'**'</code>
then the Kiali operator will add a new label to all accessible namespaces - that new
label will be this <code>label_selector</code>.</p>

<p>Note that if you do not set this <code>label_selector</code> setting but <code>deployment.accessible_namespaces</code>
does not have the special &ldquo;all namespaces&rdquo; entry of <code>'**'</code> then this <code>label_selector</code> will be set
to a default value of <code>kiali.io/[&lt;deployment.instance_name&gt;.]member-of=&lt;deployment.namespace&gt;</code>
where <code>[&lt;deployment.instance_name&gt;.]</code> is the instance name assigned to the Kiali installation
if it is not the default &lsquo;kiali&rsquo; (otherwise, this is omitted) and <code>&lt;deployment.namespace&gt;</code>
is the namespace where Kiali is to be installed.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth">.spec.auth</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid">.spec.auth.openid</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>To learn more about these settings and how to configure the OpenId authentication strategy, read the documentation at <a href="https://kiali.io/docs/configuration/authentication/openid/">https://kiali.io/docs/configuration/authentication/openid/</a></p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.additional_request_params">.spec.auth.openid.additional_request_params</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.allowed_domains">.spec.auth.openid.allowed_domains</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.allowed_domains[*]">.spec.auth.openid.allowed_domains[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.api_proxy">.spec.auth.openid.api_proxy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.api_proxy_ca_data">.spec.auth.openid.api_proxy_ca_data</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.api_token">.spec.auth.openid.api_token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.authentication_timeout">.spec.auth.openid.authentication_timeout</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.authorization_endpoint">.spec.auth.openid.authorization_endpoint</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.client_id">.spec.auth.openid.client_id</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.disable_rbac">.spec.auth.openid.disable_rbac</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.http_proxy">.spec.auth.openid.http_proxy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.https_proxy">.spec.auth.openid.https_proxy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.insecure_skip_verify_tls">.spec.auth.openid.insecure_skip_verify_tls</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.issuer_uri">.spec.auth.openid.issuer_uri</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.scopes">.spec.auth.openid.scopes</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.scopes[*]">.spec.auth.openid.scopes[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.username_claim">.spec.auth.openid.username_claim</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openshift">.spec.auth.openshift</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>To learn more about these settings and how to configure the OpenShift authentication strategy, read the documentation at <a href="https://kiali.io/docs/configuration/authentication/openshift/">https://kiali.io/docs/configuration/authentication/openshift/</a></p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openshift.client_id_prefix">.spec.auth.openshift.client_id_prefix</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The Route resource name and OAuthClient resource name will have this value as its prefix. This value normally should never change. The installer will ensure this value is set correctly.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.strategy">.spec.auth.strategy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Determines what authentication strategy to use when users log into Kiali.
Options are <code>anonymous</code>, <code>token</code>, <code>openshift</code>, <code>openid</code>, or <code>header</code>.</p>

<ul>
<li>Choose <code>anonymous</code> to allow full access to Kiali without requiring any credentials.</li>
<li>Choose <code>token</code> to allow access to Kiali using service account tokens, which controls
access based on RBAC roles assigned to the service account.</li>
<li>Choose <code>openshift</code> to use the OpenShift OAuth login which controls access based on
the individual&rsquo;s RBAC roles in OpenShift. Not valid for non-OpenShift environments.</li>
<li>Choose <code>openid</code> to enable OpenID Connect-based authentication. Your cluster is required to
be configured to accept the tokens issued by your IdP. There are additional required
configurations for this strategy. See below for the additional OpenID configuration section.</li>
<li>Choose <code>header</code> when Kiali is running behind a reverse proxy that will inject an
Authorization header and potentially impersonation headers.</li>
</ul>

<p>When empty, this value will default to <code>openshift</code> on OpenShift and <code>token</code> on other Kubernetes environments.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.custom_dashboards">.spec.custom_dashboards</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of user-defined custom monitoring dashboards that you can use to generate metrics charts
for your applications. The server has some built-in dashboards; if you define a custom dashboard here
with the same name as a built-in dashboard, your custom dashboard takes precedence and will overwrite
the built-in dashboard. You can disable one or more of the built-in dashboards by simply defining an
empty dashboard.</p>

<p>An example of an additional user-defined dashboard,</p>

<pre><code>- name: myapp
  title: My App Metrics
  items:
  - chart:
      name: &quot;Thread Count&quot;
      spans: 4
      metricName: &quot;thread-count&quot;
      dataType: &quot;raw&quot;
</code></pre>

<p>An example of disabling a built-in dashboard (in this case, disabling the Envoy dashboard),</p>

<pre><code>- name: envoy
</code></pre>

<p>To learn more about custom monitoring dashboards, see the documentation at <a href="https://kiali.io/docs/configuration/custom-dashboard/">https://kiali.io/docs/configuration/custom-dashboard/</a></p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.custom_dashboards[*]">.spec.custom_dashboards[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment">.spec.deployment</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.accessible_namespaces">.spec.deployment.accessible_namespaces</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of namespaces Kiali is to be given access to. These namespaces have service mesh components that are to be observed by Kiali. You can provide names using regex expressions matched against all namespaces the operator can see. The default makes all namespaces accessible except for some internal namespaces that typically should be ignored. NOTE! If this has an entry with the special value of <code>'**'</code> (two asterisks), that will denote you want Kiali to be given access to all namespaces via a single cluster role (if using this special value of <code>'**'</code>, you are required to have already granted the operator permissions to create cluster roles and cluster role bindings).</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.accessible_namespaces[*]">.spec.deployment.accessible_namespaces[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.additional_service_yaml">.spec.deployment.additional_service_yaml</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Additional custom yaml to add to the service definition. This is used mainly to customize the service type. For example, if the <code>deployment.service_type</code> is set to &lsquo;LoadBalancer&rsquo; and you want to set the loadBalancerIP, you can do so here with: <code>additional_service_yaml: { 'loadBalancerIP': '78.11.24.19' }</code>. Another example would be if the <code>deployment.service_type</code> is set to &lsquo;ExternalName&rsquo; you will need to configure the name via: <code>additional_service_yaml: { 'externalName': 'my.kiali.example.com' }</code>. A final example would be if external IPs need to be set: <code>additional_service_yaml: { 'externalIPs': ['80.11.12.10'] }</code></p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.affinity">.spec.deployment.affinity</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Affinity definitions that are to be used to define the nodes where the Kiali pod should be constrained. See the Kubernetes documentation on Assigning Pods to Nodes for the proper syntax for these three different affinity types.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.affinity.node">.spec.deployment.affinity.node</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.affinity.pod">.spec.deployment.affinity.pod</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.affinity.pod_anti">.spec.deployment.affinity.pod_anti</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.configmap_annotations">.spec.deployment.configmap_annotations</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Custom annotations to be created on the Kiali ConfigMap.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.custom_secrets">.spec.deployment.custom_secrets</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Defines additional secrets that are to be mounted in the Kiali pod.</p>

<p>These are useful to contain certs that are used by Kiali to securely connect to third party systems
(for example, see <code>external_services.tracing.auth.ca_file</code>).</p>

<p>These secrets must be created by an external mechanism. Kiali will not generate these secrets; it
is assumed these secrets are externally managed. You can define 0, 1, or more secrets.
An example configuration is,</p>

<pre><code>custom_secrets:
- name: mysecret
  mount: /mysecret-path
- name: my-other-secret
  mount: /my-other-secret-location
  optional: true
</code></pre>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.custom_secrets[*]">.spec.deployment.custom_secrets[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.custom_secrets[*].mount">.spec.deployment.custom_secrets[*].mount</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

<div class="property-description">
<p>The file path location where the secret content will be mounted. The custom secret cannot be mounted on a path that the operator will use to mount its secrets. Make sure you set your custom secret mount path to a unique, unused path. Paths such as <code>/kiali-configuration</code>, <code>/kiali-cert</code>, <code>/kiali-cabundle</code>, and <code>/kiali-secret</code> should not be used as mount paths for custom secrets because the operator may want to use one of those paths.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.custom_secrets[*].name">.spec.deployment.custom_secrets[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

<div class="property-description">
<p>The name of the secret that is to be mounted to the Kiali pod&rsquo;s file system. The name of the custom secret must not be the same name as one created by the operator. Names such as <code>kiali</code>, <code>kiali-cert-secret</code>, and <code>kiali-cabundle</code> should not be used as a custom secret name because the operator may want to create one with one of those names.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.custom_secrets[*].optional">.spec.deployment.custom_secrets[*].optional</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Indicates if the secret may or may not exist at the time the Kiali pod starts. This will default to &lsquo;false&rsquo; if not specified.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.host_aliases">.spec.deployment.host_aliases</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>This is content for the Kubernetes &lsquo;hostAliases&rsquo; setting for the Kiali server.
This allows you to modify the Kiali server pod &lsquo;/etc/hosts&rsquo; file.
A typical way to configure this setting is,</p>

<pre><code>host_aliases:
- ip: 192.168.1.100
  hostnames:
  - &quot;foo.local&quot;
  - &quot;bar.local&quot;
</code></pre>

<p>For details on the content of this setting, see <a href="https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/#adding-additional-entries-with-hostaliases">https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/#adding-additional-entries-with-hostaliases</a></p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.host_aliases[*]">.spec.deployment.host_aliases[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.host_aliases[*].hostnames">.spec.deployment.host_aliases[*].hostnames</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.host_aliases[*].hostnames[*]">.spec.deployment.host_aliases[*].hostnames[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.host_aliases[*].ip">.spec.deployment.host_aliases[*].ip</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.hpa">.spec.deployment.hpa</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Determines what (if any) HorizontalPodAutoscaler should be created to autoscale the Kiali pod.
A typical way to configure HPA for Kiali is,</p>

<pre><code>hpa:
  api_version: &quot;autoscaling/v2&quot;
  spec:
    maxReplicas: 2
    minReplicas: 1
    metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
</code></pre>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.hpa.api_version">.spec.deployment.hpa.api_version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>A specific HPA API version that can be specified in case there is some HPA feature you want to use that is only supported in that specific version. If value is an empty string, an attempt will be made to determine a valid version.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.hpa.spec">.spec.deployment.hpa.spec</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>The <code>spec</code> specified here will be placed in the created HPA resource&rsquo;s &lsquo;spec&rsquo; section. If <code>spec</code> is left empty, no HPA resource will be created. Note that you must not specify the &lsquo;scaleTargetRef&rsquo; section in <code>spec</code>; the Kiali Operator will populate that for you.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.image_digest">.spec.deployment.image_digest</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>If <code>deployment.image_version</code> is a digest hash, this value indicates what type of digest it is. A typical value would be &lsquo;sha256&rsquo;. Note: do NOT prefix this value with a &lsquo;@&rsquo;.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.image_name">.spec.deployment.image_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Determines which Kiali image to download and install. If you set this to a specific name (i.e. you do not leave it as the default empty string), you must make sure that image is supported by the operator. If empty, the operator will use a known supported image name based on which <code>version</code> was defined. Note that, as a security measure, a cluster admin may have configured the Kiali operator to ignore this setting. A cluster admin may do this to ensure the Kiali operator only installs a single, specific Kiali version, thus this setting may have no effect depending on how the operator itself was configured.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.image_pull_policy">.spec.deployment.image_pull_policy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The Kubernetes pull policy for the Kiali deployment. This is overridden to be &lsquo;Always&rsquo; if <code>deployment.image_version</code> is set to &lsquo;latest&rsquo;.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.image_pull_secrets">.spec.deployment.image_pull_secrets</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>The names of the secrets to be used when container images are to be pulled.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.image_pull_secrets[*]">.spec.deployment.image_pull_secrets[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.image_version">.spec.deployment.image_version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Determines which version of Kiali to install.
Choose &lsquo;lastrelease&rsquo; to use the last Kiali release.
Choose &lsquo;latest&rsquo; to use the latest image (which may or may not be a released version of Kiali).
Choose &lsquo;operator_version&rsquo; to use the image whose version is the same as the operator version.
Otherwise, you can set this to any valid Kiali version (such as &lsquo;v1.0&rsquo;) or any valid Kiali
digest hash (if you set this to a digest hash, you must indicate the digest in <code>deployment.image_digest</code>).</p>

<p>Note that if this is set to &lsquo;latest&rsquo; then the <code>deployment.image_pull_policy</code> will be set to &lsquo;Always&rsquo;.</p>

<p>If you set this to a specific version (i.e. you do not leave it as the default empty string),
you must make sure that image is supported by the operator.</p>

<p>If empty, the operator will use a known supported image version based on which &lsquo;version&rsquo; was defined.
Note that, as a security measure, a cluster admin may have configured the Kiali operator to
ignore this setting. A cluster admin may do this to ensure the Kiali operator only installs
a single, specific Kiali version, thus this setting may have no effect depending on how the
operator itself was configured.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.ingress">.spec.deployment.ingress</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configures if/how the Kiali endpoint should be exposed externally.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.ingress.additional_labels">.spec.deployment.ingress.additional_labels</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Additional labels to add to the Ingress (or Route if on OpenShift). These are added to the labels that are created by default; these do not override the default labels.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.ingress.class_name">.spec.deployment.ingress.class_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>If <code>class_name</code> is a non-empty string, it will be used as the &lsquo;spec.ingressClassName&rsquo; in the created Kubernetes Ingress resource. This setting is ignored if on OpenShift. This is also ignored if <code>override_yaml.spec</code> is defined (i.e. you must define the &lsquo;ingressClassName&rsquo; directly in your override yaml).</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.ingress.enabled">.spec.deployment.ingress.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Determines if the Kiali endpoint should be exposed externally. If &lsquo;true&rsquo;, an Ingress will be created if on Kubernetes or a Route if on OpenShift. If left undefined, this will be &lsquo;false&rsquo; on Kubernetes and &lsquo;true&rsquo; on OpenShift.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.ingress.override_yaml">.spec.deployment.ingress.override_yaml</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Because an Ingress into a cluster can vary wildly in its desired configuration,
this setting provides a way to override complete portions of the Ingress resource
configuration (Ingress on Kubernetes and Route on OpenShift). It is up to the user
to ensure this override YAML configuration is valid and supports the cluster environment
since the operator will blindly copy this custom configuration into the resource it
creates.</p>

<p>This setting is not used if <code>deployment.ingress.enabled</code> is set to &lsquo;false&rsquo;.
Note that only &lsquo;metadata.annotations&rsquo; and &lsquo;spec&rsquo; is valid and only they will
be used to override those same sections in the created resource. You can define
either one or both.</p>

<p>Note that <code>override_yaml.metadata.labels</code> is not allowed - you cannot override the labels; to add
labels to the default set of labels, use the <code>deployment.ingress.additional_labels</code> setting.
Example,</p>

<pre><code>override_yaml:
  metadata:
    annotations:
      nginx.ingress.kubernetes.io/secure-backends: &quot;true&quot;
      nginx.ingress.kubernetes.io/backend-protocol: &quot;HTTPS&quot;
  spec:
    rules:
    - http:
        paths:
        - path: /kiali
          pathType: Prefix
          backend:
            service
              name: &quot;kiali&quot;
              port:
                number: 20001
</code></pre>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.ingress.override_yaml.metadata">.spec.deployment.ingress.override_yaml.metadata</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.ingress.override_yaml.metadata.annotations">.spec.deployment.ingress.override_yaml.metadata.annotations</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.ingress.override_yaml.spec">.spec.deployment.ingress.override_yaml.spec</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.instance_name">.spec.deployment.instance_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The instance name of this Kiali installation. This instance name will be the prefix prepended to the names of all Kiali resources created by the operator and will be used to label those resources as belonging to this Kiali installation instance. You cannot change this instance name after a Kiali CR is created. If you attempt to change it, the operator will abort with an error. If you want to change it, you must first delete the original Kiali CR and create a new one. Note that this does not affect the name of the auto-generated signing key secret. If you do not supply a signing key, the operator will create one for you in a secret, but that secret will always be named &lsquo;kiali-signing-key&rsquo; and shared across all Kiali instances in the same deployment namespace. If you want a different signing key secret, you are free to create your own and tell the operator about it via <code>login_token.signing_key</code>. See the docs on that setting for more details. Note also that if you are setting this value, you may also want to change the <code>installation_tag</code> setting, but this is not required.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.logger">.spec.deployment.logger</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configures the logger that emits messages to the Kiali server pod logs.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.logger.log_format">.spec.deployment.logger.log_format</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Indicates if the logs should be written with one log message per line or using a JSON format. Must be one of: <code>text</code> or <code>json</code>.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.logger.log_level">.spec.deployment.logger.log_level</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The lowest priority of messages to log. Must be one of: <code>trace</code>, <code>debug</code>, <code>info</code>, <code>warn</code>, <code>error</code>, or <code>fatal</code>.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.logger.sampler_rate">.spec.deployment.logger.sampler_rate</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>With this setting every sampler_rate-th message will be logged. By default, every message is logged. As an example, setting this to <code>'2'</code> means every other message will be logged. The value of this setting is a string but must be parsable as an integer.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.logger.time_field_format">.spec.deployment.logger.time_field_format</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The log message timestamp format. This supports a golang time format (see <a href="https://golang.org/pkg/time/">https://golang.org/pkg/time/</a>)</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.namespace">.spec.deployment.namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The namespace into which Kiali is to be installed. If this is empty or not defined, the default will be the namespace where the Kiali CR is located.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.node_selector">.spec.deployment.node_selector</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>A set of node labels that dictate onto which node the Kiali pod will be deployed.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.pod_annotations">.spec.deployment.pod_annotations</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Custom annotations to be created on the Kiali pod.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.pod_labels">.spec.deployment.pod_labels</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Custom labels to be created on the Kiali pod.
An example use for this setting is to inject an Istio sidecar such as,</p>

<pre><code>sidecar.istio.io/inject: &quot;true&quot;
</code></pre>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.priority_class_name">.spec.deployment.priority_class_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The priorityClassName used to assign the priority of the Kiali pod.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.replicas">.spec.deployment.replicas</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The replica count for the Kiail deployment.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.resources">.spec.deployment.resources</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Defines compute resources that are to be given to the Kiali pod&rsquo;s container. The value is a dict as defined by Kubernetes. See the Kubernetes documentation (<a href="https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container">https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container</a>).
If you set this to an empty dict (<code>{}</code>) then no resources will be defined in the Deployment.
If you do not set this at all, the default is,</p>

<pre><code>requests:
  cpu: &quot;10m&quot;
  memory: &quot;64Mi&quot;
limits:
  memory: &quot;1Gi&quot;
</code></pre>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.secret_name">.spec.deployment.secret_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of a secret used by the Kiali. This secret is optionally used when configuring the OpenID authentication strategy. Consult the OpenID docs for more information at <a href="https://kiali.io/docs/configuration/authentication/openid/">https://kiali.io/docs/configuration/authentication/openid/</a></p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.service_annotations">.spec.deployment.service_annotations</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Custom annotations to be created on the Kiali Service resource.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.service_type">.spec.deployment.service_type</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The Kiali service type. Kubernetes determines what values are valid. Common values are &lsquo;NodePort&rsquo;, &lsquo;ClusterIP&rsquo;, and &lsquo;LoadBalancer&rsquo;.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.tolerations">.spec.deployment.tolerations</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of tolerations which declare which node taints Kiali can tolerate. See the Kubernetes documentation on Taints and Tolerations for more details.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.tolerations[*]">.spec.deployment.tolerations[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.verbose_mode">.spec.deployment.verbose_mode</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED! Determines which priority levels of log messages Kiali will output. Use <code>deployment.logger</code> settings instead.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.version_label">.spec.deployment.version_label</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Kiali resources will be assigned a &lsquo;version&rsquo; label when they are deployed.
This setting determines what value those &lsquo;version&rsquo; labels will have.
When empty, its default will be determined as follows,</p>

<ul>
<li>If <code>deployment.image_version</code> is &lsquo;latest&rsquo;, <code>version_label</code> will be fixed to &lsquo;master&rsquo;.</li>
<li>If <code>deployment.image_version</code> is &lsquo;lastrelease&rsquo;, <code>version_label</code> will be fixed to the last Kiali release version string.</li>
<li>If <code>deployment.image_version</code> is anything else, <code>version_label</code> will be that value, too.</li>
</ul>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.view_only_mode">.spec.deployment.view_only_mode</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, Kiali will be in &lsquo;view only&rsquo; mode, allowing the user to view and retrieve management and monitoring data for the service mesh, but not allow the user to modify the service mesh.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services">.spec.external_services</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>These external service configuration settings define how to connect to the external services
like Prometheus, Grafana, and Jaeger.</p>

<p>Regarding sensitive values in the external_services &lsquo;auth&rsquo; sections:
Some external services configured below support an &lsquo;auth&rsquo; sub-section in order to tell Kiali
how it should authenticate with the external services. Credentials used to authenticate Kiali
to those external services can be defined in the <code>auth.password</code> and <code>auth.token</code> values
within the <code>auth</code> sub-section. Because these are sensitive values, you may not want to declare
the actual credentials here in the Kiali CR. In this case, you may store the actual password
or token string in a Kubernetes secret. If you do, you need to set the <code>auth.password</code> or
<code>auth.token</code> to a value in the format <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code> where <code>&lt;secretName&gt;</code>
is the name of the secret object that Kiali can access, and <code>&lt;secretKey&gt;</code> is the name of the
key within the named secret that contains the actual password or token string. For example,
if Grafana requires a password, you can store that password in a secret named &lsquo;myGrafanaCredentials&rsquo;
in a key named &lsquo;myGrafanaPw&rsquo;. In this case, you would set <code>external_services.grafana.auth.password</code>
to <code>secret:myGrafanaCredentials:myGrafanaPw</code>.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards">.spec.external_services.custom_dashboards</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings for enabling and discovering custom dashboards.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.discovery_auto_threshold">.spec.external_services.custom_dashboards.discovery_auto_threshold</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Threshold of the number of pods, for a given Application or Workload, above which dashboards discovery will be skipped. This setting only takes effect when <code>discovery_enabled</code> is set to &lsquo;auto&rsquo;.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.discovery_enabled">.spec.external_services.custom_dashboards.discovery_enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Enable, disable or set &lsquo;auto&rsquo; mode to the dashboards discovery process. If set to &lsquo;true&rsquo;, Kiali will always try to discover dashboards based on metrics. Note that this can generate performance penalties while discovering dashboards for workloads having many pods (thus many metrics). When set to &lsquo;auto&rsquo;, Kiali will skip dashboards discovery for workloads with more than a configured threshold of pods (see <code>discovery_auto_threshold</code>). When discovery is disabled or auto/skipped, it is still possible to tie workloads with dashboards through annotations on pods (refer to the doc <a href="https://kiali.io/docs/configuration/custom-dashboard/#pod-annotations">https://kiali.io/docs/configuration/custom-dashboard/#pod-annotations</a>). Value must be one of: <code>true</code>, <code>false</code>, <code>auto</code>.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.enabled">.spec.external_services.custom_dashboards.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Enable or disable custom dashboards, including the dashboards discovery process.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.is_core">.spec.external_services.custom_dashboards.is_core</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Used in the Components health feature. When true, the unhealthy scenarios will be raised as errors. Otherwise, they will be raised as a warning.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.namespace_label">.spec.external_services.custom_dashboards.namespace_label</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The Prometheus label name used for identifying namespaces in metrics for custom dashboards. The default is <code>namespace</code> but you may want to use <code>kubernetes_namespace</code> depending on your Prometheus configuration.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus">.spec.external_services.custom_dashboards.prometheus</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>The Prometheus configuration defined here refers to the Prometheus instance that is dedicated to fetching metrics for custom dashboards. This means you can obtain these metrics for the custom dashboards from a Prometheus instance that is different from the one that Istio uses. If this section is omitted, the same Prometheus that is used to obtain the Istio metrics will also be used for retrieving custom dashboard metrics.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth">.spec.external_services.custom_dashboards.prometheus.auth</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings used to authenticate with the Prometheus instance.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth.ca_file">.spec.external_services.custom_dashboards.prometheus.auth.ca_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The certificate authority file to use when accessing Prometheus using https. An empty string means no extra certificate authority file is used.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth.insecure_skip_verify">.spec.external_services.custom_dashboards.prometheus.auth.insecure_skip_verify</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set true to skip verifying certificate validity when Kiali contacts Prometheus over https.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth.password">.spec.external_services.custom_dashboards.prometheus.auth.password</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Password to be used when making requests to Prometheus, for basic authentication. May refer to a secret.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth.token">.spec.external_services.custom_dashboards.prometheus.auth.token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Token / API key to access Prometheus, for token-based authentication. May refer to a secret.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth.type">.spec.external_services.custom_dashboards.prometheus.auth.type</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The type of authentication to use when contacting the server. Use <code>bearer</code> to send the token to the Prometheus server. Use <code>basic</code> to connect with username and password credentials. Use <code>none</code> to not use any authentication (this is the default).</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth.use_kiali_token">.spec.external_services.custom_dashboards.prometheus.auth.use_kiali_token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true and if <code>auth.type</code> is <code>bearer</code>, Kiali Service Account token will be used for the API calls to Prometheus (in this case, <code>auth.token</code> config is ignored).</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth.username">.spec.external_services.custom_dashboards.prometheus.auth.username</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Username to be used when making requests to Prometheus with <code>basic</code> authentication.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.cache_duration">.spec.external_services.custom_dashboards.prometheus.cache_duration</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Prometheus caching duration expressed in seconds.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.cache_enabled">.spec.external_services.custom_dashboards.prometheus.cache_enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Enable/disable Prometheus caching used for Health services.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.cache_expiration">.spec.external_services.custom_dashboards.prometheus.cache_expiration</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Prometheus caching expiration expressed in seconds.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.custom_headers">.spec.external_services.custom_dashboards.prometheus.custom_headers</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>A set of name/value settings that will be passed as headers when requests are sent to Prometheus.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.health_check_url">.spec.external_services.custom_dashboards.prometheus.health_check_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Used in the Components health feature. This is the url which Kiali will ping to determine whether the component is reachable or not. It defaults to <code>url</code> when not provided.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.is_core">.spec.external_services.custom_dashboards.prometheus.is_core</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Used in the Components health feature. When true, the unhealthy scenarios will be raised as errors. Otherwise, they will be raised as a warning.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.query_scope">.spec.external_services.custom_dashboards.prometheus.query_scope</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>A set of labelName/labelValue settings applied to every Prometheus query. Used to narrow unified metrics to only those scoped to the Kiali instance.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.thanos_proxy">.spec.external_services.custom_dashboards.prometheus.thanos_proxy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Define this section if Prometheus is to be queried through a Thanos proxy. Kiali will still use the <code>url</code> setting to query for Prometheus metrics so make sure that is set appropriately.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.thanos_proxy.enabled">.spec.external_services.custom_dashboards.prometheus.thanos_proxy.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set to true when a Thanos proxy is in front of Prometheus.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.thanos_proxy.retention_period">.spec.external_services.custom_dashboards.prometheus.thanos_proxy.retention_period</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Thanos Retention period value expresed as a string.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.thanos_proxy.scrape_interval">.spec.external_services.custom_dashboards.prometheus.thanos_proxy.scrape_interval</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Thanos Scrape interval value expresed as a string.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.url">.spec.external_services.custom_dashboards.prometheus.url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL used to query the Prometheus Server. This URL must be accessible from the Kiali pod. If empty, the default will assume Prometheus is in the Istio control plane namespace; e.g. <code>http://prometheus.&lt;istio_namespace&gt;:9090</code>.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana">.spec.external_services.grafana</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configuration used to access the Grafana dashboards.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.auth">.spec.external_services.grafana.auth</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings used to authenticate with the Grafana instance.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.auth.ca_file">.spec.external_services.grafana.auth.ca_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The certificate authority file to use when accessing Grafana using https. An empty string means no extra certificate authority file is used.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.auth.insecure_skip_verify">.spec.external_services.grafana.auth.insecure_skip_verify</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set true to skip verifying certificate validity when Kiali contacts Grafana over https.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.auth.password">.spec.external_services.grafana.auth.password</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Password to be used when making requests to Grafana, for basic authentication. May refer to a secret.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.auth.token">.spec.external_services.grafana.auth.token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Token / API key to access Grafana, for token-based authentication. May refer to a secret.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.auth.type">.spec.external_services.grafana.auth.type</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The type of authentication to use when contacting the server. Use <code>bearer</code> to send the token to the Grafana server. Use <code>basic</code> to connect with username and password credentials. Use <code>none</code> to not use any authentication (this is the default).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.auth.use_kiali_token">.spec.external_services.grafana.auth.use_kiali_token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true and if <code>auth.type</code> is <code>bearer</code>, Kiali Service Account token will be used for the API calls to Grafana (in this case, <code>auth.token</code> config is ignored).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.auth.username">.spec.external_services.grafana.auth.username</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Username to be used when making requests to Grafana with <code>basic</code> authentication.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.dashboards">.spec.external_services.grafana.dashboards</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of Grafana dashboards that Kiali can link to.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.dashboards[*]">.spec.external_services.grafana.dashboards[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.dashboards[*].name">.spec.external_services.grafana.dashboards[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the Grafana dashboard.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.dashboards[*].variables">.spec.external_services.grafana.dashboards[*].variables</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.dashboards[*].variables.app">.spec.external_services.grafana.dashboards[*].variables.app</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of a variable that holds the app name, if used in that dashboard (else it must be omitted).</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.dashboards[*].variables.namespace">.spec.external_services.grafana.dashboards[*].variables.namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of a variable that holds the namespace, if used in that dashboard (else it must be omitted).</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.dashboards[*].variables.service">.spec.external_services.grafana.dashboards[*].variables.service</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of a variable that holds the service name, if used in that dashboard (else it must be omitted).</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.dashboards[*].variables.workload">.spec.external_services.grafana.dashboards[*].variables.workload</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of a variable that holds the workload name, if used in that dashboard (else it must be omitted).</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.enabled">.spec.external_services.grafana.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, Grafana support will be enabled in Kiali.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.health_check_url">.spec.external_services.grafana.health_check_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Used in the Components health feature. This is the URL which Kiali will ping to determine whether the component is reachable or not. It defaults to <code>in_cluster_url</code> when not provided.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.in_cluster_url">.spec.external_services.grafana.in_cluster_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL used for in-cluster access. An example would be <code>http://grafana.istio-system:3000</code>. This URL can contain query parameters if needed, such as &lsquo;?orgId=1&rsquo;. If not defined, it will default to <code>http://grafana.&lt;istio_namespace&gt;:3000</code>.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.is_core">.spec.external_services.grafana.is_core</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Used in the Components health feature. When true, the unhealthy scenarios will be raised as errors. Otherwise, they will be raised as a warning.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.url">.spec.external_services.grafana.url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL that Kiali uses when integrating with Grafana. This URL must be accessible to clients external to the cluster in order for the integration to work properly. If empty, an attempt to auto-discover it is made. This URL can contain query parameters if needed, such as &lsquo;?orgId=1&rsquo;.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio">.spec.external_services.istio</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Istio configuration that Kiali needs to know about in order to observe the mesh.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.component_status">.spec.external_services.istio.component_status</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Istio components whose status will be monitored by Kiali.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.component_status.components">.spec.external_services.istio.component_status.components</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A specific Istio component whose status will be monitored by Kiali.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.component_status.components[*]">.spec.external_services.istio.component_status.components[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.component_status.components[*].app_label">.spec.external_services.istio.component_status.components[*].app_label</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Istio component pod app label.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.component_status.components[*].is_core">.spec.external_services.istio.component_status.components[*].is_core</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Whether the component is to be considered a core component for your deployment.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.component_status.components[*].is_proxy">.spec.external_services.istio.component_status.components[*].is_proxy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Whether the component is a native Envoy proxy.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.component_status.components[*].namespace">.spec.external_services.istio.component_status.components[*].namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The namespace where the component is installed. It defaults to the Istio control plane namespace (e.g. <code>istio_namespace</code>) setting. Note that the Istio documentation suggests you install the ingress and egress to different namespaces, so you most likely will want to explicitly set this namespace value for the ingress and egress components.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.component_status.enabled">.spec.external_services.istio.component_status.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Determines if Istio component statuses will be displayed in the Kiali masthead indicator.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.config_map_name">.spec.external_services.istio.config_map_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the istio control plane config map.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.envoy_admin_local_port">.spec.external_services.istio.envoy_admin_local_port</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The port which kiali will open to fetch envoy config data information.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istio_canary_revision">.spec.external_services.istio.istio_canary_revision</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>These values are used in Canary upgrade/downgrade functionality when <code>istio_upgrade_action</code> is true.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istio_canary_revision.current">.spec.external_services.istio.istio_canary_revision.current</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The currently installed Istio revision.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istio_canary_revision.upgrade">.spec.external_services.istio.istio_canary_revision.upgrade</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The installed Istio canary revision to upgrade to.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istio_identity_domain">.spec.external_services.istio.istio_identity_domain</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The annotation used by Istio to identify domains.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istio_injection_annotation">.spec.external_services.istio.istio_injection_annotation</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the field that annotates a workload to indicate a sidecar should be automatically injected by Istio. This is the name of a Kubernetes annotation. Note that some Istio implementations also support labels by the same name. In other words, if a workload has a Kubernetes label with this name, that may also trigger automatic sidecar injection.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istio_sidecar_annotation">.spec.external_services.istio.istio_sidecar_annotation</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The pod annotation used by Istio to identify the sidecar.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istio_sidecar_injector_config_map_name">.spec.external_services.istio.istio_sidecar_injector_config_map_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the istio-sidecar-injector config map.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istiod_deployment_name">.spec.external_services.istio.istiod_deployment_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the istiod deployment.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istiod_pod_monitoring_port">.spec.external_services.istio.istiod_pod_monitoring_port</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The monitoring port of the IstioD pod (not the Service).</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.root_namespace">.spec.external_services.istio.root_namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The namespace to treat as the administrative root namespace for Istio configuration.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.url_service_version">.spec.external_services.istio.url_service_version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The Istio service used to determine the Istio version. If empty, assumes the URL for the well-known Istio version endpoint.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus">.spec.external_services.prometheus</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>The Prometheus configuration defined here refers to the Prometheus instance that is used by Istio to store its telemetry.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.auth">.spec.external_services.prometheus.auth</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings used to authenticate with the Prometheus instance.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.auth.ca_file">.spec.external_services.prometheus.auth.ca_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The certificate authority file to use when accessing Prometheus using https. An empty string means no extra certificate authority file is used.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.auth.insecure_skip_verify">.spec.external_services.prometheus.auth.insecure_skip_verify</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set true to skip verifying certificate validity when Kiali contacts Prometheus over https.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.auth.password">.spec.external_services.prometheus.auth.password</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Password to be used when making requests to Prometheus, for basic authentication. May refer to a secret.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.auth.token">.spec.external_services.prometheus.auth.token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Token / API key to access Prometheus, for token-based authentication. May refer to a secret.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.auth.type">.spec.external_services.prometheus.auth.type</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The type of authentication to use when contacting the server. Use <code>bearer</code> to send the token to the Prometheus server. Use <code>basic</code> to connect with username and password credentials. Use <code>none</code> to not use any authentication (this is the default).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.auth.use_kiali_token">.spec.external_services.prometheus.auth.use_kiali_token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true and if <code>auth.type</code> is <code>bearer</code>, Kiali Service Account token will be used for the API calls to Prometheus (in this case, <code>auth.token</code> config is ignored).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.auth.username">.spec.external_services.prometheus.auth.username</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Username to be used when making requests to Prometheus with <code>basic</code> authentication.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.cache_duration">.spec.external_services.prometheus.cache_duration</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Prometheus caching duration expressed in seconds.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.cache_enabled">.spec.external_services.prometheus.cache_enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Enable/disable Prometheus caching used for Health services.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.cache_expiration">.spec.external_services.prometheus.cache_expiration</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Prometheus caching expiration expressed in seconds.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.custom_headers">.spec.external_services.prometheus.custom_headers</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>A set of name/value settings that will be passed as headers when requests are sent to Prometheus.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.health_check_url">.spec.external_services.prometheus.health_check_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Used in the Components health feature. This is the url which Kiali will ping to determine whether the component is reachable or not. It defaults to <code>url</code> when not provided.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.is_core">.spec.external_services.prometheus.is_core</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Used in the Components health feature. When true, the unhealthy scenarios will be raised as errors. Otherwise, they will be raised as a warning.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.query_scope">.spec.external_services.prometheus.query_scope</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>A set of labelName/labelValue settings applied to every Prometheus query. Used to narrow unified metrics to only those scoped to the Kiali instance.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.thanos_proxy">.spec.external_services.prometheus.thanos_proxy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Define this section if Prometheus is to be queried through a Thanos proxy. Kiali will still use the <code>url</code> setting to query for Prometheus metrics so make sure that is set appropriately.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.thanos_proxy.enabled">.spec.external_services.prometheus.thanos_proxy.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set to true when a Thanos proxy is in front of Prometheus.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.thanos_proxy.retention_period">.spec.external_services.prometheus.thanos_proxy.retention_period</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Thanos Retention period value expresed as a string.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.thanos_proxy.scrape_interval">.spec.external_services.prometheus.thanos_proxy.scrape_interval</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Thanos Scrape interval value expresed as a string.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.url">.spec.external_services.prometheus.url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL used to query the Prometheus Server. This URL must be accessible from the Kiali pod. If empty, the default will assume Prometheus is in the Istio control plane namespace; e.g. <code>http://prometheus.&lt;istio_namespace&gt;:9090</code>.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing">.spec.external_services.tracing</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configuration used to access the Tracing (Jaeger) dashboards.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.auth">.spec.external_services.tracing.auth</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings used to authenticate with the Tracing server instance.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.auth.ca_file">.spec.external_services.tracing.auth.ca_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The certificate authority file to use when accessing the Tracing server using https. An empty string means no extra certificate authority file is used.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.auth.insecure_skip_verify">.spec.external_services.tracing.auth.insecure_skip_verify</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set true to skip verifying certificate validity when Kiali contacts the Tracing server over https.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.auth.password">.spec.external_services.tracing.auth.password</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Password to be used when making requests to the Tracing server, for basic authentication. May refer to a secret.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.auth.token">.spec.external_services.tracing.auth.token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Token / API key to access the Tracing server, for token-based authentication. May refer to a secret.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.auth.type">.spec.external_services.tracing.auth.type</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The type of authentication to use when contacting the server. Use <code>bearer</code> to send the token to the Tracing server. Use <code>basic</code> to connect with username and password credentials. Use <code>none</code> to not use any authentication (this is the default).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.auth.use_kiali_token">.spec.external_services.tracing.auth.use_kiali_token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true and if <code>auth.type</code> is <code>bearer</code>, Kiali Service Account token will be used for the API calls to the Tracing server (in this case, <code>auth.token</code> config is ignored).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.auth.username">.spec.external_services.tracing.auth.username</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Username to be used when making requests to the Tracing server with <code>basic</code> authentication.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.enabled">.spec.external_services.tracing.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, connections to the Tracing server are enabled. <code>in_cluster_url</code> and/or <code>url</code> need to be provided.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.in_cluster_url">.spec.external_services.tracing.in_cluster_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Set URL for in-cluster access, which enables further integration between Kiali and Jaeger. When not provided, Kiali will only show external links using the <code>url</code> setting. Note: Jaeger v1.20+ has separated ports for GRPC(16685) and HTTP(16686) requests. Make sure you use the appropriate port according to the <code>use_grpc</code> value. Example: <a href="http://tracing.istio-system:16685">http://tracing.istio-system:16685</a></p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.is_core">.spec.external_services.tracing.is_core</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Used in the Components health feature. When true, the unhealthy scenarios will be raised as errors. Otherwise, they will be raised as a warning.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.namespace_selector">.spec.external_services.tracing.namespace_selector</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Kiali use this boolean to find traces with a namespace selector : service.namespace.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.url">.spec.external_services.tracing.url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The external URL that will be used to generate links to Jaeger. It must be accessible to clients external to the cluster (e.g: a browser) in order to generate valid links. If the tracing service is deployed with a QUERY_BASE_PATH set, set this URL like https://<hostname>/<QUERY_BASE_PATH>. For example, <a href="https://tracing-service:8080/jaeger">https://tracing-service:8080/jaeger</a></p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.use_grpc">.spec.external_services.tracing.use_grpc</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set to true in order to enable GRPC connections between Kiali and Jaeger which will speed up the queries. In some setups you might not be able to use GRPC (e.g. if Jaeger is behind some reverse proxy that doesn&rsquo;t support it). If not specified, this will defalt to &lsquo;false&rsquo; if deployed within a Maistra/OSSM+OpenShift environment, &lsquo;true&rsquo; otherwise.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.whitelist_istio_system">.spec.external_services.tracing.whitelist_istio_system</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Kiali will get the traces of these services found in the Istio control plane namespace.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.whitelist_istio_system[*]">.spec.external_services.tracing.whitelist_istio_system[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>A name of a service found in the Istio control plane namespace whose traces will be retrieved by Kiali.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config">.spec.health_config</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>This section defines what it means for nodes to be healthy. For more details, see <a href="https://kiali.io/docs/configuration/health/">https://kiali.io/docs/configuration/health/</a></p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate">.spec.health_config.rate</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*]">.spec.health_config.rate[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].kind">.spec.health_config.rate[*].kind</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The type of resource that this configuration applies to. This is a regular expression.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].name">.spec.health_config.rate[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of a resource that this configuration applies to. This is a regular expression.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].namespace">.spec.health_config.rate[*].namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the namespace that this configuration applies to. This is a regular expression.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].tolerance">.spec.health_config.rate[*].tolerance</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of tolerances for this configuration.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].tolerance[*]">.spec.health_config.rate[*].tolerance[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].tolerance[*].code">.spec.health_config.rate[*].tolerance[*].code</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The status code that applies for this tolerance. This is a regular expression.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].tolerance[*].degraded">.spec.health_config.rate[*].tolerance[*].degraded</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Health will be considered degraded when the telemetry reaches this value (specified as an integer representing a percentage).</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].tolerance[*].direction">.spec.health_config.rate[*].tolerance[*].direction</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The direction that applies for this tolerance (e.g. inbound or outbound). This is a regular expression.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].tolerance[*].failure">.spec.health_config.rate[*].tolerance[*].failure</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>A failure status will be shown when the telemetry reaches this value (specified as an integer representing a percentage).</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.rate[*].tolerance[*].protocol">.spec.health_config.rate[*].tolerance[*].protocol</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The protocol that applies for this tolerance (e.g. grpc or http). This is a regular expression.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.identity">.spec.identity</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings that define the Kiali server identity.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.identity.cert_file">.spec.identity.cert_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Certificate file used to identify the Kiali server. If set, you must go over https to access Kiali. The Kiali operator will set this if it deploys Kiali behind https. When left undefined, the operator will attempt to generate a cluster-specific cert file that provides https by default (today, this auto-generation of a cluster-specific cert is only supported on OpenShift). When set to an empty string, https will be disabled.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.identity.private_key_file">.spec.identity.private_key_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Private key file used to identify the Kiali server. If set, you must go over https to access Kiali. When left undefined, the Kiali operator will attempt to generate a cluster-specific private key file that provides https by default (today, this auto-generation of a cluster-specific private key is only supported on OpenShift). When set to an empty string, https will be disabled.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.installation_tag">.spec.installation_tag</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Tag used to identify a particular instance/installation of the Kiali server. This is merely a human-readable string that will be used within Kiali to help a user identify the Kiali being used (e.g. in the Kiali UI title bar). See <code>deployment.instance_name</code> for the setting used to customize Kiali resource names that are created.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.istio_labels">.spec.istio_labels</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Defines specific labels used by Istio that Kiali needs to know about.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.istio_labels.app_label_name">.spec.istio_labels.app_label_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the label used to define what application a workload belongs to. This is typically something like <code>app</code> or <code>app.kubernetes.io/name</code>.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.istio_labels.injection_label_name">.spec.istio_labels.injection_label_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the label used to instruct Istio to automatically inject sidecar proxies when applications are deployed.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.istio_labels.injection_label_rev">.spec.istio_labels.injection_label_rev</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The label used to identify the Istio revision.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.istio_labels.version_label_name">.spec.istio_labels.version_label_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the label used to define what version of the application a workload belongs to. This is typically something like <code>version</code> or <code>app.kubernetes.io/version</code>.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.istio_namespace">.spec.istio_namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The namespace where Istio is installed. If left empty, it is assumed to be the same namespace as where Kiali is installed (i.e. <code>deployment.namespace</code>).</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags">.spec.kiali_feature_flags</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Kiali features that can be enabled or disabled.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.certificates_information_indicators">.spec.kiali_feature_flags.certificates_information_indicators</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Flag to enable/disable displaying certificates information and which secrets to grant read permissions.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.certificates_information_indicators.enabled">.spec.kiali_feature_flags.certificates_information_indicators.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.certificates_information_indicators.secrets">.spec.kiali_feature_flags.certificates_information_indicators.secrets</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.certificates_information_indicators.secrets[*]">.spec.kiali_feature_flags.certificates_information_indicators.secrets[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering">.spec.kiali_feature_flags.clustering</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Clustering and federation related features.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.enabled">.spec.kiali_feature_flags.clustering.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Flag to enable/disable clustering and federation related features.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.disabled_features">.spec.kiali_feature_flags.disabled_features</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>There may be some features that admins do not want to be accessible to users (even in &lsquo;view only&rsquo; mode). In this case, this setting allows you to disable one or more of those features entirely.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.disabled_features[*]">.spec.kiali_feature_flags.disabled_features[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.istio_injection_action">.spec.kiali_feature_flags.istio_injection_action</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Flag to enable/disable an Action to label a namespace for automatic Istio Sidecar injection.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.istio_upgrade_action">.spec.kiali_feature_flags.istio_upgrade_action</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Flag to activate the Kiali functionality of upgrading namespaces to point to an installed Istio Canary revision. Related Canary upgrade and current revisions of Istio should be defined in <code>istio_canary_revision</code> section.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults">.spec.kiali_feature_flags.ui_defaults</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Default settings for the UI. These defaults apply to all users.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph">.spec.kiali_feature_flags.ui_defaults.graph</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Default settings for the Graph UI.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.find_options">.spec.kiali_feature_flags.ui_defaults.graph.find_options</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of commonly used and useful find expressions that will be provided to the user out-of-box.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.find_options[*]">.spec.kiali_feature_flags.ui_defaults.graph.find_options[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.find_options[*].description">.spec.kiali_feature_flags.ui_defaults.graph.find_options[*].description</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Human-readable text to let the user know what the expression does.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.find_options[*].expression">.spec.kiali_feature_flags.ui_defaults.graph.find_options[*].expression</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The find expression.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.hide_options">.spec.kiali_feature_flags.ui_defaults.graph.hide_options</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of commonly used and useful hide expressions that will be provided to the user out-of-box.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.hide_options[*]">.spec.kiali_feature_flags.ui_defaults.graph.hide_options[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.hide_options[*].description">.spec.kiali_feature_flags.ui_defaults.graph.hide_options[*].description</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Human-readable text to let the user know what the expression does.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.hide_options[*].expression">.spec.kiali_feature_flags.ui_defaults.graph.hide_options[*].expression</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The hide expression.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.traffic">.spec.kiali_feature_flags.ui_defaults.graph.traffic</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>These settings determine which rates are used to determine graph traffic.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.traffic.grpc">.spec.kiali_feature_flags.ui_defaults.graph.traffic.grpc</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>gRPC traffic is measured in requests or sent/received/total messages. Value must be one of: <code>none</code>, <code>requests</code>, <code>sent</code>, <code>received</code>, or <code>total</code>.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.traffic.http">.spec.kiali_feature_flags.ui_defaults.graph.traffic.http</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>HTTP traffic is measured in requests. Value must be one of: <code>none</code> or <code>requests</code>.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.traffic.tcp">.spec.kiali_feature_flags.ui_defaults.graph.traffic.tcp</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>TCP traffic is measured in sent/received/total bytes. Only request traffic supplies response codes. Value must be one of: <code>none</code>, <code>sent</code>, <code>received</code>, or <code>total</code>.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_inbound">.spec.kiali_feature_flags.ui_defaults.metrics_inbound</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Additional label aggregation for inbound metric pages in detail pages.
You will see these configurations in the &lsquo;Metric Settings&rsquo; drop-down.
An example,</p>

<pre><code>metrics_inbound:
  aggregations:
  - display_name: Istio Network
    label: topology_istio_io_network
  - display_name: Istio Revision
    label: istio_io_rev
</code></pre>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations">.spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations[*]">.spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations[*].display_name">.spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations[*].display_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations[*].label">.spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations[*].label</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_outbound">.spec.kiali_feature_flags.ui_defaults.metrics_outbound</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Additional label aggregation for outbound metric pages in detail pages.
You will see these configurations in the &lsquo;Metric Settings&rsquo; drop-down.
An example,</p>

<pre><code>metrics_outbound:
  aggregations:
  - display_name: Istio Network
    label: topology_istio_io_network
  - display_name: Istio Revision
    label: istio_io_rev
</code></pre>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations">.spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations[*]">.spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations[*].display_name">.spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations[*].display_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations[*].label">.spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations[*].label</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_per_refresh">.spec.kiali_feature_flags.ui_defaults.metrics_per_refresh</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Duration of metrics to fetch on each refresh. Value must be one of: <code>1m</code>, <code>2m</code>, <code>5m</code>, <code>10m</code>, <code>30m</code>, <code>1h</code>, <code>3h</code>, <code>6h</code>, <code>12h</code>, <code>1d</code>, <code>7d</code>, or <code>30d</code></p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.namespaces">.spec.kiali_feature_flags.ui_defaults.namespaces</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Default selections for the namespace selection dropdown. Non-existent or inaccessible namespaces will be ignored. Omit or set to an empty array for no default namespaces.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.namespaces[*]">.spec.kiali_feature_flags.ui_defaults.namespaces[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.refresh_interval">.spec.kiali_feature_flags.ui_defaults.refresh_interval</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The automatic refresh interval for pages offering automatic refresh. Value must be one of: <code>pause</code>, <code>10s</code>, <code>15s</code>, <code>30s</code>, <code>1m</code>, <code>5m</code> or <code>15m</code></p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.validations">.spec.kiali_feature_flags.validations</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Features specific to the validations subsystem.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.validations.ignore">.spec.kiali_feature_flags.validations.ignore</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of one or more validation codes whose errors are to be ignored.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.validations.ignore[*]">.spec.kiali_feature_flags.validations.ignore[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>A validation code (e.g. <code>KIA0101</code>) for a specific validation error that is to be ignored.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config">.spec.kubernetes_config</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configuration of Kiali&rsquo;s access of the Kubernetes API.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.burst">.spec.kubernetes_config.burst</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The Burst value of the Kubernetes client.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.cache_duration">.spec.kubernetes_config.cache_duration</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The ratio interval (expressed in seconds) used for the cache to perform a full refresh. Only used when <code>cache_enabled</code> is true.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.cache_enabled">.spec.kubernetes_config.cache_enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Flag to use a Kubernetes cache for watching changes and updating pods and controllers data asynchronously.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.cache_istio_types">.spec.kubernetes_config.cache_istio_types</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Kiali can cache VirtualService, DestinationRule, Gateway and ServiceEntry Istio resources if they are present on this list of Istio types. Other Istio types are not yet supported.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.cache_istio_types[*]">.spec.kubernetes_config.cache_istio_types[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.cache_namespaces">.spec.kubernetes_config.cache_namespaces</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>List of namespaces or regex defining namespaces to include in a cache.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.cache_namespaces[*]">.spec.kubernetes_config.cache_namespaces[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.cache_token_namespace_duration">.spec.kubernetes_config.cache_token_namespace_duration</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>This Kiali cache is a list of namespaces per user. This is typically a short-lived cache compared with the duration of the namespace cache defined by the <code>cache_duration</code> setting. This is specified in seconds.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.excluded_workloads">.spec.kubernetes_config.excluded_workloads</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>List of controllers that won&rsquo;t be used for Workload calculation. Kiali queries Deployment, ReplicaSet, ReplicationController, DeploymentConfig, StatefulSet, Job and CronJob controllers. Deployment and ReplicaSet will be always queried, but ReplicationController, DeploymentConfig, StatefulSet, Job and CronJobs can be skipped from Kiali workloads queries if they are present in this list.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.excluded_workloads[*]">.spec.kubernetes_config.excluded_workloads[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kubernetes_config.qps">.spec.kubernetes_config.qps</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The QPS value of the Kubernetes client.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.login_token">.spec.login_token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.login_token.expiration_seconds">.spec.login_token.expiration_seconds</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>A user&rsquo;s login token expiration specified in seconds. This is applicable to token and header auth strategies only.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.login_token.signing_key">.spec.login_token.signing_key</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The signing key used to generate tokens for user authentication. Because this is potentially sensitive, you have the option to store this value in a secret. If you store this signing key value in a secret, you must indicate what key in what secret by setting this value to a string in the form of <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. If left as an empty string, a secret with a random signing key will be generated for you. The signing key must be 16, 24 or 32 byte long.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server">.spec.server</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configuration that controls some core components within the Kiali Server.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.address">.spec.server.address</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Where the Kiali server is bound. The console and API server are accessible on this host.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.audit_log">.spec.server.audit_log</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, allows additional audit logging on write operations.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.cors_allow_all">.spec.server.cors_allow_all</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, allows the web console to send requests to other domains other than where the console came from. Typically used for development environments only.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.gzip_enabled">.spec.server.gzip_enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, Kiali serves http requests with gzip enabled (if the browser supports it) when the requests are over 1400 bytes.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability">.spec.server.observability</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings to enable observability into the Kiali server itself.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.metrics">.spec.server.observability.metrics</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings that control how Kiali itself emits its own metrics.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.metrics.enabled">.spec.server.observability.metrics.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, the metrics endpoint will be available for Prometheus to scrape.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.metrics.port">.spec.server.observability.metrics.port</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The port that the server will bind to in order to receive metric requests. This is the port Prometheus will need to scrape when collecting metrics from Kiali.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.tracing">.spec.server.observability.tracing</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings that control how the Kiali server itself emits its own tracing data.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.tracing.collector_url">.spec.server.observability.tracing.collector_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL used to determine where the Kiali server tracing data will be stored.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.tracing.enabled">.spec.server.observability.tracing.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, the Kiali server itself will product its own tracing data.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.port">.spec.server.port</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The port that the server will bind to in order to receive console and API requests.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.web_fqdn">.spec.server.web_fqdn</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Defines the public domain where Kiali is being served. This is the &lsquo;domain&rsquo; part of the URL (usually it&rsquo;s a fully-qualified domain name). For example, <code>kiali.example.org</code>. When empty, Kiali will try to guess this value from HTTP headers. On non-OpenShift clusters, you must populate this value if you want to enable cross-linking between Kiali instances in a multi-cluster setup.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.web_history_mode">.spec.server.web_history_mode</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Define the history mode of kiali UI. Value must be one of: <code>browser</code> or <code>hash</code>.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.web_port">.spec.server.web_port</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Defines the ingress port where the connections come from. This is usually necessary when the application responds through a proxy/ingress, and it does not forward the correct headers (when this happens, Kiali cannot guess the port). When empty, Kiali will try to guess this value from HTTP headers.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.web_root">.spec.server.web_root</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Defines the context root path for the Kiali console and API endpoints and readiness probes. When providing a context root path that is not <code>/</code>, do not add a trailing slash (i.e. use <code>/kiali</code> not <code>/kiali/</code>). When empty, this will default to <code>/</code> on OpenShift and <code>/kiali</code> on other Kubernetes environments.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.web_schema">.spec.server.web_schema</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Defines the public HTTP schema used to serve Kiali. Value must be one of: <code>http</code> or <code>https</code>. When empty, Kiali will try to guess this value from HTTP headers. On non-OpenShift clusters, you must populate this value if you want to enable cross-linking between Kiali instances in a multi-cluster setup.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.version">.spec.version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The version of the Ansible playbook to execute in order to install that version of Kiali.
It is rare you will want to set this - if you are thinking of setting this, know what you are doing first.
The only supported value today is <code>default</code>.</p>

<p>If not specified, a default version of Kiali will be installed which will be the most recent release of Kiali.
Refer to this file to see where these values are defined in the master branch,
<a href="https://github.com/kiali/kiali-operator/tree/master/playbooks/default-supported-images.yml">https://github.com/kiali/kiali-operator/tree/master/playbooks/default-supported-images.yml</a></p>

<p>This version setting affects the defaults of the deployment.image_name and
deployment.image_version settings. See the comments for those settings
below for additional details. But in short, this version setting will
dictate which version of the Kiali image will be deployed by default.
Note that if you explicitly set deployment.image_name and/or
deployment.image_version you are responsible for ensuring those settings
are compatible with this setting (i.e. the Kiali image must be compatible
with the rest of the configuration and resources the operator will install).</p>

</div>

</div>
</div>

<div class="property depth-0">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".status">.status</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>The processing status of this CR as reported by the Kiali operator.</p>

</div>

</div>
</div>





</div>



