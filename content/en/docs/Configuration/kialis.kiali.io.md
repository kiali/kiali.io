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

  version: "default"

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
      discovery_override:
        authorization_endpoint: ""
        jwks_uri: ""
        token_endpoint: ""
        userinfo_endpoint: ""
    openshift:
      #redirect_uris:
      #token_inactivity_timeout:
      #token_max_age:

  chat_ai:    
    default_provider: ""
    enabled: false
    providers: []
    store_config:
      enabled: true
      max_cache_memory_mb: 1024      
      reduce_threshold: 15
      reduce_with_ai: false
      
  clustering:
    autodetect_secrets:
      enabled: true
      label: "kiali.io/multiCluster=true"
    clusters: []
    ignore_home_cluster: false
    kiali_urls: []

  # default: custom_dashboards is an empty list
  custom_dashboards:
  - name: "envoy"

  deployment:
    additional_pod_containers_yaml: []
    additional_pod_init_containers_yaml: []
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
    cluster_wide_access: true
    # default: configmap_annotations is empty
    configmap_annotations:
      strategy.spinnaker.io/versioned: "false"
    # default: custom_envs is an empty list
    custom_envs:
    - name: "HTTP_PROXY"
      value: "http://my.proxy.com:1234"
    - name: "NO_PROXY"
      value: "hostname.example.com"
    # default: custom_secrets is an empty list
    custom_secrets:
    - name: "a-custom-secret"
      mount: "/a-custom-secret-path"
      optional: true
    - name: "a-csi-secret"
      mount: "/a-csi-secret-path"
      csi:
        driver: secrets-store.csi.k8s.io
        readOnly: true
        volumeAttributes:
          secretProviderClass: kiali-secretprovider
    # default: discovery_selectors is empty
    discovery_selectors:
      default:
      - matchLabels:
          region: north
      - matchExpressions:
        - key: organization
          operator: "In"
          values: ["engineering", "accounting"]
      - matchLabels:
          region: south
        matchExpressions:
        - key: app
          operator: "DoesNotExist"
        - key: domain
          operator: "NotIn"
          values: ["production"]
      overrides:
        myRemoteCluster:
        - matchLabels:
            region: world
        - matchExpressions:
          - key: organization
            operator: "NotIn"
            values: ["marketing"]
        - matchLabels:
            region: antarctica
          matchExpressions:
          - key: app
            operator: "DoesNotExist"
          - key: domain
            operator: "In"
            values: ["staging"]
    dns:
      # default: config is empty
      config:
        options:
        - name: ndots
          value: "1"
      # default: policy is empty
      policy: "ClusterFirst"
    extra_labels: {}
    # default: host_aliases is an empty list
    host_aliases:
    - ip: "192.168.1.100"
      hostnames:
      - "foo.local"
      - "bar.local"
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
    network_policy:
      enabled: true
    # default: node_selector is empty
    node_selector:
      nodeSelector: "nodeSelectorValue"
    # default: pod_annotations is empty
    pod_annotations:
      proxy.istio.io/config: '{ "holdApplicationUntilProxyStarts": true }'
    # default: pod_labels is empty
    pod_labels:
      sidecar.istio.io/inject: "true"
    priority_class_name: ""
    probes:
      liveness:
        initial_delay_seconds: 5
        period_seconds: 30
      readiness:
        initial_delay_seconds: 5
        period_seconds: 30
      startup:
        failure_threshold: 6
        initial_delay_seconds: 30
        period_seconds: 10
    remote_cluster_resources_only: false
    replicas: 1
    # default: resources is undefined
    resources:
      requests:
        cpu: "10m"
        memory: "64Mi"
      limits:
        memory: "1Gi"
    secret_name: "kiali"
    security_context: {}
    # default: service_annotations is empty
    service_annotations:
      svcAnnotation: "svcAnnotationValue"
    # default: service_type is undefined
    service_type: "NodePort"
    strategy: {}
    # default: tolerations is an empty list
    tolerations:
    - key: "example-key"
      operator: "Exists"
      effect: "NoSchedule"
    topology_spread_constraints: []
    version_label: ""
    view_only_mode: false

  # default: extensions is an empty list
  extensions:
  - enabled: true
    name: "skupper"

  external_services:
    custom_dashboards:
      discovery_auto_threshold: 10
      discovery_enabled: "auto"
      enabled: true
      is_core: false
      namespace_label: "namespace"
      prometheus:
        auth:
          insecure_skip_verify: false
          password: ""
          token: ""
          type: "none"
          use_kiali_token: false
          username: ""
        cache_duration: 7
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
        insecure_skip_verify: false
        password: ""
        token: ""
        type: "none"
        use_kiali_token: false
        username: ""
      dashboards:
      - name: "Istio Service Dashboard"
        variables:
          datasource: "var-datasource"
          namespace: "var-namespace"
          service: "var-service"
          version: "var-version"
      - name: "Istio Workload Dashboard"
        variables:
          datasource: "var-datasource"
          namespace: "var-namespace"
          workload: "var-workload"
          version: "var-version"
      - name: "Istio Mesh Dashboard"
      - name: "Istio Control Plane Dashboard"
      - name: "Istio Performance Dashboard"
      - name: "Istio Wasm Extension Dashboard"
      datasource_uid: ""
      enabled: true
      external_url: ""
      health_check_url: ""
      internal_url: "http://grafana.istio-system:3000"
      is_core: false
    istio:
      component_status:
        components: []
        enabled: true
      gateway_api_classes: []
      gateway_api_classes_label_selector: ""
      istio_api_enabled: true
      istio_identity_domain: "svc.cluster.local"
      istiod_polling_interval_seconds: 20
      validation_change_detection_enabled: true
      validation_reconcile_interval: "1m"
    perses:
      auth:
        insecure_skip_verify: false
        password: ""
        type: "none"
        use_kiali_token: false
        username: ""
      dashboards:
      - name: "Istio Service Dashboard"
        variables:
          datasource: "var-datasource"
          namespace: "var-namespace"
          service: "var-service"
          version: "var-version"
      - name: "Istio Workload Dashboard"
        variables:
          datasource: "var-datasource"
          namespace: "var-namespace"
          workload: "var-workload"
          version: "var-version"
      - name: "Istio Mesh Dashboard"
      - name: "Istio Control Plane Dashboard"
      - name: "Istio Performance Dashboard"
      - name: "Istio Wasm Extension Dashboard"
      enabled: false
      external_url: ""
      health_check_url: ""
      internal_url: ""
      is_core: false
      project: "istio"
      url_format: ""
    prometheus:
      auth:
        insecure_skip_verify: false
        password: ""
        token: ""
        type: "none"
        use_kiali_token: false
        username: ""
      cache_duration: 7
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
        insecure_skip_verify: false
        password: ""
        token: ""
        type: "none"
        use_kiali_token: false
        username: ""
      # default: custom_headers is empty
      custom_headers:
        customHeader1: "customHeader1Value"
      disable_version_check: false
      enabled: false
      external_url: ""
      grpc_port: 9095
      health_check_url: ""
      internal_url: ""
      is_core: false
      namespace_selector: true
      provider: "jaeger"
      # default: query_scope is empty
      query_scope:
        mesh_id: "mesh-1"
        cluster: "cluster-east"
      query_timeout: 5
      tempo_config:
        cache_capacity: 200
        cache_enabled: true
        datasource_uid: ""
        name: ""
        namespace: ""
        org_id: ""
        tenant: ""
        url_format: "grafana"
      use_grpc: true
      use_waypoint_name: false
      whitelist_istio_system: ["jaeger-query", "istio-ingressgateway"]

  health_config:
    compute:
      duration: "5m"
      refresh_interval: "3m"
      timeout: "10m"
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
    app_label_name: ""
    egress_gateway_label: "istio=egressgateway"
    ingress_gateway_label: "istio=ingressgateway"
    injection_label_name: "istio-injection"
    injection_label_rev: "istio.io/rev"
    version_label_name: ""

  kiali_feature_flags:
    authz:
      require_namespace_get: false
    clustering:
      enable_exec_provider: false
    # default: custom_workload_types is an empty list
    custom_workload_types:
    - group: "argoproj.io"
      version: "v1alpha1"
      kind: "Rollout"
    disabled_features: []
    istio_annotation_action: true
    istio_injection_action: true
    istio_upgrade_action: false
    ui_defaults:
      graph:
        find_options:
        - description: "Find: slow edges (> 1s)"
          expression: "rt > 1000"
        - description: "Find: unhealthy nodes"
          expression: "! healthy"
        - description: "Find: unknown nodes"
          expression: "name = unknown"
        hide_options:
        - description: "Hide: healthy nodes"
          expression: "healthy"
        - description: "Hide: unknown nodes"
          expression: "name = unknown"
        settings:
          animation: "point"
        traffic:
          ambient: "total"
          grpc: "requests"
          http: "requests"
          tcp: "sent"
      i18n:
        language: "en"
        show_selector: false
      list:
        include_health: true
        include_istio_resources: true
        include_validations: true
        show_include_toggles: false
      mesh:
        find_options:
        - description: "Find: unhealthy nodes"
          expression: "! healthy"
        hide_options:
        - description: "Hide: healthy nodes"
          expression: "healthy"
      # default: metrics_inbound is undefined
      metrics_inbound:
        aggregations:
        - display_name: "Istio Network"
          label: "topology_istio_io_network"
          single_selection: false
        - display_name: "Istio Revision"
          label: "istio_io_rev"
          single_selection: false
      # default: metrics_outbound is undefined
      metrics_outbound:
        aggregations:
        - display_name: "Istio Network"
          label: "topology_istio_io_network"
          single_selection: false
        - display_name: "Istio Revision"
          label: "istio_io_rev"
          single_selection: false
      metrics_per_refresh: "1m"
      # default: namespaces is an empty list
      namespaces: ["istio-system"]
      refresh_interval: "1m"
      tracing:
        limit: 100
    validations:
      ignore: ["KIA1301"]
      skip_wildcard_gateway_hosts: false

  kubernetes_config:
    burst: 200
    cache_duration: 300
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
    # default: node_port is undefined
    node_port: 32475
    observability:
      metrics:
        enabled: true
        health_status:
          enabled: false
          max_consecutive_na: 3
        port: 9090
      tracing:
        collector_type: "otel"
        collector_url: "jaeger-collector.istio-system:4318"
        enabled: false
        otel:
          ca_name: ""
          protocol: "http"
          skip_verify: false
          tls_enabled: false
        sampling_rate: 0.5
    port: 20001
    profiler:
      enabled: false
    require_auth: false
    web_fqdn: ""
    web_history_mode: "browser"
    web_port: ""
    web_root: ""
    web_schema: ""
    write_timeout: "60s"
```


### Validating your Kiali CR

The Kiali CR has a CRD Schema so it will be validated when you create or update it in your cluster.

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

<pre><code>spec:
  annotations:
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

<div class="property-description">
<p>DEPRECATED AFTER v1.73: These settings control how the Kiali API should be accessed.</p>

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
<p>DEPRECATED AFTER v1.73: Settings for the API namespaces feature.</p>

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
<p>DEPRECATED AFTER v1.73: A list of namespace names that will be excluded from Kiali API.</p>

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
<h3 class="property-path" id=".spec.api.namespaces.include">.spec.api.namespaces.include</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: A list of namespace names that will be included in Kiali API.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.api.namespaces.include[*]">.spec.api.namespaces.include[*]</h3>
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
<h3 class="property-path" id=".spec.api.namespaces.label_selector_exclude">.spec.api.namespaces.label_selector_exclude</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: A Kubernetes label selector expression that will be used to exclude namespaces.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.api.namespaces.label_selector_include">.spec.api.namespaces.label_selector_include</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: A Kubernetes label selector expression that will be used to include namespaces.</p>

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

<div class="property-description">
<p>DEPRECATED since v2.21: Use auth.openid.discovery_override.authorization_endpoint instead. The URL of the provider&rsquo;s authorization endpoint.</p>

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
<h3 class="property-path" id=".spec.auth.openid.discovery_override">.spec.auth.openid.discovery_override</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Optional configuration to override OpenID Connect auto-discovery. Use when the IdP restricts access to /.well-known/openid-configuration endpoint.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.discovery_override.authorization_endpoint">.spec.auth.openid.discovery_override.authorization_endpoint</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL of the provider&rsquo;s authorization endpoint.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.discovery_override.jwks_uri">.spec.auth.openid.discovery_override.jwks_uri</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL of the provider&rsquo;s JWK Set document.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.discovery_override.token_endpoint">.spec.auth.openid.discovery_override.token_endpoint</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL of the provider&rsquo;s token endpoint.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openid.discovery_override.userinfo_endpoint">.spec.auth.openid.discovery_override.userinfo_endpoint</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL of the provider&rsquo;s UserInfo endpoint.</p>

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
<h3 class="property-path" id=".spec.auth.openshift.auth_timeout">.spec.auth.openshift.auth_timeout</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The amount of time in seconds Kiali will wait for a response from the OpenShift API when requesting authentication information.</p>

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
<p>DEPRECATED AFTER v1.73: A prefix that will be applied to the OpenShift OAuth client identifier.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openshift.insecure_skip_verify_tls">.spec.auth.openshift.insecure_skip_verify_tls</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set true to skip verifying certificate validity when Kiali contacts OpenShift over https.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openshift.redirect_uris">.spec.auth.openshift.redirect_uris</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Custom redirect URIs for the OpenShift OAuth client. These URIs specify where users will be redirected after successful authentication. If not specified, Kiali will automatically generate appropriate redirect URIs based on the Kiali server&rsquo;s route. You normally do not have to set this unless you are creating remote cluster resources (see <code>deployment.remote_cluster_resources_only</code>) with <code>auth.strategy</code> set to <code>openshift</code>.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openshift.redirect_uris[*]">.spec.auth.openshift.redirect_uris[*]</h3>
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
<h3 class="property-path" id=".spec.auth.openshift.token_inactivity_timeout">.spec.auth.openshift.token_inactivity_timeout</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Sets the maximum time in seconds that can elapse between consecutive uses of an OAuth access token before it expires due to inactivity. This helps improve security by automatically expiring unused tokens. If set to 0, tokens will not expire due to inactivity. Note that OpenShift may enforce minimum values for this setting, and existing tokens are not affected by changes to this configuration.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.auth.openshift.token_max_age">.spec.auth.openshift.token_max_age</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Sets the absolute maximum lifetime in seconds for OAuth access tokens, regardless of activity. After this time period, tokens will expire and users must re-authenticate. If set to 0, tokens will not have an absolute expiration time and will only expire due to inactivity (if token_inactivity_timeout is configured).</p>

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
<h3 class="property-path" id=".spec.chat_ai">.spec.chat_ai</h3>
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
<h3 class="property-path" id=".spec.chat_ai.default_provider">.spec.chat_ai.default_provider</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The default provider to use for the ChatAI feature. This is the provider that will be used if no provider is specified in the request.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.enabled">.spec.chat_ai.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Enable or disable the ChatAI feature.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers">.spec.chat_ai.providers</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of providers that can be used for the ChatAI feature. This is the list of providers that will be available to the user to choose from.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*]">.spec.chat_ai.providers[*]</h3>
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
<h3 class="property-path" id=".spec.chat_ai.providers[*].config">.spec.chat_ai.providers[*].config</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The type of the config needed by the AI models provider. Available values are <code>default</code>, <code>gemini</code>, and <code>azure</code>. Default value is <code>default</code>.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].default_model">.spec.chat_ai.providers[*].default_model</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The default model of the provider.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].description">.spec.chat_ai.providers[*].description</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The description of the provider.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].enabled">.spec.chat_ai.providers[*].enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Enable or disable the provider.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].key">.spec.chat_ai.providers[*].key</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The key of the provider. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the token is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].models">.spec.chat_ai.providers[*].models</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of models that can be used for the ChatAI feature. This is the list of models that will be available to the user to choose from.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].models[*]">.spec.chat_ai.providers[*].models[*]</h3>
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
<h3 class="property-path" id=".spec.chat_ai.providers[*].models[*].description">.spec.chat_ai.providers[*].models[*].description</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The description of the model.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].models[*].enabled">.spec.chat_ai.providers[*].models[*].enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Enable or disable the model.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].models[*].endpoint">.spec.chat_ai.providers[*].models[*].endpoint</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The endpoint of the model.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].models[*].key">.spec.chat_ai.providers[*].models[*].key</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The key of the model. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the token is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].models[*].model">.spec.chat_ai.providers[*].models[*].model</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The model of the model.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].models[*].name">.spec.chat_ai.providers[*].models[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the model.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].name">.spec.chat_ai.providers[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the provider.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.providers[*].type">.spec.chat_ai.providers[*].type</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The type of the AI models provider. Available values are <code>openai</code>. Default value is <code>openai</code>.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.store_config">.spec.chat_ai.store_config</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configuration for the ChatAI store.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.store_config.enabled">.spec.chat_ai.store_config.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Enable or disable the ChatAI store.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.store_config.max_cache_memory_mb">.spec.chat_ai.store_config.max_cache_memory_mb</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The maximum cache memory for the ChatAI store.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.store_config.reduce_threshold">.spec.chat_ai.store_config.reduce_threshold</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The threshold for the ChatAI store reduction with AI. This is the number of messages in a conversation before the conversation is reduced.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.chat_ai.store_config.reduce_with_ai">.spec.chat_ai.store_config.reduce_with_ai</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Enable or disable the ChatAI store reduction with AI.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering">.spec.clustering</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Multi-cluster related features.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.autodetect_secrets">.spec.clustering.autodetect_secrets</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings to allow cluster secrets to be auto-detected. Secrets must exist in the Kiali deployment namespace.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.autodetect_secrets.enabled">.spec.clustering.autodetect_secrets.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>If true then remote cluster secrets will be autodetected during the installation of the Kiali Server Deployment. Any remote cluster secrets found in the Kiali deployment namespace will be mounted to the Kiali Server&rsquo;s file system. If false, you can still manually specify the remote cluster secret information in the &lsquo;clusters&rsquo; setting if you wish to utilize multicluster features.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.autodetect_secrets.label">.spec.clustering.autodetect_secrets.label</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name and value of a label that exists on all remote cluster secrets.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.clusters">.spec.clustering.clusters</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of clusters that the Kiali Server can access. You need to specify the remote clusters here if &lsquo;autodetect_secrets.enabled&rsquo; is false.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.clusters[*]">.spec.clustering.clusters[*]</h3>
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
<h3 class="property-path" id=".spec.clustering.clusters[*].name">.spec.clustering.clusters[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the cluster.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.clusters[*].secret_name">.spec.clustering.clusters[*].secret_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the secret that contains the credentials necessary to connect to the remote cluster. This secret must exist in the Kiali deployment namespace. If a secret name is not provided then it&rsquo;s assumed that the cluster is inaccessible.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.enable_exec_provider">.spec.clustering.enable_exec_provider</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Flag to enable exec provider for clustering authentication.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.ignore_home_cluster">.spec.clustering.ignore_home_cluster</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set to true for an external Kiali deployment, or if Kiali should not try to discover Istio on the home cluster. When set to <code>true</code>, it is required to set <code>kubernetes_config.cluster_name</code>.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.kiali_urls">.spec.clustering.kiali_urls</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A map between cluster name, instance name and namespace to a Kiali URL. Will be used showing the Mesh page&rsquo;s Kiali URLs. The Kiali service&rsquo;s &lsquo;kiali.io/external-url&rsquo; annotation will be overridden when this property is set.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.kiali_urls[*]">.spec.clustering.kiali_urls[*]</h3>
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
<h3 class="property-path" id=".spec.clustering.kiali_urls[*].cluster_name">.spec.clustering.kiali_urls[*].cluster_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the cluster.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.kiali_urls[*].instance_name">.spec.clustering.kiali_urls[*].instance_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The instance name of this Kiali installation. This should be the value used in <code>deployment.instance_name</code> for Kiali resource name.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.kiali_urls[*].namespace">.spec.clustering.kiali_urls[*].namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The namespace into which Kiali is installed.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.clustering.kiali_urls[*].url">.spec.clustering.kiali_urls[*].url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL of Kiali in the cluster.</p>

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

<pre><code>spec:
  custom_dashboards:
  - name: myapp
    title: My App Metrics
    items:
    - chart:
        name: &quot;Thread Count&quot;
        spans: 4
        metricName: &quot;thread-count&quot;
        dataType: &quot;raw&quot;
</code></pre>

<p>An example of disabling a built-in dashboard (in this case, disabling the Envoy dashboard),</p>

<pre><code>spec:
  custom_dashboards:
  - name: envoy
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
<p>DEPRECATED AFTER v1.73: A list of namespaces Kiali is allowed to access. This replaces discovery selectors.</p>

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
<h3 class="property-path" id=".spec.deployment.additional_pod_containers_yaml">.spec.deployment.additional_pod_containers_yaml</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Additional containers to add to the list of pod containers. Use this to add container(s) to the Kiali pod. SECURITY: By default, the operator will forcibly apply a restrictive security context to all containers (allowPrivilegeEscalation: false, privileged: false, readOnlyRootFilesystem: true, runAsNonRoot: true, capabilities dropped). However, if the operator&rsquo;s ALLOW_SECURITY_CONTEXT_OVERRIDE environment variable is set to &lsquo;true&rsquo;, containers can define their own security contexts which will be preserved. Secret-backed volumes are automatically forced to read-only regardless of the security context override setting. Use with care since containers may cause the Kiali container itself to operate incorrectly. It is up to the user who added the additional containers to ensure it works properly inside the Kiali pod; Kiali makes no guarantee additional containers will work.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.additional_pod_containers_yaml[*]">.spec.deployment.additional_pod_containers_yaml[*]</h3>
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
<h3 class="property-path" id=".spec.deployment.additional_pod_init_containers_yaml">.spec.deployment.additional_pod_init_containers_yaml</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Additional initContainers to add to the list of pod initContainers. Use this to add initContainer(s) to the Kiali pod. SECURITY: By default, the operator will forcibly apply a restrictive security context to all initContainers (allowPrivilegeEscalation: false, privileged: false, readOnlyRootFilesystem: true, runAsNonRoot: true, capabilities dropped). However, if the operator&rsquo;s ALLOW_SECURITY_CONTEXT_OVERRIDE environment variable is set to &lsquo;true&rsquo;, initContainers can define their own security contexts which will be preserved. Secret-backed volumes are automatically forced to read-only regardless of the security context override setting. Use with care since initContainers may cause the Kiali container itself to operate incorrectly. It is up to the user who added the additional initContainers to ensure it works properly inside the Kiali pod; Kiali makes no guarantee additional initContainers will work.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.additional_pod_init_containers_yaml[*]">.spec.deployment.additional_pod_init_containers_yaml[*]</h3>
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
<h3 class="property-path" id=".spec.deployment.cluster_wide_access">.spec.deployment.cluster_wide_access</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Determines if the Kiali server will be granted cluster-wide permissions to see all namespaces. When true, this provides more efficient caching within the Kiali server. It must be <code>true</code> if <code>deployment.discovery_selectors.default</code> is left unset. To limit the namespaces for which Kiali has permissions, set to <code>false</code> and define the desired selectors in <code>deployment.discovery_selectors.default</code>.</p>

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
<h3 class="property-path" id=".spec.deployment.custom_envs">.spec.deployment.custom_envs</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Defines additional environment variables to be set in the Kiali server pod. This is typically used for (but not limited to) setting proxy environment variables such as HTTP_PROXY, HTTPS_PROXY, and/or NO_PROXY.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.custom_envs[*]">.spec.deployment.custom_envs[*]</h3>
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
<h3 class="property-path" id=".spec.deployment.custom_envs[*].name">.spec.deployment.custom_envs[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

<div class="property-description">
<p>The name of the custom environment variable.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.custom_envs[*].value">.spec.deployment.custom_envs[*].value</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

<div class="property-description">
<p>The value of the custom environment variable.</p>

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

<p>These are useful to contain client certificates that are used by Kiali to authenticate to third party systems
using mTLS (for example, see <code>external_services.tracing.auth.cert_file</code> and <code>external_services.tracing.auth.key_file</code>).</p>

<p>These secrets must be created by an external mechanism. Kiali will not generate these secrets; it
is assumed these secrets are externally managed. You can define 0, 1, or more secrets.
An example configuration is,</p>

<pre><code>spec:
  deployment:
    custom_secrets:
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
<h3 class="property-path" id=".spec.deployment.custom_secrets[*].csi">.spec.deployment.custom_secrets[*].csi</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Defines CSI-specific settings that allows a secret from an external CSI secret store to be injected in the pod via a volume mount. For details, see <a href="https://secrets-store-csi-driver.sigs.k8s.io/">https://secrets-store-csi-driver.sigs.k8s.io/</a></p>

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
<p>The file path location where the secret content will be mounted. The custom secret cannot be mounted on a path that the operator will use to mount its secrets. Make sure you set your custom secret mount path to a unique, unused path. Paths such as <code>/kiali-configuration</code>, <code>/kiali-cert</code>, <code>/kiali-cabundle</code>, <code>/kiali-secret</code>, <code>/kiali-override-secrets</code>, and <code>/kiali-remote-cluster-secrets</code> should not be used as mount paths for custom secrets because the operator may want to use one of those paths.</p>

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
<p>Indicates if the secret may or may not exist at the time the Kiali pod starts. This is ignored if <code>csi</code> is specified - CSI secrets must exist when specified.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.discovery_selectors">.spec.deployment.discovery_selectors</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Discovery selectors used to determine which namespaces are accessible to Kiali and which namespaces are visible to Kiali users.
You can define discovery selectors to match namespaces on the local cluster as well as remote clusters.
The list of namespaces that a user can access is a subset of these namespaces, given that user&rsquo;s RBAC permissions.
These selectors will have similar semantics as defined by Istio ( <a href="https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#MeshConfig">https://istio.io/latest/docs/reference/config/istio.mesh.v1alpha1/#MeshConfig</a> )
and the syntax of the equality-based and set-based label selectors are documented by Kubernetes here
( <a href="https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#resources-that-support-set-based-requirements">https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#resources-that-support-set-based-requirements</a> )</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.discovery_selectors.default">.spec.deployment.discovery_selectors.default</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>These are label selectors for the Kiali local cluster and for all remote clusters that do not have overrides.
Namespaces that match these selectors are visible to Kiali users.
When <code>cluster_wide_access=false</code> these <code>default</code> selectors are used to restrict which namespaces Kiali will have access to.
If there are no default discovery selectors, then <code>cluster_wide_access</code> should be <code>true</code> in which case Kiali will have
permissions to access all namespaces.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.discovery_selectors.default[*]">.spec.deployment.discovery_selectors.default[*]</h3>
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
<h3 class="property-path" id=".spec.deployment.discovery_selectors.default[*].matchExpressions">.spec.deployment.discovery_selectors.default[*].matchExpressions</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.discovery_selectors.default[*].matchExpressions[*]">.spec.deployment.discovery_selectors.default[*].matchExpressions[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-7">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.discovery_selectors.default[*].matchExpressions[*].key">.spec.deployment.discovery_selectors.default[*].matchExpressions[*].key</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

</div>
</div>

<div class="property depth-7">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.discovery_selectors.default[*].matchExpressions[*].operator">.spec.deployment.discovery_selectors.default[*].matchExpressions[*].operator</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

</div>
</div>

<div class="property depth-7">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.discovery_selectors.default[*].matchExpressions[*].values">.spec.deployment.discovery_selectors.default[*].matchExpressions[*].values</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

</div>
</div>

<div class="property depth-8">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.discovery_selectors.default[*].matchExpressions[*].values[*]">.spec.deployment.discovery_selectors.default[*].matchExpressions[*].values[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.discovery_selectors.default[*].matchLabels">.spec.deployment.discovery_selectors.default[*].matchLabels</h3>
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
<h3 class="property-path" id=".spec.deployment.discovery_selectors.overrides">.spec.deployment.discovery_selectors.overrides</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>If a remote cluster has different namespaces than the local cluster, these overrides provide a way for you to match those remote namespaces. Kiali will make these remote namespaces visible to users. The name of the overrides section is the name of the remote cluster. Note that the <code>default</code> selectors are ignored when matching namespaces on a remote cluster if that remote cluster has overrides defined.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.dns">.spec.deployment.dns</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>The Kiali server pod&rsquo;s DNS configuration. Kubernetes supports different DNS policies and configurations.
For further details, consult the Kubernetes documentation - <a href="https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/">https://kubernetes.io/docs/concepts/services-networking/dns-pod-service/</a></p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.dns.config">.spec.deployment.dns.config</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>DNS configuration that is applied to the DNS policy. See the Kubernetes documentation for the different configuration settings that are supported.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.dns.policy">.spec.deployment.dns.policy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DNS policy. See the Kubernetes documentation for the different policies that are supported.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.extra_labels">.spec.deployment.extra_labels</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Extra name/value pairs to be added to the labels of all resources created by the operator.
These are added to the labels the operator creates by default. These will not overwrite
labels that the operator creates itself. For example, if you set &ldquo;app.kubernetes.io/name&rdquo;
as an extra label, it will be silently ignored because that is one of the labels the operator
creates on all resources.</p>

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

<pre><code>spec:
  deployment:
    host_aliases:
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

<pre><code>spec:
  deployment:
    hpa:
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

<pre><code>spec:
  deployment:
    ingress:
      override_yaml:
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
<h3 class="property-path" id=".spec.deployment.network_policy">.spec.deployment.network_policy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configures if the Kiali server pod should be protected by a NetworkPolicy resource that restricts both ingress and egress traffic.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.network_policy.enabled">.spec.deployment.network_policy.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>If true, a NetworkPolicy resource is created to restrict traffic to the Kiali server pod. The NetworkPolicy will allow ingress traffic only to the Kiali server API port and, if enabled, the metrics port.</p>

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
<p>Custom annotations to be created on the Kiali pod.
By default, the following annotation is applied:</p>

<pre><code>proxy.istio.io/config: '{ &quot;holdApplicationUntilProxyStarts&quot;: true }'
</code></pre>

<p>If you define your own pod_annotations, they will overwrite this default.
To retain the default behavior while adding your own annotations,
make sure to include this value alongside your custom annotations.</p>

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
<h3 class="property-path" id=".spec.deployment.probes">.spec.deployment.probes</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configures the liveness, readiness, and startup probes of the Kiali pod.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.probes.liveness">.spec.deployment.probes.liveness</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configures the liveness probe of the Kiali pod.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.probes.liveness.initial_delay_seconds">.spec.deployment.probes.liveness.initial_delay_seconds</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.probes.liveness.period_seconds">.spec.deployment.probes.liveness.period_seconds</h3>
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
<h3 class="property-path" id=".spec.deployment.probes.readiness">.spec.deployment.probes.readiness</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configures the readiness probe of the Kiali pod.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.probes.readiness.initial_delay_seconds">.spec.deployment.probes.readiness.initial_delay_seconds</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.probes.readiness.period_seconds">.spec.deployment.probes.readiness.period_seconds</h3>
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
<h3 class="property-path" id=".spec.deployment.probes.startup">.spec.deployment.probes.startup</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configures the startup probe of the Kiali pod.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.probes.startup.failure_threshold">.spec.deployment.probes.startup.failure_threshold</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.probes.startup.initial_delay_seconds">.spec.deployment.probes.startup.initial_delay_seconds</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.probes.startup.period_seconds">.spec.deployment.probes.startup.period_seconds</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.remote_cluster_resources_only">.spec.deployment.remote_cluster_resources_only</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When <code>true</code>, only those resources necessary for a remote Kiali Server to access this cluster are created (such as the service account and roles/bindings). There will be no Kiali Server deployment/pod created when this is <code>true</code>.</p>

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
<p>The replica count for the Kiail deployment. If <code>deployment.hpa</code> is specified, this setting is ignored.</p>

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

<pre><code>spec:
  deployment:
    resources:
      requests:
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
<h3 class="property-path" id=".spec.deployment.security_context">.spec.deployment.security_context</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Custom security context to be placed on the server container. The entire security context on the container will be the value of this setting if the operator is configured to allow it. Note that, as a security measure, a cluster admin may have configured the Kiali operator to not allow portions of this override setting - in this case you can specify additional security context settings but you cannot replace existing, default ones.</p>

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
<h3 class="property-path" id=".spec.deployment.strategy">.spec.deployment.strategy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configures the update strategy for the Kiali deployment. If not specified, a RollingUpdate strategy is used with maxSurge=1 and maxUnavailable=1. See the Kubernetes documentation on Deployment Strategy for details.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.tls_config">.spec.deployment.tls_config</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>TLS policy configuration. When source is &lsquo;auto&rsquo; on OpenShift, the APIServer TLSSecurityProfile is used. Otherwise, the explicit config values are enforced.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.tls_config.cipher_suites">.spec.deployment.tls_config.cipher_suites</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Explicit TLS cipher suites (OpenSSL names). Ignored for TLS 1.3.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.tls_config.cipher_suites[*]">.spec.deployment.tls_config.cipher_suites[*]</h3>
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
<h3 class="property-path" id=".spec.deployment.tls_config.max_version">.spec.deployment.tls_config.max_version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Maximum TLS version (e.g., TLSv1.3, TLSv1.2).</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.tls_config.min_version">.spec.deployment.tls_config.min_version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Minimum TLS version (e.g., TLSv1.3, TLSv1.2).</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.tls_config.source">.spec.deployment.tls_config.source</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>TLS policy source: &lsquo;auto&rsquo; to use OpenShift TLSSecurityProfile; &lsquo;config&rsquo; to use explicit settings.</p>

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
<h3 class="property-path" id=".spec.deployment.topology_spread_constraints">.spec.deployment.topology_spread_constraints</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of constraints which control how the Kiali pods are spread across your cluster to help achieve high availability as well as efficient resource utilization. See the Kubernetes documentation on Topology Spread Constraints for more details.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.topology_spread_constraints[*]">.spec.deployment.topology_spread_constraints[*]</h3>
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
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: When true, Kiali will log additional debug information about its operations.</p>

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
<h3 class="property-path" id=".spec.extensions">.spec.extensions</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Defines third-party extensions whose metrics can be integrated into the Kiali traffic graph.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.extensions[*]">.spec.extensions[*]</h3>
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
<h3 class="property-path" id=".spec.extensions[*].enabled">.spec.extensions[*].enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Determines if the Kiali traffic graph should incorporate the extension&rsquo;s metrics.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.extensions[*].name">.spec.extensions[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name that is used to identify the metric time series for the extension.</p>

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
<p>Enable, disable or set &lsquo;auto&rsquo; mode to the dashboards discovery process. If set to &lsquo;true&rsquo;, Kiali will always try to discover dashboards based on metrics. Note that this can generate performance penalties while discovering dashboards for workloads having many pods (thus many metrics). When set to &lsquo;auto&rsquo;, Kiali will skip dashboards discovery for workloads with more than a configured threshold of pods (see <code>discovery_auto_threshold</code>). When discovery is disabled or auto/skipped, it is still possible to tie workloads with dashboards through annotations on pods (refer to the doc <a href="https://kiali.io/docs/configuration/custom-dashboard/#pod-annotations">https://kiali.io/docs/configuration/custom-dashboard/#pod-annotations</a>). Value must be a string and be one of: <code>true</code>, <code>false</code>, <code>auto</code>.</p>

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
<p>DEPRECATED since v2.20: This setting is deprecated and will be ignored. To configure custom CA certificates, use the kiali-cabundle ConfigMap instead. See the TLS Configuration documentation for details.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth.cert_file">.spec.external_services.custom_dashboards.prometheus.auth.cert_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client certificate file to use when accessing Prometheus using https with mTLS. An empty string means no client certificate is used. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the certificate is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<h3 class="property-path" id=".spec.external_services.custom_dashboards.prometheus.auth.key_file">.spec.external_services.custom_dashboards.prometheus.auth.key_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client private key file to use when accessing Prometheus using https with mTLS. An empty string means no client private key is used. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the key is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Password to be used when making requests to Prometheus, for basic authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the password is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Token / API key to access Prometheus, for token-based authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the token is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>The type of authentication to use when contacting the server. Use <code>bearer</code> to send the token to the Prometheus server. Use <code>basic</code> to connect with username and password credentials. Use <code>none</code> to not use any authentication.</p>

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
<p>Username to be used when making requests to Prometheus with <code>basic</code> authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the username is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Thanos Retention period value expressed as a string.</p>

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
<p>Thanos Scrape interval value expressed as a string.</p>

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
<p>The URL used to query the Prometheus Server. This URL must be accessible from the Kiali pod. If empty, the default will assume Prometheus is in the Istio control plane namespace; e.g. <code>http://prometheus.istio-system:9090</code>.</p>

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
<p>DEPRECATED since v2.20: This setting is deprecated and will be ignored. To configure custom CA certificates, use the kiali-cabundle ConfigMap instead. See the TLS Configuration documentation for details.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.auth.cert_file">.spec.external_services.grafana.auth.cert_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client certificate file to use when accessing Grafana using https with mTLS. An empty string means no client certificate is used. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the certificate is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<h3 class="property-path" id=".spec.external_services.grafana.auth.key_file">.spec.external_services.grafana.auth.key_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client private key file to use when accessing Grafana using https with mTLS. An empty string means no client private key is used. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the key is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Password to be used when making requests to Grafana, for basic authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the password is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Token / API key to access Grafana, for token-based authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the token is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>The type of authentication to use when contacting the server. Use <code>bearer</code> to send the token to the Grafana server. Use <code>basic</code> to connect with username and password credentials. Use <code>none</code> to not use any authentication.</p>

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
<p>Username to be used when making requests to Grafana with <code>basic</code> authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the username is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<h3 class="property-path" id=".spec.external_services.grafana.dashboards[*].variables.datasource">.spec.external_services.grafana.dashboards[*].variables.datasource</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the variable that holds the Datasource UID, required if Grafana has multiple datasources configured (else it must be omitted).</p>

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
<h3 class="property-path" id=".spec.external_services.grafana.dashboards[*].variables.version">.spec.external_services.grafana.dashboards[*].variables.version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of a variable that holds the version, if used in that dashboard (else it must be omitted).</p>

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
<h3 class="property-path" id=".spec.external_services.grafana.datasource_uid">.spec.external_services.grafana.datasource_uid</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The UID of the Datasource configured in Grafana must be specified if multiple datasources are configured. It is empty by default and is used only in conjunction with the <code>datasource</code> variable.</p>

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
<h3 class="property-path" id=".spec.external_services.grafana.external_url">.spec.external_services.grafana.external_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL that the Kiali UI uses when displaying Grafana links to the user. This URL must be accessible to clients external to the cluster (e.g. a browser) in order for the integration to work properly. If empty, an attempt to auto-discover it is made. This URL can contain query parameters if needed, such as &lsquo;?orgId=1&rsquo;.</p>

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
<p>Used in the Components health feature. This is the URL which Kiali will ping to determine whether the component is reachable or not. It defaults to <code>internal_url</code> when not provided.</p>

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
<p>DEPRECATED AFTER v1.73: The URL used for in-cluster access to Grafana.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.grafana.internal_url">.spec.external_services.grafana.internal_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL used by Kiali to perform requests and queries to Grafana. An example would be <code>http://grafana.istio-system:3000</code>. This URL can contain query parameters if needed, such as &lsquo;?orgId=1&rsquo;. If not defined, it will default to <code>http://grafana.&lt;istio namespace&gt;:3000</code>.</p>

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
<p>DEPRECATED AFTER v1.73: The URL used to access Grafana from external sources.</p>

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
<h3 class="property-path" id=".spec.external_services.istio.component_status.components[*].is_multicluster">.spec.external_services.istio.component_status.components[*].is_multicluster</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Whether the component is a multi-cluster component.</p>

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
<p>The namespace where the component is installed. It defaults to the Istio control plane namespace (e.g. <code>istio-system</code>). Note that the Istio documentation suggests you install the ingress and egress to different namespaces, so you most likely will want to explicitly set this namespace value for the ingress and egress components.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The name of the istio control plane config map is now autodetected based on revision.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.egress_gateway_namespace">.spec.external_services.istio.egress_gateway_namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The namespace where Istio EgressGateway component is read for a status check. When left empty, the control plane namespace is used. e.g. <code>istio-system</code>.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The port which Kiali will open to fetch envoy config data information is now hardcoded to the standard Envoy port.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.gateway_api_class_name">.spec.external_services.istio.gateway_api_class_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The name of the Gateway API Class used by Istio.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.gateway_api_classes">.spec.external_services.istio.gateway_api_classes</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list declaring all the Gateway API Classes used in Istio. If empty or undefined, Kiali attempts to auto-discover Gateway Classes if <code>cluster_wide_access</code> is set <code>true</code> for Kiali; otherwise, it defaults to <code>istio</code>, <code>istio-remote</code>, and adds <code>istio-waypoint</code> for Ambient mode or <code>istio-east-west</code> for multicluster setup.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.gateway_api_classes[*]">.spec.external_services.istio.gateway_api_classes[*]</h3>
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
<h3 class="property-path" id=".spec.external_services.istio.gateway_api_classes[*].class_name">.spec.external_services.istio.gateway_api_classes[*].class_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the GatewayClass.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.gateway_api_classes[*].name">.spec.external_services.istio.gateway_api_classes[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the Gateway API implementation.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.gateway_api_classes_label_selector">.spec.external_services.istio.gateway_api_classes_label_selector</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Label selector for auto-discovering K8s Gateway API Classes. Used if <code>gateway_api_classes</code> is unset and <code>cluster_wide_access</code> is set <code>true</code> for Kiali. When left empty then all K8s Gateway API Classes will be loaded.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istio_api_enabled">.spec.external_services.istio.istio_api_enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Indicates if Kiali has access to istiod.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. Canary upgrade/downgrade functionality now autodetects canary revisions from running istiod pods.</p>

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
<p>DEPRECATED AFTER v2.11: The currently installed Istio revision.</p>

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
<p>DEPRECATED AFTER v2.11: The installed Istio canary revision to upgrade to.</p>

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
<p>The Kubernetes cluster DNS domain suffix used to construct fully qualified service hostnames (e.g. reviews.bookinfo.svc.cluster.local) and service account identity strings for validation.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The name of the field that annotates a workload to indicate a sidecar should be automatically injected by Istio is now hardcoded to the standard value.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The pod annotation used by Istio to identify the sidecar is now hardcoded to the standard value.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The name of the istio-sidecar-injector config map is now autodetected based on revision.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The name of the istiod deployment is now autodetected.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The monitoring port of the IstioD pod is now autodetected from the deployment args.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.istiod_polling_interval_seconds">.spec.external_services.istio.istiod_polling_interval_seconds</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>How often in seconds Kiali will poll istiod(s) for proxy status. Polling is not performed if istio_api_enabled is false.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The namespace to treat as the administrative root namespace for Istio configuration.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The Istio service used to determine the Istio version is now autodetected from services.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.validation_change_detection_enabled">.spec.external_services.istio.validation_change_detection_enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, Kiali will detect changes in Istio configuration and trigger validation reconciliation.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.istio.validation_reconcile_interval">.spec.external_services.istio.validation_reconcile_interval</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Configures how often Kiali will validate Istio configuration. Validations cannot be disabled at the moment but you can set this to a long period of time. Accepts a golang duration string e.g. &lsquo;1h&rsquo; or &lsquo;30m&rsquo;.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses">.spec.external_services.perses</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configuration used to access the Perses dashboards.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.auth">.spec.external_services.perses.auth</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings used to authenticate with the Perses instance.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.auth.ca_file">.spec.external_services.perses.auth.ca_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED since v2.20: This setting is deprecated and will be ignored. To configure custom CA certificates, use the kiali-cabundle ConfigMap instead. See the TLS Configuration documentation for details.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.auth.cert_file">.spec.external_services.perses.auth.cert_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client certificate file to use when accessing Perses using https with mTLS. An empty string means no client certificate is used. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the certificate is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.auth.insecure_skip_verify">.spec.external_services.perses.auth.insecure_skip_verify</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set true to skip verifying certificate validity when Kiali contacts Perses over https.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.auth.key_file">.spec.external_services.perses.auth.key_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client private key file to use when accessing Perses using https with mTLS. An empty string means no client private key is used. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the key is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.auth.password">.spec.external_services.perses.auth.password</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Password to be used when making requests to Perses, for basic authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the password is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.auth.type">.spec.external_services.perses.auth.type</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The type of authentication to use when contacting the server. Use <code>bearer</code> to send the token to the Perses server. Use <code>basic</code> to connect with username and password credentials. Use <code>none</code> to not use any authentication.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.auth.use_kiali_token">.spec.external_services.perses.auth.use_kiali_token</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true and if <code>auth.type</code> is <code>bearer</code>, Kiali Service Account token will be used for the API calls to Perses.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.auth.username">.spec.external_services.perses.auth.username</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Username to be used when making requests to Perses with <code>basic</code> authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the username is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.dashboards">.spec.external_services.perses.dashboards</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>A list of Perses dashboards that Kiali can link to.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.dashboards[*]">.spec.external_services.perses.dashboards[*]</h3>
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
<h3 class="property-path" id=".spec.external_services.perses.dashboards[*].name">.spec.external_services.perses.dashboards[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the Perses dashboard.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.dashboards[*].variables">.spec.external_services.perses.dashboards[*].variables</h3>
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
<h3 class="property-path" id=".spec.external_services.perses.dashboards[*].variables.app">.spec.external_services.perses.dashboards[*].variables.app</h3>
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
<h3 class="property-path" id=".spec.external_services.perses.dashboards[*].variables.datasource">.spec.external_services.perses.dashboards[*].variables.datasource</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the variable that holds the Datasource UID, required if Perses has multiple datasources configured (else it must be omitted).</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.dashboards[*].variables.namespace">.spec.external_services.perses.dashboards[*].variables.namespace</h3>
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
<h3 class="property-path" id=".spec.external_services.perses.dashboards[*].variables.service">.spec.external_services.perses.dashboards[*].variables.service</h3>
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
<h3 class="property-path" id=".spec.external_services.perses.dashboards[*].variables.version">.spec.external_services.perses.dashboards[*].variables.version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of a variable that holds the version, if used in that dashboard (else it must be omitted).</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.dashboards[*].variables.workload">.spec.external_services.perses.dashboards[*].variables.workload</h3>
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
<h3 class="property-path" id=".spec.external_services.perses.enabled">.spec.external_services.perses.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, Perses support will be enabled in Kiali.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.external_url">.spec.external_services.perses.external_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL that the Kiali UI uses when displaying Perses links to the user. This URL must be accessible to clients external to the cluster (e.g. a browser) in order for the integration to work properly. If empty, an attempt to auto-discover it is made. This URL can contain query parameters if needed, such as &lsquo;?orgId=1&rsquo;.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.health_check_url">.spec.external_services.perses.health_check_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Used in the Components health feature. This is the URL which Kiali will ping to determine whether the component is reachable or not. It defaults to <code>internal_url</code> when not provided.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.internal_url">.spec.external_services.perses.internal_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL used by Kiali to perform requests and queries to Perses. An example would be <code>http://perses.istio-system:4000</code>. This URL can contain query parameters if needed, such as &lsquo;?orgId=1&rsquo;. If not defined, it will default to <code>http://perses.&lt;istio_namespace&gt;:4000</code>.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.is_core">.spec.external_services.perses.is_core</h3>
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
<h3 class="property-path" id=".spec.external_services.perses.project">.spec.external_services.perses.project</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the project where the Dashboards are defined.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.perses.url_format">.spec.external_services.perses.url_format</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL format. Leave empty (the default) for standard Perses upstream. Use <code>openshift</code> when using Perses Dashboards via the Cluster Observability operator in OpenShift.</p>

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
<p>DEPRECATED since v2.20: This setting is deprecated and will be ignored. To configure custom CA certificates, use the kiali-cabundle ConfigMap instead. See the TLS Configuration documentation for details.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.prometheus.auth.cert_file">.spec.external_services.prometheus.auth.cert_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client certificate file to use when accessing Prometheus using https with mTLS. An empty string means no client certificate is used. May refer to a secret.</p>

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
<h3 class="property-path" id=".spec.external_services.prometheus.auth.key_file">.spec.external_services.prometheus.auth.key_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client private key file to use when accessing Prometheus using https with mTLS. An empty string means no client private key is used. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the key is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Password to be used when making requests to Prometheus, for basic authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the password is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Token / API key to access Prometheus, for token-based authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the token is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Username to be used when making requests to Prometheus with <code>basic</code> authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the username is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Thanos Retention period value expressed as a string.</p>

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
<p>Thanos Scrape interval value expressed as a string.</p>

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
<p>The URL used to query the Prometheus Server. This URL must be accessible from the Kiali pod. If empty, the default will assume Prometheus is in the Istio control plane namespace; e.g. <code>http://prometheus.istio-system:9090</code>.</p>

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
<p>Configuration used to access the Tracing (Jaeger or Tempo) dashboards.</p>

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
<p>DEPRECATED since v2.20: This setting is deprecated and will be ignored. To configure custom CA certificates, use the kiali-cabundle ConfigMap instead. See the TLS Configuration documentation for details.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.auth.cert_file">.spec.external_services.tracing.auth.cert_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client certificate file to use when accessing the Tracing server using https with mTLS. An empty string means no client certificate is used. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the certificate is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<h3 class="property-path" id=".spec.external_services.tracing.auth.key_file">.spec.external_services.tracing.auth.key_file</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The client private key file to use when accessing the Tracing server using https with mTLS. An empty string means no client private key is used. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the key is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Password to be used when making requests to the Tracing server, for basic authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the password is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Token / API key to access the Tracing server, for token-based authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the token is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

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
<p>Username to be used when making requests to the Tracing server with <code>basic</code> authentication. May refer to a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the username is cached and automatically refreshed when the secret changes, enabling rotation without pod restart.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.custom_headers">.spec.external_services.tracing.custom_headers</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>A set of name/value settings that will be passed as headers when requests are sent to the Tracing backend.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.disable_version_check">.spec.external_services.tracing.disable_version_check</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, the version of the Tracing backend will not be retrieved. This will mean Kiali will not be able to display the version of your Tracing component in the Kiali UI. This may be needed in order to avoid Kiali reporting errors in cases where the full version endpoint is not accessible or is unknown. A common use case is when using Jaeger with gRPC and the HTTP endpoint is not deployed in the standard port (80).</p>

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
<p>When true, connections to the Tracing server are enabled. <code>internal_url</code> and/or <code>external_url</code> need to be provided.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.external_url">.spec.external_services.tracing.external_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL that the Kiali UI uses when displaying Tracing UI links to the user. This URL must be accessible to clients external to the cluster (e.g. a browser) in order to generate valid links. If the tracing service is deployed with a QUERY_BASE_PATH set, set this URL like https://<hostname>/<QUERY_BASE_PATH>; for example, <a href="https://tracing-service:8080/jaeger">https://tracing-service:8080/jaeger</a></p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.grpc_port">.spec.external_services.tracing.grpc_port</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Set port number when <code>use_grpc</code> is true and <code>provider</code> is <code>tempo</code>.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.health_check_url">.spec.external_services.tracing.health_check_url</h3>
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
<h3 class="property-path" id=".spec.external_services.tracing.in_cluster_url">.spec.external_services.tracing.in_cluster_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The URL used for in-cluster access to the tracing service.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.internal_url">.spec.external_services.tracing.internal_url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL used by Kiali to perform requests and queries to the tracing backend which enables further integration between Kiali and the tracing server. When not provided, Kiali will only show external links using the <code>external_url</code> setting. Note: Jaeger v1.20+ has separated ports for GRPC(16685) and HTTP(16686) requests. Make sure you use the appropriate port according to the <code>use_grpc</code> value. Example: <a href="http://tracing.istio-system:16685">http://tracing.istio-system:16685</a></p>

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
<h3 class="property-path" id=".spec.external_services.tracing.provider">.spec.external_services.tracing.provider</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The trace provider to get the traces from. Value must be one of: <code>jaeger</code> or <code>tempo</code>.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.query_scope">.spec.external_services.tracing.query_scope</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>A set of tagKey/tagValue settings applied to every Jaeger query. Used to narrow unified traces to only those scoped to the Kiali instance.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.query_timeout">.spec.external_services.tracing.query_timeout</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The amount of time in seconds Kiali will wait for a response from &lsquo;jaeger-query&rsquo; service when fetching traces.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.tempo_config">.spec.external_services.tracing.tempo_config</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings used to configure the access url to the Tempo Datasource in Grafana.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.tempo_config.cache_capacity">.spec.external_services.tracing.tempo_config.cache_capacity</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>When <code>cache_enabled</code> is true, the number of traces saved in the cache.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.tempo_config.cache_enabled">.spec.external_services.tracing.tempo_config.cache_enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>A FIFO cache with the last <code>cache_capacity</code> traces viewed.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.tempo_config.datasource_uid">.spec.external_services.tracing.tempo_config.datasource_uid</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The unique identifier (uid) of the Tempo datasource in Grafana.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.tempo_config.name">.spec.external_services.tracing.tempo_config.name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the Tempo instance for the <code>url_format</code> of <code>openshift</code> in the Plugin UI.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.tempo_config.namespace">.spec.external_services.tracing.tempo_config.namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The namespace of the Tempo instance for the <code>url_format</code> of <code>openshift</code> in the Plugin UI.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.tempo_config.org_id">.spec.external_services.tracing.tempo_config.org_id</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The Id of the organization that the dashboard is in. Default to 1 (the first and default organization).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.tempo_config.tenant">.spec.external_services.tracing.tempo_config.tenant</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the Tempo tenant for the <code>url_format</code> of <code>openshift</code> in the Plugin UI.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.tempo_config.url_format">.spec.external_services.tracing.tempo_config.url_format</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The URL format for the external url. Can be &lsquo;jaeger&rsquo;, &lsquo;grafana&rsquo; or &lsquo;openshift&rsquo;. Default to &lsquo;grafana&rsquo;. Openshift will need the name, namespace and tenant in the <code>tempo_config</code> settings.</p>

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
<p>DEPRECATED AFTER v1.73: The URL used to access the tracing service from external sources.</p>

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
<p>Set to true in order to enable GRPC connections between Kiali and Jaeger which will speed up the queries. In some setups you might not be able to use GRPC (e.g. if Jaeger is behind some reverse proxy that doesn&rsquo;t support it).</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.external_services.tracing.use_waypoint_name">.spec.external_services.tracing.use_waypoint_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Set to true in order to look for traces using the waypoint service name and not the actual service. Ex. To find traces for Istio versions earlier than 1.28.</p>

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
<h3 class="property-path" id=".spec.health_config.compute">.spec.health_config.compute</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Configuration for health pre-computation and caching.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.compute.duration">.spec.health_config.compute.duration</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The time period over which health is calculated. Used as the rate interval for Prometheus queries.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.compute.refresh_interval">.spec.health_config.compute.refresh_interval</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The interval between health cache refreshes.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.health_config.compute.timeout">.spec.health_config.compute.timeout</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The maximum time allowed for a single health refresh cycle. If exceeded, the refresh is cancelled and the next cycle starts on schedule.</p>

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
<p>If using a single scheme for app/version labeling, set this to the app label name being used. This is typically <code>app</code> or <code>app.kubernetes.io/name</code>. The default is unset, and Kiali will handle mixed schemes.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.istio_labels.egress_gateway_label">.spec.istio_labels.egress_gateway_label</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The selector label for Egress Gateway workload. This is typically <code>istio=egressgateway</code>.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.istio_labels.ingress_gateway_label">.spec.istio_labels.ingress_gateway_label</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The selector label for Ingress Gateway workload. This is typically <code>istio=ingressgateway</code>.</p>

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
<p>If using a single scheme for app/version labeling, set this to the version label name being used. This is typically <code>version</code> or <code>app.kubernetes.io/version</code>. The default is unset, and Kiali will handle mixed schemes.</p>

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
<p>DEPRECATED AFTER v2.11: This setting is deprecated and will be ignored. The namespace where Istio is installed is now autodetected. If left empty, it was previously assumed to be the same namespace as where Kiali is installed (i.e. <code>deployment.namespace</code>).</p>

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
<h3 class="property-path" id=".spec.kiali_feature_flags.authz">.spec.kiali_feature_flags.authz</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Authorization-related feature flags.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.authz.require_namespace_get">.spec.kiali_feature_flags.authz.require_namespace_get</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, a user must have GET permission on a namespace for it to be visible,
even if the user has LIST permission. When false (the default), a successful LIST
is trusted without per-namespace GET checks. Enable this in multi-tenant environments
where LIST permission is granted broadly but GET is restricted per namespace.</p>

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
<p>DEPRECATED AFTER v1.73: Settings for certificate information indicators.</p>

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

<div class="property-description">
<p>DEPRECATED AFTER v1.73: When true, certificate information indicators will be displayed.</p>

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

<div class="property-description">
<p>DEPRECATED AFTER v1.73: List of secrets that contain certificate information.</p>

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
<p>DEPRECATED AFTER v1.73: Multi-cluster related features.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.autodetect_secrets">.spec.kiali_feature_flags.clustering.autodetect_secrets</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: Settings to allow cluster secrets to be auto-detected.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.autodetect_secrets.enabled">.spec.kiali_feature_flags.clustering.autodetect_secrets.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: If true then remote cluster secrets will be autodetected.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.autodetect_secrets.label">.spec.kiali_feature_flags.clustering.autodetect_secrets.label</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The name and value of a label that exists on all remote cluster secrets.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.clusters">.spec.kiali_feature_flags.clustering.clusters</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: A list of clusters that the Kiali Server can access.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.clusters[*]">.spec.kiali_feature_flags.clustering.clusters[*]</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.clusters[*].name">.spec.kiali_feature_flags.clustering.clusters[*].name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The name of the cluster.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.clusters[*].secret_name">.spec.kiali_feature_flags.clustering.clusters[*].secret_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The name of the secret that contains the credentials necessary to connect to the remote cluster.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.enable_exec_provider">.spec.kiali_feature_flags.clustering.enable_exec_provider</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: Flag to enable exec provider for clustering authentication.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.kiali_urls">.spec.kiali_feature_flags.clustering.kiali_urls</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: A map between cluster name, instance name and namespace to a Kiali URL.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.kiali_urls[*]">.spec.kiali_feature_flags.clustering.kiali_urls[*]</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.kiali_urls[*].cluster_name">.spec.kiali_feature_flags.clustering.kiali_urls[*].cluster_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The name of the cluster.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.kiali_urls[*].instance_name">.spec.kiali_feature_flags.clustering.kiali_urls[*].instance_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The instance name of this Kiali installation.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.kiali_urls[*].namespace">.spec.kiali_feature_flags.clustering.kiali_urls[*].namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The namespace into which Kiali is installed.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.clustering.kiali_urls[*].url">.spec.kiali_feature_flags.clustering.kiali_urls[*].url</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED AFTER v1.73: The URL of Kiali in the cluster.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.custom_workload_types">.spec.kiali_feature_flags.custom_workload_types</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>Enable observability tabs (Traffic, Logs, Metrics, Traces) for custom workload types beyond the built-in Kubernetes controllers.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.custom_workload_types[*]">.spec.kiali_feature_flags.custom_workload_types[*]</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.custom_workload_types[*].group">.spec.kiali_feature_flags.custom_workload_types[*].group</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

<div class="property-description">
<p>The API group of the custom workload type (e.g., &lsquo;argoproj.io&rsquo;).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.custom_workload_types[*].kind">.spec.kiali_feature_flags.custom_workload_types[*].kind</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

<div class="property-description">
<p>The kind of the custom workload type (e.g., &lsquo;Rollout&rsquo;).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.custom_workload_types[*].version">.spec.kiali_feature_flags.custom_workload_types[*].version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>
<span class="property-required">*Required*</span>
</div>

<div class="property-description">
<p>The API version of the custom workload type (e.g., &lsquo;v1alpha1&rsquo;).</p>

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
<h3 class="property-path" id=".spec.kiali_feature_flags.istio_annotation_action">.spec.kiali_feature_flags.istio_annotation_action</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Flag to enable/disable an Action to edit annotations.</p>

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
<p>Flag to activate the Kiali functionality of upgrading namespaces to point to an installed Istio Canary revision.</p>

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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.find_options[*].auto_select">.spec.kiali_feature_flags.ui_defaults.graph.find_options[*].auto_select</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>If true this option will be selected and take effect automatically. Note that only one option in the list can have this value be set to true.</p>

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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.hide_options[*].auto_select">.spec.kiali_feature_flags.ui_defaults.graph.hide_options[*].auto_select</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>If true this option will be selected and take effect automatically. Note that only one option in the list can have this value be set to true.</p>

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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.settings">.spec.kiali_feature_flags.ui_defaults.graph.settings</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Various presentation options.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.settings.animation">.spec.kiali_feature_flags.ui_defaults.graph.settings.animation</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The traffic animation style. Value must be one of: <code>dash</code> or <code>point</code>.</p>

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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.graph.traffic.ambient">.spec.kiali_feature_flags.ui_defaults.graph.traffic.ambient</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Ambient traffic is reported by ztunnel and/or waypoints. Value must be one of: <code>none</code>, <code>total</code>, <code>waypoint</code>, or <code>ztunnel</code>.</p>

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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.i18n">.spec.kiali_feature_flags.ui_defaults.i18n</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Default settings for the i18n values.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.i18n.language">.spec.kiali_feature_flags.ui_defaults.i18n.language</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Default language used in Kiali application.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.i18n.show_selector">.spec.kiali_feature_flags.ui_defaults.i18n.show_selector</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>If true Kiali masthead displays language selector icon.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.list">.spec.kiali_feature_flags.ui_defaults.list</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Default settings for the List views (Apps, Workloads, etc).</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.list.include_health">.spec.kiali_feature_flags.ui_defaults.list.include_health</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Include Health column (by default) for applicable list views. Setting to false can improve performance.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.list.include_istio_resources">.spec.kiali_feature_flags.ui_defaults.list.include_istio_resources</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Include Istio resources (by default) in Details column for applicable list views. Setting to false can improve performance.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.list.include_validations">.spec.kiali_feature_flags.ui_defaults.list.include_validations</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Include Configuration validation column (by default) for applicable list views. Setting to false can improve performance.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.list.show_include_toggles">.spec.kiali_feature_flags.ui_defaults.list.show_include_toggles</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>If true list pages display checkbox toggles for the include options, Otherwise the configured settings are applied but can not be changed by the user.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh">.spec.kiali_feature_flags.ui_defaults.mesh</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Default settings for the Mesh UI.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.find_options">.spec.kiali_feature_flags.ui_defaults.mesh.find_options</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.find_options[*]">.spec.kiali_feature_flags.ui_defaults.mesh.find_options[*]</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.find_options[*].auto_select">.spec.kiali_feature_flags.ui_defaults.mesh.find_options[*].auto_select</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>If true this option will be selected and take effect automatically. Note that only one option in the list can have this value be set to true.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.find_options[*].description">.spec.kiali_feature_flags.ui_defaults.mesh.find_options[*].description</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.find_options[*].expression">.spec.kiali_feature_flags.ui_defaults.mesh.find_options[*].expression</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.hide_options">.spec.kiali_feature_flags.ui_defaults.mesh.hide_options</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.hide_options[*]">.spec.kiali_feature_flags.ui_defaults.mesh.hide_options[*]</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.hide_options[*].auto_select">.spec.kiali_feature_flags.ui_defaults.mesh.hide_options[*].auto_select</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>If true this option will be selected and take effect automatically. Note that only one option in the list can have this value be set to true.</p>

</div>

</div>
</div>

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.hide_options[*].description">.spec.kiali_feature_flags.ui_defaults.mesh.hide_options[*].description</h3>
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
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.mesh.hide_options[*].expression">.spec.kiali_feature_flags.ui_defaults.mesh.hide_options[*].expression</h3>
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

<pre><code>spec:
  kiali_feature_flags:
    ui_defaults:
      metrics_inbound:
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

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations[*].single_selection">.spec.kiali_feature_flags.ui_defaults.metrics_inbound.aggregations[*].single_selection</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Flag to indicate if only one option can be selected for this aggregation.</p>

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

<pre><code>spec:
  kiali_feature_flags:
    ui_defaults:
      metrics_outbound:
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

<div class="property depth-6">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations[*].single_selection">.spec.kiali_feature_flags.ui_defaults.metrics_outbound.aggregations[*].single_selection</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Flag to indicate if only one option can be selected for this aggregation.</p>

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
<p>The automatic refresh interval for pages offering automatic refresh. <code>Manual</code> requires user action even for initial page load. Value must be one of: <code>pause</code>, <code>manual</code>, <code>10s</code>, <code>15s</code>, <code>30s</code>, <code>1m</code>, <code>5m</code> or <code>15m</code></p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.tracing">.spec.kiali_feature_flags.ui_defaults.tracing</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Default settings for the Tracing UI.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.ui_defaults.tracing.limit">.spec.kiali_feature_flags.ui_defaults.tracing.limit</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The default limit for the number of traces that will be fetched. It can be customized in the UI. It must be a number between 10 and 1000.</p>

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

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_feature_flags.validations.skip_wildcard_gateway_hosts">.spec.kiali_feature_flags.validations.skip_wildcard_gateway_hosts</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>The KIA0301 validation checks duplicity of host and port combinations across all Istio Gateways. This includes also Gateways with &lsquo;*&rsquo; in hosts. But Istio considers such a Gateway with a wildcard in hosts as the last in order, after the Gateways with FQDN in hosts. This option is to skip Gateways with wildcards in hosts from the KIA0301 validations but still keep Gateways with FQDN hosts.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali_internal">.spec.kiali_internal</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Unstructured section for internal testing and debugging features.</p>

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
<h3 class="property-path" id=".spec.kubernetes_config.cluster_name">.spec.kubernetes_config.cluster_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The name of the cluster Kiali is deployed in. This is also known as the home cluster. This is only used in multi cluster environments. This must be set when <code>clustering.ignore_home_cluster=true</code>. If not set, Kiali will try to auto detect the cluster name from the Istiod deployment or use the default &lsquo;Kubernetes&rsquo;.</p>

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
<p>The signing key used to generate tokens for user authentication. Because this is potentially sensitive, you have the option to store this value in a secret using the pattern <code>secret:&lt;secretName&gt;:&lt;secretKey&gt;</code>. When using a secret, the signing key is read dynamically, enabling automatic rotation without pod restart. If left as an empty string, a secret with a random signing key will be generated for you. The signing key must be 16, 24 or 32 byte long.</p>

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
<h3 class="property-path" id=".spec.server.node_port">.spec.server.node_port</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>If <code>deployment.service_type</code> is &lsquo;NodePort&rsquo; and this value is set, then this is the node port that the Kiali service will listen to.</p>

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
<p>The metrics HTTP listener is started when either this or health_status.enabled is true.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.metrics.health_status">.spec.server.observability.metrics.health_status</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Settings for the kiali_health_status Prometheus gauge (per-entity health from the health cache refresh). Independent of metrics.enabled.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.metrics.health_status.enabled">.spec.server.observability.metrics.health_status.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, Kiali exports kiali_health_status metrics during health cache refresh.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.metrics.health_status.max_consecutive_na">.spec.server.observability.metrics.health_status.max_consecutive_na</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>Number of consecutive health refresh cycles an entity may report NA or be missing before its kiali_health_status series is removed. Values less than or equal to 0 use the server default (3).</p>

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
<h3 class="property-path" id=".spec.server.observability.tracing.collector_type">.spec.server.observability.tracing.collector_type</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The collector type to use. Today the only valid value is <code>otel</code>.</p>

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
<p>Used to determine where the Kiali server tracing data will be stored.</p>

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

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.tracing.otel">.spec.server.observability.tracing.otel</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Specific properties when the collector type is <code>otel</code>.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.tracing.otel.ca_name">.spec.server.observability.tracing.otel.ca_name</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>DEPRECATED since v2.20: This setting is deprecated and will be ignored. To configure custom CA certificates, use the kiali-cabundle ConfigMap instead. See the TLS Configuration documentation for details.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.tracing.otel.protocol">.spec.server.observability.tracing.otel.protocol</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Protocol. Value must be one of: <code>http</code>, <code>https</code> or <code>grpc</code>.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.tracing.otel.skip_verify">.spec.server.observability.tracing.otel.skip_verify</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>If true, TLS certificate verification will not be performed. This is an unsecure option and is recommended only for testing.</p>

</div>

</div>
</div>

<div class="property depth-5">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.tracing.otel.tls_enabled">.spec.server.observability.tracing.otel.tls_enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Enable TLS for the collector. This must be specified when <code>protocol</code> is <code>https</code> or <code>grpc</code>.</p>

</div>

</div>
</div>

<div class="property depth-4">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.observability.tracing.sampling_rate">.spec.server.observability.tracing.sampling_rate</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(number)</span>

</div>

<div class="property-description">
<p>Sampling rate for Kiali server traces. &gt;= 1.0 always samples and &lt;= 0 never samples.</p>

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
<h3 class="property-path" id=".spec.server.profiler">.spec.server.profiler</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Controls the internal profiler used to debug the internals of Kiali</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.profiler.enabled">.spec.server.profiler.enabled</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When &lsquo;true&rsquo;, the profiler will be enabled and accessible at /debug/pprof/ on the Kiali endpoint.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.require_auth">.spec.server.require_auth</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>When true, the /api endpoint will require users to authenticate themselves. When false, users need not authenticate with Kiali in order to get basic runtime info about the server via the /api endpoint. This setting is ignored if auth.strategy is &lsquo;anonymous&rsquo;.</p>

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

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.server.write_timeout">.spec.server.write_timeout</h3>
</div>
<div class="property-body">
<div class="property-meta">


</div>

<div class="property-description">
<p>The maximum duration before timing out writes of the HTTP response back to the client.
Can be specified as a number (seconds) or duration string (e.g., &ldquo;30s&rdquo;, &ldquo;1h&rdquo;, &ldquo;2m30s&rdquo;).</p>

<p>In OpenShift clusters, the route request time out should be also increased.
This can be done by annotating the specific route with <code>haproxy.router.openshift.io/timeout</code>.
See <a href="https://docs.openshift.com/container-platform/4.16/networking/routes/route-configuration.html#nw-configuring-route-timeouts_route-configuration">https://docs.openshift.com/container-platform/4.16/networking/routes/route-configuration.html#nw-configuring-route-timeouts_route-configuration</a> for further details.</p>

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
<p>The version of the Ansible role that will be executed in order to install Kiali.
This also indirectly determines the version of Kiali that will be installed.
You normally will want to use <code>default</code> since this is the only officially supported value today.</p>

<p>If not specified, the value of <code>default</code> is assumed which means the most recent Ansible role is used;
thus the most recent release of Kiali will be installed.</p>

<p>Refer to this file to see what the valid values are for this <code>version</code> field (as defined in the master branch),
<a href="https://github.com/kiali/kiali-operator/blob/master/playbooks/kiali-default-supported-images.yml">https://github.com/kiali/kiali-operator/blob/master/playbooks/kiali-default-supported-images.yml</a></p>

<p>This <code>version</code> setting affects the defaults of the <code>deployment.image_name</code> and
<code>deployment.image_version</code> settings. See the documentation for those settings below for
additional details. In short, this <code>version</code> setting will dictate which version of the
Kiali image will be deployed by default. However, if you explicitly set <code>deployment.image_name</code>
and/or <code>deployment.image_version</code> to reference your own custom image, that will override the
default Kiali image to be installed; therefore, you are responsible for ensuring those settings
are compatible with the Ansible role that will be executed in order to install Kiali (i.e. your
custom Kiali image must be compatible with the rest of the configuration and resources the
operator will install).</p>

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



