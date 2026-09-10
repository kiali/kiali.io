---
title: "ACM Observability"
description: "Configure Kiali to use Red Hat Advanced Cluster Management (ACM) and the multicluster observability add-on for centralized, federated mesh metrics in multi-cluster OpenShift environments."
weight: 20
---

{{% alert color="warning" %}}
**OpenShift Only**: This guide is specifically for Red Hat OpenShift environments using Red Hat Advanced Cluster Management (ACM) for Kubernetes. ACM is an OpenShift-specific product.
{{% /alert %}}

## Overview

Red Hat Advanced Cluster Management (ACM) provides centralized observability for multi-cluster OpenShift environments through its Observability Service. Metrics from all managed clusters (including the hub cluster itself) are collected and aggregated into a central Thanos-based storage system

This guide uses the multicluster observability add-on (MCOA) to aggregate mesh metrics on managed clusters (introduced in ACM 4.17), federate selected series, and remote-write them to the central Thanos-based storage system.

Kiali can query these aggregated metrics either through ACM's external Observatorium API (using mTLS authentication) or directly through internal Thanos services. This guide explains both options, with detailed steps for the Observatorium API approach.

## Architecture

### Components

**On the Hub Cluster:**
- **ACM Observability Service**: Centralized observability platform
  - **Observatorium API**: External HTTPS endpoint with mTLS authentication
  - **Thanos**: Metrics storage and query engine (Query, Query Frontend, Receive, Store)

**On Managed Clusters (Hub + Spokes):**
- **User Workload Monitoring (UWM)**: OpenShift's Prometheus for user workloads
- **PodMonitor/ServiceMonitor**: Scrape Istio metrics from:
  - Sidecar proxies (in application namespaces)
  - Control plane (istiod in istio-system)
  - Ztunnel (in ztunnel namespace, for L4 metrics in Ambient mode)
  - Waypoint proxies (in application namespaces, for L7 metrics in Ambient mode)
- **One MCOA PrometheusRule per target namespace**: Aggregates that namespace's raw per-proxy traffic series into `workload:istio_*` series on UWM
- **MCOA user-workload Prometheus Agent**: Federates selected UWM series, restores standard `istio_*` metric names, and remote-writes them to hub Thanos

**Kiali Deployment Location:**

Kiali can be deployed on **any cluster with network access** to:
1. The hub cluster's metrics backend (Observatorium API or internal Thanos services)
2. Each managed cluster's Kubernetes API (for workload and configuration data)

Common deployment locations:
- **Hub cluster** (recommended): Co-located with ACM for lower latency metric queries and simplified networking. Can use internal Thanos services (HTTP) or external Observatorium API (HTTPS). Typically requires external deployment mode (`ignore_home_cluster: true`) since the hub usually doesn't run mesh workloads or an Istio control plane.
- **Spoke/managed cluster**: Kiali deployed alongside the mesh workloads or the Istio control plane. Must use external Observatorium API route.
- **Separate management cluster**: Kiali deployed externally in dedicated "external deployment" mode (see [External Kiali]({{< relref "./external" >}})). Must use external Observatorium API route.

This guide assumes Kiali is deployed on the hub cluster in external deployment mode, but the configuration applies to any deployment location.

### Metrics Flow

There are two independent flows:

**Ingestion (managed cluster → hub):**
1. **Istio data plane components** (sidecars, ztunnel, or waypoint proxies) expose metrics at `:15020/stats/prometheus`.
2. **User Workload Monitoring Prometheus** scrapes those metrics (typically every 30s).
3. UWM evaluates recording rules that remove per-proxy cardinality and produce `workload:istio_*` series.
4. The **MCOA user-workload Prometheus Agent** federates selected series through `/federate`, relabels `workload:istio_*` back to `istio_*`, and remote-writes them to the hub (every 5 minutes by default).
5. The hub stores them in **Thanos Receive/Store** and serves them through **Thanos Query Frontend**.

**Query (Kiali → hub):**

Kiali can query metrics through either of these paths:

*Via Observatorium API Route (HTTPS with mTLS):*
1. **Kiali** queries the external Observatorium API route.
2. **Observatorium** forwards the request to Thanos Query Frontend.
3. **Thanos Query Frontend** reads from Thanos Store/Receive and returns the result back through Observatorium to Kiali.

*Via Internal Thanos Service (HTTP):*
1. **Kiali** queries the internal Thanos Query Frontend service directly within the cluster, bypassing Observatorium.

**Expected Latency**: 5-6 minutes from traffic generation to visibility in Kiali due to the 5-minute (default) push interval.

## Prerequisites

### 1. ACM Observability Service

ACM MultiClusterObservability must be installed on the hub cluster:

```bash
# Verify ACM Observability is running
oc get mco observability

# Check Observatorium API route
oc get route observatorium-api -n open-cluster-management-observability
```

### 2. User Workload Monitoring

User Workload Monitoring must be enabled on all clusters (hub and spokes):

```bash
# Enable UWM by editing cluster-monitoring-config
oc -n openshift-monitoring edit configmap cluster-monitoring-config

# Add:
# data:
#   config.yaml: |
#     enableUserWorkload: true

# Verify UWM pods are running
oc get pods -n openshift-user-workload-monitoring
```

See: [Enabling monitoring for user-defined projects](https://docs.redhat.com/en/documentation/monitoring_stack_for_red_hat_openshift/4.20/html-single/configuring_user_workload_monitoring/index)

### 3. Istio Metrics Collection

Create ServiceMonitor and PodMonitor resources to collect Istio metrics. The **PodMonitor for sidecars** must be created in **each namespace** with Istio sidecars because OpenShift monitoring ignores `namespaceSelector` in these resources. The **ServiceMonitor for `istiod`** is created once in `istio-system`.

**ServiceMonitor for istiod** (in istio-system):

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: istiod-monitor
  namespace: istio-system
spec:
  targetLabels:
  - app
  selector:
    matchLabels:
      istio: pilot
  endpoints:
  - port: http-monitoring
    interval: 30s
```

**PodMonitor for Istio proxies** (must be applied in every mesh namespace):

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: istio-proxies-monitor-<your-mesh-namespace>
  namespace: <your-mesh-namespace>
spec:
  selector:
    matchExpressions:
    - key: istio-prometheus-ignore
      operator: DoesNotExist
  podMetricsEndpoints:
  - path: /stats/prometheus
    interval: 30s
    relabelings:
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_container_name"]
      regex: "istio-proxy"
    - action: keep
      sourceLabels: ["__meta_kubernetes_pod_annotationpresent_prometheus_io_scrape"]
    - action: replace
      regex: (\d+);(([A-Fa-f0-9]{1,4}::?){1,7}[A-Fa-f0-9]{1,4})
      replacement: '[$2]:$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '$2:$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_pod_label_app_kubernetes_io_name","__meta_kubernetes_pod_label_app"]
      separator: ";"
      targetLabel: "app"
      action: replace
      regex: "(.+);.*|.*;(.+)"
      replacement: "${1}${2}"
    - sourceLabels: ["__meta_kubernetes_pod_label_app_kubernetes_io_version","__meta_kubernetes_pod_label_version"]
      separator: ";"
      targetLabel: "version"
      action: replace
      regex: "(.+);.*|.*;(.+)"
      replacement: "${1}${2}"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "<your-mesh-identification-string>"
      targetLabel: mesh_id
```

See: [Configuring OpenShift Monitoring with Service Mesh](https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0/html-single/observability/index)

#### Ambient Mode Metrics

If you are using Istio's **Ambient mode** instead of (or in addition to) sidecar mode, you need additional PodMonitors to collect metrics from the Ambient data plane components.

##### Understanding Ambient Mode Metrics

Ambient mode uses a layered architecture with two metric sources:

**Ztunnel (L4 metrics only)**
- Runs as a DaemonSet (namespace varies by installation)
- Handles all L4 traffic for pods enrolled in ambient mode
- Produces TCP-level metrics:
  - `istio_tcp_sent_bytes_total`
  - `istio_tcp_received_bytes_total`
  - `istio_tcp_connections_opened_total`
  - `istio_tcp_connections_closed_total`
- Does not produce HTTP metrics

**Waypoint proxies (L7 metrics)**
- Run as Deployments in application namespaces
- Optional L7 proxies deployed per-namespace or per-service
- Produce full HTTP metrics (same as sidecars):
  - `istio_requests_total`
  - `istio_request_duration_milliseconds_*`
  - `istio_request_bytes_*`
  - `istio_response_bytes_*`
  - Plus all TCP metrics listed above

If you only use ztunnel (no waypoints), Kiali will show TCP traffic but not HTTP-level details like response codes or latency histograms.

##### PodMonitor for Ztunnel

Create a PodMonitor in the namespace where ztunnel runs. Ztunnel pods expose metrics using the same interface as sidecars:

- Container name: `istio-proxy`
- Annotation: `prometheus.io/scrape: "true"`
- Metrics path: `/stats/prometheus` on port 15020

Because ztunnel uses the same metrics interface, you can use the same PodMonitor configuration shown in the [Istio Metrics Collection](#3-istio-metrics-collection) section above, changing only the `namespace` field to match your ztunnel namespace.

{{% alert color="info" %}}
**Note**: The ztunnel namespace location depends on your Istio installation method. Verify your ztunnel namespace with: `oc get pods -l app=ztunnel -A`
{{% /alert %}}

##### PodMonitor for Waypoint Proxies

Create a PodMonitor in **each namespace with a waypoint**. Waypoint pods also expose metrics using the same interface as sidecars:

- Container name: `istio-proxy`
- Annotation: `prometheus.io/scrape: "true"`
- Metrics path: `/stats/prometheus` on port 15020

Because waypoints use the same metrics interface, you can use the same PodMonitor configuration shown in the [Istio Metrics Collection](#3-istio-metrics-collection) section above.

### 4. Enable the ACM multicluster observability add-on

MCOA is disabled by default. It uses the OpenShift Cluster Observability Operator's Prometheus Operator and Prometheus Agent to federate and remote-write metrics from managed clusters. Install the Cluster Observability Operator as required by ACM, then enable both platform and user-workload metrics on the hub:

```yaml
apiVersion: observability.open-cluster-management.io/v1beta2
kind: MultiClusterObservability
metadata:
  name: observability
spec:
  capabilities:
    platform:
      metrics:
        default:
          enabled: true
    userWorkloads:
      metrics:
        default:
          enabled: true
```

Enabling these capabilities replaces the legacy metrics collectors with MCOA collectors. See the [ACM 2.17 MCOA documentation](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.17/html/observability/observing-environments-intro#multicluster-observability-addon).

{{% alert color="info" %}}
The hub-level custom allowlist used by the legacy ACM collector is still a valid legacy configuration: the observability operator merges it into the configuration distributed to managed clusters. It is not sufficient after switching to MCOA because MCOA replaces those collectors. ACM 2.17 documents migrating custom allowlists to `ScrapeConfig` and `PrometheusRule` resources; this guide uses that MCOA resource model directly.
{{% /alert %}}

### 5. Aggregate and federate Istio metrics

Use UWM as the **Edge Prometheus** described in [Recording Rules and Federation]({{< relref "../p8s-jaeger-grafana/prometheus" >}}#option-1-recording-rules-and-federation-recommended). MCOA's Prometheus Agent is the federation and remote-write layer, and ACM Observatorium/Thanos is the long-retention federated backend that Kiali queries.

Create the following resources on the hub in namespace `open-cluster-management-observability`. Repeat the `PrometheusRule` and platform `ScrapeConfig` for **each** target namespace whose Istio traffic or platform CPU and memory Kiali should display (normally the control plane namespace and every application namespace). The target namespace must exist on every managed cluster selected by the placement.

First, create a `PrometheusRule` for each target namespace. This example is for `istio-system`; change both the name suffix and target-namespace annotation for each additional namespace. The annotation tells MCOA where to propagate the rule. The label selects UWM Prometheus, rather than Thanos Ruler, to evaluate the rule on the managed cluster.

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: kiali-istio-aggregation-istio-system
  namespace: open-cluster-management-observability
  annotations:
    observability.open-cluster-management.io/target-namespace: istio-system
  labels:
    app.kubernetes.io/component: user-workload-metrics-collector
    openshift.io/prometheus-rule-evaluation-scope: leaf-prometheus
spec:
  groups:
  - name: istio.workload-aggregation
    interval: 30s
    rules:
    - record: workload:istio_requests_total
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_requests_total)
    - record: workload:istio_request_messages_total
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_messages_total)
    - record: workload:istio_response_messages_total
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_response_messages_total)
    - record: workload:istio_tcp_sent_bytes_total
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_tcp_sent_bytes_total)
    - record: workload:istio_tcp_received_bytes_total
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_tcp_received_bytes_total)
    - record: workload:istio_tcp_connections_opened_total
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_tcp_connections_opened_total)
    - record: workload:istio_tcp_connections_closed_total
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_tcp_connections_closed_total)
    - record: workload:istio_request_duration_milliseconds_bucket
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_duration_milliseconds_bucket)
    - record: workload:istio_request_duration_milliseconds_sum
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_duration_milliseconds_sum)
    - record: workload:istio_request_duration_milliseconds_count
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_duration_milliseconds_count)
    - record: workload:istio_request_bytes_bucket
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_bytes_bucket)
    - record: workload:istio_request_bytes_sum
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_bytes_sum)
    - record: workload:istio_request_bytes_count
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_request_bytes_count)
    - record: workload:istio_response_bytes_bucket
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_response_bytes_bucket)
    - record: workload:istio_response_bytes_sum
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_response_bytes_sum)
    - record: workload:istio_response_bytes_count
      expr: sum without (pod, pod_template_hash, instance, namespace, job, node) (istio_response_bytes_count)
```

Next, create this UWM `ScrapeConfig`. It federates the aggregated traffic metrics and the non-aggregated Istio, control-plane, process, and Envoy metrics that Kiali needs. The relabeling restores the original `istio_*` names before remote write.

```yaml
apiVersion: monitoring.rhobs/v1alpha1
kind: ScrapeConfig
metadata:
  name: kiali-istio-federation
  namespace: open-cluster-management-observability
  labels:
    app.kubernetes.io/component: user-workload-metrics-collector
spec:
  honorLabels: true
  jobName: kiali-istio-federation
  metricRelabelings:
  - action: replace
    regex: 'workload:(.*)'
    replacement: '${1}'
    sourceLabels: [__name__]
    targetLabel: __name__
  metricsPath: /federate
  params:
    match[]:
    - '{__name__=~"workload:istio_requests_total"}'
    - '{__name__=~"workload:istio_request_bytes_(bucket|count|sum)"}'
    - '{__name__=~"workload:istio_request_duration_milliseconds_(bucket|count|sum)"}'
    - '{__name__=~"workload:istio_request_messages_total"}'
    - '{__name__=~"workload:istio_response_bytes_(bucket|count|sum)"}'
    - '{__name__=~"workload:istio_response_messages_total"}'
    - '{__name__=~"workload:istio_tcp_connections_(opened|closed)_total"}'
    - '{__name__=~"workload:istio_tcp_(received|sent)_bytes_total"}'
    - '{__name__=~"istio_build|process_cpu_seconds_total|process_resident_memory_bytes"}'
    - '{__name__=~"pilot_info|pilot_proxy_convergence_time_(sum|count)|pilot_services|pilot_xds$|pilot_xds_pushes"}'
    - '{__name__=~"workload_manager_active_proxy_count"}'
    - '{__name__=~"envoy_cluster_upstream_cx_active|envoy_cluster_upstream_rq_total|envoy_listener_downstream_cx_active|envoy_listener_http_downstream_rq|envoy_server_memory_allocated|envoy_server_memory_heap_size|envoy_server_uptime"}'
```

Now create this platform `ScrapeConfig` once per target namespace. This example collects CPU and memory metrics for pods in `istio-system`; for each additional target namespace, change `metadata.name`, `spec.jobName`, and the `namespace` value in `spec.params.match[]`.

```yaml
apiVersion: monitoring.rhobs/v1alpha1
kind: ScrapeConfig
metadata:
  name: kiali-istio-platform-federation-istio-system
  namespace: open-cluster-management-observability
  labels:
    app.kubernetes.io/component: platform-metrics-collector
spec:
  jobName: kiali-istio-platform-federation-istio-system
  metricsPath: /federate
  params:
    match[]:
    - '{__name__=~"container_cpu_usage_seconds_total|container_memory_working_set_bytes",namespace="istio-system"}'
```

Finally, add references for the `PrometheusRule` objects and all `ScrapeConfig` objects to the selected placement in the existing `ClusterManagementAddOn` object named `multicluster-observability-addon`. The following is a fragment of that placement's `configs` list; merge these entries with its existing entries rather than applying this as a replacement for the whole add-on object. Add one `PrometheusRule` reference and one platform `ScrapeConfig` reference per target namespace, plus the shared `kiali-istio-federation` `ScrapeConfig` reference.

{{% alert color="info" %}}
A placement is ACM's hub-side selection of managed clusters that receive an add-on configuration. Use the `name` and `namespace` from the placement entry that MCOA already uses:

```bash
oc get clustermanagementaddon multicluster-observability-addon -o yaml
```

Look under `spec.installStrategy.placements`. If multiple entries exist, choose the one that selects the managed clusters hosting this mesh. For example, if you see `name: global` and `namespace: open-cluster-management-global-set`, use those values for `<placement-name>` and `<placement-namespace>`.
{{% /alert %}}

```yaml
spec:
  installStrategy:
    placements:
    - name: <placement-name>
      namespace: <placement-namespace>
      configs:
      - group: monitoring.coreos.com
        resource: prometheusrules
        name: kiali-istio-aggregation-istio-system
        namespace: open-cluster-management-observability
      - group: monitoring.rhobs
        resource: scrapeconfigs
        name: kiali-istio-federation
        namespace: open-cluster-management-observability
      - group: monitoring.rhobs
        resource: scrapeconfigs
        name: kiali-istio-platform-federation-istio-system
        namespace: open-cluster-management-observability
```

{{% alert color="info" %}}
For a repeatable development installation, the Kiali repository's `hack/configure-acm-mcoa.sh install` helper creates these same objects and placement references without changing the current kubeconfig context. It is a convenience, not a prerequisite for this configuration.
{{% /alert %}}

{{% alert color="warning" %}}
Every target namespace must exist on every managed cluster selected by the placement before MCOA propagates its recording rule. If clusters use different namespace layouts, use separate placements and resource sets.
{{% /alert %}}

The `kiali-istio-federation` user-workload `ScrapeConfig` collects the aggregated traffic metrics rather than raw per-proxy series. The per-namespace platform `ScrapeConfig` resources collect CPU and memory separately because those metrics belong to OpenShift platform monitoring rather than UWM.

## Configuring Kiali for ACM Observability

### Choosing Between Observatorium API and Internal Thanos Services

You have two options for connecting Kiali to ACM metrics:

**Option 1: Observatorium API Route (HTTPS with mTLS)**
```yaml
external_services:
  prometheus:
    url: "https://observatorium-api-<namespace>.<apps-domain>/api/metrics/v1/default"
    auth:
      type: none
      cert_file: "secret:acm-observability-certs:tls.crt"
      key_file: "secret:acm-observability-certs:tls.key"
```

Provides:
- HTTPS with mTLS authentication and encryption
- External access (can be accessed from outside the cluster if needed)
- RBAC enforcement via Observatorium
- Multi-tenant isolation
- Requires certificate setup

**Option 2: Internal Thanos Service (HTTP)**
```yaml
external_services:
  prometheus:
    url: "http://observability-thanos-query-frontend.open-cluster-management-observability.svc:9090"
    auth:
      type: none
```

Provides:
- Simpler setup (no certificates required)
- Direct access to Thanos (potentially lower latency)
- Internal cluster networking only
- HTTP only (no encryption between Kiali and Thanos)

**Recommendation**: Use the Observatorium API for production environments where you want encrypted connections and proper authentication. Use internal services for development/testing environments where simplicity is preferred or where network security is already provided by the cluster infrastructure.

**The rest of this guide focuses on the Observatorium API approach with mTLS authentication.**

### Step 1: Obtain mTLS Certificates from ACM

ACM automatically creates long-lived client certificates (1 year validity) for accessing the Observatorium API. Extract these from the hub cluster:

```bash
# Extract client certificate (for authentication)
oc get secret observability-grafana-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.tls\.crt}' | base64 -d > tls.crt

# Extract client key (for authentication)
oc get secret observability-grafana-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.tls\.key}' | base64 -d > tls.key
```

**Note**: These certificates are created automatically when ACM MultiClusterObservability is deployed and are already trusted by the Observatorium API.

{{% alert color="info" %}}
**ACM Version Note**: Secret names may vary depending on your ACM version. Before proceeding, verify the secret exists:
```bash
oc get secrets -n open-cluster-management-observability | grep -i cert
```
If `observability-grafana-certs` doesn't exist, look for similar secrets containing client certificates.
{{% /alert %}}

### Step 2: Extract Server CA Certificate

Extract the CA certificate that signed the Observatorium API server certificate. This is used by Kiali to validate the server's TLS certificate.

**First, identify which CA issued the server certificate:**

```bash
# Get the Observatorium API route hostname
HOST=$(oc get route observatorium-api -n open-cluster-management-observability -o jsonpath='{.spec.host}')

# Check who issued the server certificate
echo | openssl s_client -connect "${HOST}:443" -servername "${HOST}" -showcerts 2>/dev/null | openssl x509 -noout -issuer
```

Example output:
```
issuer=C=US, O=Red Hat, Inc., CN=observability-server-ca-certificate
```

**Then, extract the matching CA certificate based on the issuer CN:**

If the issuer CN is `observability-server-ca-certificate`:
```bash
oc get secret observability-server-ca-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > server-ca.crt
```

If the issuer CN is `observability-client-ca-certificate`:
```bash
oc get secret observability-client-ca-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > server-ca.crt
```

**Note**: Both secrets are in the `open-cluster-management-observability` namespace. The exact CA used may vary depending on your ACM version and configuration.

### Step 3: Create Kubernetes Resources

{{% alert color="info" %}}
**Note**: `<kiali-namespace>` and `${KIALI_NAMESPACE}` are used as a placeholder for the namespace where Kiali is deployed. This is commonly `istio-system` but is not required to be - replace with your actual Kiali namespace.
{{% /alert %}}

**Create the mTLS certificate secret** in Kiali's namespace:

```bash
KIALI_NAMESPACE="istio-system"  # Replace with your Kiali namespace

oc create secret generic acm-observability-certs \
  -n ${KIALI_NAMESPACE} \
  --from-file=tls.crt=tls.crt \
  --from-file=tls.key=tls.key
```

**Create the CA bundle ConfigMap** in Kiali's namespace:

```bash
oc create configmap kiali-cabundle \
  -n ${KIALI_NAMESPACE} \
  --from-file=additional-ca-bundle.pem=server-ca.crt
```

{{% alert color="info" %}}
**On OpenShift**: The Kiali Operator (or Helm chart) automatically creates a separate ConfigMap named `kiali-cabundle-openshift` for the OpenShift service CA, then uses a projected volume to combine it with your custom `kiali-cabundle` ConfigMap. You only need to create/manage `kiali-cabundle` with your ACM CA - the system handles merging.
{{% /alert %}}

For more details about CA bundle configuration, see [TLS Configuration]({{< relref "../p8s-jaeger-grafana/tls-configuration" >}}).

### Step 4: Get Observatorium API URL

Find the external Observatorium API route URL:

```bash
oc get route observatorium-api \
  -n open-cluster-management-observability \
  -o jsonpath='https://{.spec.host}/api/metrics/v1/default'
```

The URL format is: `https://observatorium-api-<namespace>.<apps-domain>/api/metrics/v1/default`

### Step 5: Configure Kiali

**Using Kiali Operator (Kiali CR):**

```yaml
spec:
  external_services:
    prometheus:
      # Use Observatorium API route
      url: "<observatorium-api-url>"

      auth:
        type: none  # mTLS authentication at TLS layer, no Authorization header
        cert_file: "secret:acm-observability-certs:tls.crt"
        key_file: "secret:acm-observability-certs:tls.key"

      # Enable Thanos proxy mode
      thanos_proxy:
        enabled: true
        retention_period: "365d"
        scrape_interval: "5m"
```

**Using Server Helm Chart:**

```bash
OBSERVATORIUM_API_URL="$(oc get route observatorium-api -n open-cluster-management-observability -o jsonpath='https://{.spec.host}/api/metrics/v1/default')"

helm install kiali kiali-server \
  --namespace ${KIALI_NAMESPACE} \
  --set external_services.prometheus.url="${OBSERVATORIUM_API_URL}" \
  --set external_services.prometheus.auth.type="none" \
  --set external_services.prometheus.auth.cert_file="secret:acm-observability-certs:tls.crt" \
  --set external_services.prometheus.auth.key_file="secret:acm-observability-certs:tls.key" \
  --set external_services.prometheus.thanos_proxy.enabled="true" \
  --set external_services.prometheus.thanos_proxy.retention_period="365d" \
  --set external_services.prometheus.thanos_proxy.scrape_interval="5m"
```

## Important Configuration Notes

### Metrics Latency

The MCOA `PrometheusAgent` scrapes its federation endpoint every **300 seconds** by default and remote-writes the result to Thanos. This means there is normally a 5-6 minute delay before new metrics appear in Kiali.

To use a different interval for the Kiali federation jobs, set `spec.scrapeInterval` on the `kiali-istio-federation` `ScrapeConfig` and on each `kiali-istio-platform-federation-<namespace>` `ScrapeConfig`. For example, the following makes the shared user-workload job run every minute:

```yaml
spec:
  jobName: kiali-istio-federation
  scrapeInterval: 1m
  # Other fields from the ScrapeConfig in step 5 remain unchanged.
```

Set Kiali's `external_services.prometheus.thanos_proxy.scrape_interval` to the same interval. Do not change the generated MCOA `PrometheusAgent` merely to alter these Kiali jobs: that changes the default interval for the agent's other jobs as well.

**Initial warm-up period**: After deploying a new application, it takes approximately **twice the collection interval** before data appears in Kiali's graph and metrics tab. This is because Kiali uses PromQL `rate()` functions which require at least two data points to compute a result, and with ACM's collection interval, two data points take at least two collection cycles to accumulate. For example, with the default 5-minute interval, expect a ~10-minute warm-up period. After this initial warm-up, all time ranges in Kiali should display data normally. However, keep in mind that the most recent data visible in Kiali will always be at least one collection interval old, since metrics must complete a full collection cycle before they appear in Thanos.

### Thanos Proxy Mode

Enable `thanos_proxy` when using ACM/Thanos:

```yaml
external_services:
  prometheus:
    thanos_proxy:
      enabled: true
      retention_period: "365d" # Match your actual ACM Thanos retention
      scrape_interval: "5m"   # Must match the MCOA federation interval
```

When `enabled: true`, Kiali uses the configured `scrape_interval` and `retention_period` values directly, rather than querying Prometheus's `/api/v1/status/config` and `/api/v1/status/runtimeinfo` endpoints to discover them. This is necessary because Thanos does not expose these Prometheus configuration endpoints.

**Why these values matter:**
- **`scrape_interval`**: Kiali's UI uses this value to compute PromQL `rate()` intervals and query step sizes. The rate interval must be large enough to contain at least two data points for `rate()` to produce results. With ACM, data points arrive in Thanos at the ACM collection interval (default 5 minutes), **not** at the local Prometheus scrape interval (typically 15-30 seconds). If `scrape_interval` is set too low (e.g., "30s"), the computed rate windows will be too narrow to capture two ACM data points, causing Kiali's metrics tab to show empty charts even though data exists in Thanos.

{{% alert color="warning" %}}
**Critical**: Set `scrape_interval` to match the effective **MCOA federation interval** (default `"5m"`), not the local UWM scrape interval. MCOA's default `PrometheusAgent.spec.scrapeInterval` is `300s`; a per-job `ScrapeConfig` interval can override it. If you customize either value, configure Kiali with the effective interval.
{{% /alert %}}

- **`retention_period`**: Used to limit time range queries to available data. ACM defaults to 365d retention when `spec.advanced.retentionConfig` is not explicitly configured in the `MultiClusterObservability` CR. If using the default, set `retention_period` to "365d". If configuring custom retention, use at least 10d minimum (a Thanos requirement for downsampling to function). Always match `retention_period` to your actual ACM retention configuration. Use `14d` only when your `MultiClusterObservability` retention policy is configured for 14 days.

## Multi-Cluster Setup

For multi-cluster service mesh deployments with ACM:

### 1. Metrics Aggregation (Handled by ACM)

ACM automatically aggregates metrics from all managed clusters. Each cluster's metrics include a `cluster` label with the cluster name (the `metadata.name` of the ManagedCluster resource). To get a list of all the clusters managed by ACM, run `oc get managedcluster` on the hub cluster.

Kiali can filter metrics by cluster using `query_scope`. The `query_scope` configuration adds label filters to every Prometheus query:

```yaml
external_services:
  prometheus:
    # Example 1: Filter to a single cluster
    query_scope:
      cluster: "east-cluster"

    # Example 2: Filter by mesh_id and cluster
    query_scope:
      mesh_id: "mesh-1"
      cluster: "east-cluster"
```

Each key-value pair in `query_scope` is added as `key="value"` to every query. For example, `cluster: "east-cluster"` adds `cluster="east-cluster"` to all PromQL queries.

### 2. Remote Cluster Access (For Workload/Config Data)

While metrics come from ACM's central Thanos, Kiali still needs direct API access to each cluster for:
- Workload and service discovery
- Istio configuration validation
- Kubernetes resource details

Create remote cluster secrets as described in the [multi-cluster setup guide]({{< relref "../multi-cluster" >}}).
When the external Kiali deployment uses `auth.strategy: openshift`, also follow
the [OpenShift multi-cluster authentication guidance]({{< relref "../authentication/openshift#multi-cluster" >}}).
In particular, a remote cluster that provides only
`remote_cluster_resources_only: true` needs its Kiali OAuthClient callback URI
to point to the external Kiali route and end in
`/api/auth/callback/<remote-cluster-name>`. This remote API authentication is
independent of ACM/MCOA metrics federation.

### 3. External Deployment Model

For multi-cluster with ACM, if you deploy Kiali on the hub cluster (or on a separate management cluster), you will typically want to run Kiali in **external deployment mode**:

```yaml
clustering:
  ignore_home_cluster: true  # Kiali is external to mesh

kubernetes_config:
  cluster_name: "<management-cluster-name>"  # Unique name for the cluster where Kiali runs
```

This is Kiali's own home-cluster identity. It is not required to match the ACM
`ManagedCluster` name or an Istio `clusterName`; choose a value unique among
the clusters configured in Kiali. In this external deployment model, set
`clustering.ignore_home_cluster: true` so Kiali does not attempt to treat the
management cluster as a mesh cluster.

See the [External Kiali]({{< relref "./external" >}}) guide for complete external deployment instructions.

## Certificate Management

### Automatic Rotation

ACM-issued certificates (stored in the `observability-grafana-certs` secret in the ACM observability namespace) have 1-year validity and are automatically rotated by ACM before expiration. When certificates are rotated:

1. ACM updates the `observability-grafana-certs` secret in `open-cluster-management-observability` namespace
2. You must update the `acm-observability-certs` secret in Kiali's namespace with the new certificate data. Options include:
   - Re-run the extraction commands from [Step 1: Obtain mTLS Certificates from ACM](#step-1-obtain-mtls-certificates-from-acm) manually
   - Use an ACM `ConfigurationPolicy` with hub cluster templating to automatically distribute and update the secret to the cluster where Kiali runs (see [ACM Governance documentation](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.13/html/governance/policy-deployment) for details)
3. Kubernetes updates the mounted files in Kiali pod (within 60 seconds after the secret update)
4. Kiali automatically uses new certificates on next connection (no pod restart needed)

### Using Custom Certificates

If you prefer to use your own certificate infrastructure instead of ACM's certificates:

1. Generate/obtain certificates signed by a CA trusted by ACM Observatorium API
2. Configure ACM to trust your CA (consult ACM documentation)
3. Create the `acm-observability-certs` secret with your certificates

## Verification

### Check Certificate Configuration

```bash
# Verify secret exists
oc get secret acm-observability-certs -n ${KIALI_NAMESPACE}

# Check certificate expiration
oc get secret acm-observability-certs -n ${KIALI_NAMESPACE} \
  -o jsonpath='{.data.tls\.crt}' | base64 -d | \
  openssl x509 -noout -enddate

# Verify CA bundle
oc get configmap kiali-cabundle -n ${KIALI_NAMESPACE} \
  -o jsonpath='{.data.additional-ca-bundle\.pem}' | \
  openssl x509 -noout -subject
```

### Check Kiali Logs

Verify certificates are loaded successfully:

```bash
oc logs -n ${KIALI_NAMESPACE} deployment/kiali | grep -i "credential\|certificate"

# Expected output (at "info" log level):
# INF Loaded [1] valid CA certificate(s) from [/kiali-cabundle/additional-ca-bundle.pem]
#
# Additional output (at "debug" log level):
# DBG Credential file path configured: [/kiali-override-secrets/prometheus-cert/tls.crt]
# DBG Credential file path configured: [/kiali-override-secrets/prometheus-key/tls.key]
```

### Test Metrics

1. **Generate mesh traffic** in one of your managed clusters
2. **Wait for the initial warm-up period** (approximately twice the ACM collection interval; default ~10 minutes) for metrics to propagate to Thanos and for enough data points to accumulate for rate calculations. The graph may appear sooner (after ~5 minutes).
3. **Access Kiali UI** and navigate to a workload
4. **Verify metrics** appear in the Metrics tab and traffic graph

{{% alert color="info" %}}
**Ambient Mode**: If you are using Ambient mode:
- **Ztunnel-only traffic** (no waypoint): You'll see TCP metrics and traffic edges in the graph, but HTTP details (response codes, latency) will not be available.
- **Traffic through waypoints**: You'll see full L7 metrics, same as sidecar mode.
{{% /alert %}}

### Verify Metrics in Thanos Directly

Test that metrics exist in Thanos (from within the hub cluster). The following are different queries you can run to obtain metrics data from the backend metric datastore used by ACM.

{{% alert color="info" %}}
**Note**: These commands use `jq` to format JSON output. If you don't have jq installed, simply omit `| jq .` to see the full, unfiltered and raw JSON.
{{% /alert %}}

```bash
# List available metric names (Kiali uses istio_*, pilot_*, and envoy_* metrics)
oc get --raw "/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/api/v1/label/__name__/values" | jq -r '.data[] | select(startswith("istio_") or startswith("pilot_") or startswith("envoy_"))'

# Count timeseries for key Istio metrics (shows which metrics have data and how many unique timeseries)
oc get --raw "/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/api/v1/query?query=count%20by%20(__name__)%20({__name__=~%22istio_requests_total|istio_tcp.*total%22})" | jq -r '.data.result[] | "\(.metric.__name__): \(.value[1])"'

# Query Istio request metrics with full details (limited to first result to show structure)
oc get --raw "/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/api/v1/query?query=istio_requests_total" | jq '.data.result |= .[0:1]'
```

## Troubleshooting

### Empty Graph or No Metrics

**Symptom**: Kiali shows an empty graph, "No metrics" in the metrics tab, or both.

**Causes and Solutions**:

1. **`scrape_interval` too low**: If `thanos_proxy.scrape_interval` is set lower than the ACM collection interval (e.g., "30s" instead of "5m"), Kiali's rate calculations will use windows too narrow to capture enough data points from Thanos
   - **Solution**: Set `thanos_proxy.scrape_interval` to match the ACM collection interval (default "5m"). See [Thanos Proxy Mode](#thanos-proxy-mode) for details

2. **Still in warm-up period**: After deploying a new application, it takes approximately twice the ACM collection interval (~10 minutes by default) before enough data points exist for rate calculations
   - **Solution**: Wait for the warm-up period to elapse

3. **MCOA federation resources missing**: The recording rules or federation job were not propagated to the managed cluster
   - **Solution**: On the hub, verify the correctness of the `kiali-istio-federation` and `kiali-istio-platform-federation-*` `ScrapeConfig` resources and the `kiali-istio-aggregation-*` `PrometheusRule` resources. Then verify their references under the selected `ClusterManagementAddOn` placement. On a managed cluster, run `oc get prometheusagent,scrapeconfig -A` to find MCOA's configured agent namespace (the default is `open-cluster-management-agent-addon`) and run `oc get prometheusrule -n <target-namespace>` to verify the propagated rule.

4. **PodMonitor missing**: Prometheus not scraping Istio data plane components
   - **Solution**: Create an `istio-proxies-monitor-<namespace>` PodMonitor in **each mesh namespace** (including the ztunnel namespace and namespaces with waypoint proxies if using Ambient mode)

5. **UWM not enabled**: User Workload Monitoring not configured
   - **Solution**: Enable `enableUserWorkload: true` in `cluster-monitoring-config` ConfigMap in `openshift-monitoring` namespace

6. **Missing source/destination labels**: The graph builds its topology from workload and namespace labels in the metrics. Verify Istio metrics have proper labels

7. **Namespace not selected**: Ensure the namespace is selected in the graph's namespace dropdown

8. **Query scope mismatch**: Check `query_scope` cluster names match actual `cluster` label values

See also the [Why is my graph empty?]({{< relref "../../FAQ/graph#emptygraph" >}}) FAQ for additional troubleshooting information.

### TLS/Certificate Errors

**Symptom**: Kiali logs show "x509: certificate signed by unknown authority" or "tls: bad certificate"

**Solutions**:

1. **Verify CA bundle**: Ensure `kiali-cabundle` ConfigMap has the correct CA
   ```bash
   oc get configmap kiali-cabundle -n ${KIALI_NAMESPACE} -o yaml
   ```

2. **Check certificate chain**: Verify client cert is signed by expected CA
   ```bash
   oc get secret acm-observability-certs -n ${KIALI_NAMESPACE} \
     -o jsonpath='{.data.tls\.crt}' | base64 -d | \
     openssl x509 -noout -issuer
   ```

3. **Verify projected volume**: Check both ConfigMaps are mounted
   ```bash
   oc exec -n ${KIALI_NAMESPACE} deploy/kiali -- ls -la /kiali-cabundle/
   # Should show: additional-ca-bundle.pem, service-ca.crt
   ```

### Connection Refused / Timeout

**Symptom**: Kiali cannot reach Observatorium API

**Solutions**:

1. **Verify route exists**:
   ```bash
   oc get route observatorium-api -n open-cluster-management-observability
   ```
2. **Check ACM is ready** (should return "True"):
   ```bash
   oc get mco observability -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}{"\n"}'
   ```
3. **Test connectivity** (should return "OK"):
   ```bash
   oc get --raw "/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/-/ready"
   ```
4. **Check NetworkPolicies**: Ensure no policies block egress from Kiali's namespace

### Ambient Mode: No HTTP Metrics

**Symptom**: Ambient mode workloads show TCP traffic in Kiali but no HTTP metrics (response codes, latency)

**Possible causes**:

1. **No waypoint deployed**: Ztunnel only provides L4 (TCP) metrics. Deploy a waypoint proxy for L7 (HTTP) visibility.

2. **Missing waypoint PodMonitor**: Even with a waypoint, metrics won't be collected without a PodMonitor:
   - Verify waypoint pod exists: `oc get pods -n <namespace> -l gateway.networking.k8s.io/gateway-class-name=istio-waypoint`
   - Create PodMonitor in the waypoint's namespace (same config as sidecar PodMonitor)

3. **Missing recording rule in waypoint namespace**: Create the per-namespace `PrometheusRule` and platform `ScrapeConfig` for the waypoint namespace, add their placement references, and verify that MCOA propagated the rule.

### Ambient Mode: No Ztunnel Metrics

**Symptom**: Ambient mode workloads show no traffic at all in Kiali

**Possible causes**:

1. **Missing ztunnel PodMonitor**: Create an `istio-proxies-monitor-<ztunnel-namespace>` PodMonitor in the ztunnel namespace
2. **Wrong ztunnel namespace**: Verify ztunnel location: `oc get pods -l app=ztunnel -A`
3. **Missing recording rule**: Create the per-namespace `PrometheusRule` and platform `ScrapeConfig` for the ztunnel namespace, add their placement references, and verify that MCOA propagated the rule.

## Reference

This example represents a fully configured Kiali installation using ACM Observability via the Observatorium API with mTLS:

```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: <kiali-namespace>
spec:
  clustering:
    ignore_home_cluster: true  # External deployment

  kubernetes_config:
    cluster_name: "<management-cluster-name>"

  external_services:
    prometheus:
      url: "<observatorium-api-url>"

      auth:
        type: none
        cert_file: "secret:acm-observability-certs:tls.crt"
        key_file: "secret:acm-observability-certs:tls.key"

      thanos_proxy:
        enabled: true
        retention_period: "365d"
        scrape_interval: "5m"
```

**Required Kubernetes resources:**

```yaml
---
# mTLS client certificates (from ACM)
# Data extracted from Secret observability-grafana-certs in namespace open-cluster-management-observability
apiVersion: v1
kind: Secret
metadata:
  name: acm-observability-certs
  namespace: <kiali-namespace>
type: Opaque
data:
  tls.crt: <base64-encoded-certificate>  # From observability-grafana-certs secret, tls.crt key
  tls.key: <base64-encoded-key>          # From observability-grafana-certs secret, tls.key key

---
# Server CA trust (from ACM)
# Data extracted from Secret observability-client-ca-certs (or observability-server-ca-certs) in namespace open-cluster-management-observability
apiVersion: v1
kind: ConfigMap
metadata:
  name: kiali-cabundle
  namespace: <kiali-namespace>
data:
  additional-ca-bundle.pem: |
    -----BEGIN CERTIFICATE-----
    <ACM Observability CA certificate>  # From ca.crt or tls.crt key (see Step 2 for extraction commands)
    -----END CERTIFICATE-----
```

## Additional Resources

- [Red Hat ACM 2.17 Observability Documentation](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.17/html/observability/observing-environments-intro)
- [Configuring User Workload Monitoring](https://docs.redhat.com/en/documentation/monitoring_stack_for_red_hat_openshift/4.20/html-single/configuring_user_workload_monitoring/)
- [OpenShift Service Mesh Observability](https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0/html-single/observability/)
- [Istio Standard Metrics](https://istio.io/latest/docs/reference/config/metrics/)
- [Troubleshoot Ztunnel Connectivity (Istio Ambient Mode)](https://istio.io/latest/docs/ambient/usage/troubleshoot-ztunnel/)
- [Connecting Grafana to ACM Observability (Red Hat Blog)](https://www.redhat.com/en/blog/how-your-grafana-can-fetch-metrics-from-red-hat-advanced-cluster-management-observability-observatorium-and-thanos)
- [Kiali Multi-cluster Setup]({{< relref "../multi-cluster" >}})
- [External Kiali Deployment]({{< relref "./external" >}})
- [TLS Configuration]({{< relref "../p8s-jaeger-grafana/tls-configuration" >}})
