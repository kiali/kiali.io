---
title: "ACM Observability"
description: "Configure Kiali to use Red Hat Advanced Cluster Management Observability for centralized metrics in multi-cluster OpenShift environments."
weight: 20
---

{{% alert color="warning" %}}
**OpenShift Only**: This guide is specifically for Red Hat OpenShift environments using Red Hat Advanced Cluster Management (ACM) for Kubernetes. ACM is an OpenShift-specific product.
{{% /alert %}}

## Overview

Red Hat Advanced Cluster Management (ACM) provides centralized observability for multi-cluster OpenShift environments through its Observability Service. When ACM Observability is enabled, metrics from all managed clusters (including the hub cluster itself) are collected and aggregated into a central Thanos-based storage system.

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
- **Metrics Allowlist ConfigMaps**: Define which metrics ACM should collect
- **Metrics Collector**: Runs on each managed cluster and pushes its Prometheus metrics to the hub cluster's Thanos every 5 minutes (default)

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
3. The **ACM observability collector/agent** on the managed cluster reads from Prometheus and ships metrics to the hub (typically every 5 minutes).
4. The hub stores them in **Thanos Receive/Store** and serves them through **Thanos Query Frontend**.

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
  name: istio-proxies-monitor
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

### 4. Metrics Allowlist Configuration

ACM only collects metrics that are explicitly allowlisted. For **user workload metrics** (Istio), create a ConfigMap in the **source namespace** with key `uwl_metrics_list.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: observability-metrics-custom-allowlist
  namespace: <your-mesh-namespace>
data:
  uwl_metrics_list.yaml: |
    names:
    # Core Istio metrics below. For additional metrics that Kiali uses,
    # see: https://kiali.io/docs/faq/general/#requiredmetrics
    #
    # L7 (HTTP) metrics - from sidecars and waypoint proxies
    - istio_requests_total
    - istio_request_duration_milliseconds_bucket
    - istio_request_duration_milliseconds_sum
    - istio_request_duration_milliseconds_count
    - istio_request_bytes_bucket
    - istio_request_bytes_sum
    - istio_request_bytes_count
    - istio_response_bytes_bucket
    - istio_response_bytes_sum
    - istio_response_bytes_count
    # L4 (TCP) metrics - from sidecars, waypoint proxies, AND ztunnel
    - istio_tcp_sent_bytes_total
    - istio_tcp_received_bytes_total
    - istio_tcp_connections_opened_total
    - istio_tcp_connections_closed_total
```

**Critical**: The ConfigMap must be in the **source namespace** where metrics originate (e.g., `istio-system`, application namespaces), **NOT** in `open-cluster-management-observability`.

{{% alert color="info" %}}
**Ambient Mode**: The same allowlist works for all Istio data plane components. However, ztunnel only produces TCP metrics (`istio_tcp_*`), so HTTP metrics in the allowlist will have no data from ztunnel. Waypoints produce both TCP and HTTP metrics, same as sidecars. Create the allowlist ConfigMap in each namespace where you have a PodMonitor, including the namespace where ztunnel runs and any namespaces with waypoint proxies.
{{% /alert %}}

See: [Adding user workload metrics](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.12/html-single/observability/index#adding-user-workload-metrics)

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
        retention_period: "14d"
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
  --set external_services.prometheus.thanos_proxy.retention_period="14d" \
  --set external_services.prometheus.thanos_proxy.scrape_interval="5m"
```

## Important Configuration Notes

### Metrics Latency

ACM collects metrics from each cluster's Prometheus and pushes to Thanos **every 5 minutes** (default). This means, by default, there is a 5-6 minute delay before new metrics appear in Kiali. This latency is inherent to ACM's architecture and applies to all managed clusters.

**Note**: This interval is configurable via the `spec.observabilityAddonSpec.interval` field (in seconds) in the `MultiClusterObservability` CR on the hub cluster.

**Initial warm-up period**: After deploying a new application, it takes approximately **twice the collection interval** before metrics appear in Kiali. This is because Kiali uses PromQL `rate()` functions which require at least two data points to compute a result, and with ACM's collection interval, two data points take at least two collection cycles to accumulate. For example, with the default 5-minute interval, expect a ~10-minute warm-up period. After this initial warm-up, all time ranges in Kiali should display data normally. However, keep in mind that the most recent data visible in Kiali will always be at least one collection interval old, since metrics must complete a full collection cycle before they appear in Thanos.

### Thanos Proxy Mode

Enable `thanos_proxy` when using ACM/Thanos:

```yaml
external_services:
  prometheus:
    thanos_proxy:
      enabled: true
      retention_period: "14d"  # Should match your ACM Thanos retention
      scrape_interval: "5m"   # Must match ACM's metrics collection interval
```

When `enabled: true`, Kiali uses the configured `scrape_interval` and `retention_period` values directly, rather than querying Prometheus's `/api/v1/status/config` and `/api/v1/status/runtimeinfo` endpoints to discover them. This is necessary because Thanos does not expose these Prometheus configuration endpoints.

**Why these values matter:**
- **`scrape_interval`**: Kiali's UI uses this value to compute PromQL `rate()` intervals and query step sizes. The rate interval must be large enough to contain at least two data points for `rate()` to produce results. With ACM, data points arrive in Thanos at the ACM collection interval (default 5 minutes), **not** at the local Prometheus scrape interval (typically 15-30 seconds). If `scrape_interval` is set too low (e.g., "30s"), the computed rate windows will be too narrow to capture two ACM data points, causing Kiali's metrics tab to show empty charts even though data exists in Thanos.

{{% alert color="warning" %}}
**Critical**: Set `scrape_interval` to match the **ACM metrics collection interval** (default `"5m"`), not the local Prometheus scrape interval. The ACM collection interval is configured via `spec.observabilityAddonSpec.interval` in the `MultiClusterObservability` CR on the hub cluster. If you have customized this value, set `scrape_interval` to match.
{{% /alert %}}

- **`retention_period`**: Used to limit time range queries to available data. ACM defaults to 365d retention when `spec.advanced.retentionConfig` is not explicitly configured in the `MultiClusterObservability` CR. If using the default, set `retention_period` to "365d". If configuring custom retention, use at least 10d minimum (a Thanos requirement for downsampling to function). Always match `retention_period` to your actual ACM retention configuration. The "14d" value shown in examples here is used for demonstration.

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

### 3. External Deployment Model

For multi-cluster with ACM, if you deploy Kiali on the hub cluster (or on a separate management cluster), you will typically want to run Kiali in **external deployment mode**:

```yaml
clustering:
  ignore_home_cluster: true  # Kiali is external to mesh

kubernetes_config:
  cluster_name: "<management-cluster-name>"  # Unique name for the cluster where Kiali runs
```

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
2. **Wait 5-10 minutes** for metrics to propagate to Thanos
3. **Access Kiali UI** and navigate to a workload
4. **Select time range** that includes data older than 5-6 minutes (e.g., "Last 30 minutes")
5. **Verify metrics** appear in the Metrics tab and traffic graph

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

### No Metrics Displayed

**Symptom**: Kiali shows empty graphs and "No metrics" in dashboards.

**Causes and Solutions**:

1. **Time range too recent**: Metrics have several minutes-long latency due to ACM's collection interval
   - **Solution**: In the Kiali UI, use the time range dropdown to select "Last 30m" or longer to ensure the query includes data that has been collected by ACM

2. **Metrics not allowlisted**: ACM doesn't collect metrics by default
   - **Solution**: Create `observability-metrics-custom-allowlist` ConfigMap with `uwl_metrics_list.yaml` key in **source namespace**

3. **PodMonitor missing**: Prometheus not scraping Istio data plane components
   - **Solution**: Create `istio-proxies-monitor` PodMonitor in **each mesh namespace** (including the ztunnel namespace and namespaces with waypoint proxies if using Ambient mode)

4. **UWM not enabled**: User Workload Monitoring not configured
   - **Solution**: Enable `enableUserWorkload: true` in `cluster-monitoring-config` ConfigMap in `openshift-monitoring` namespace

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

1. **Verify route exists**: `oc get route observatorium-api -n open-cluster-management-observability`
2. **Check ACM is ready**: `oc get mco observability -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}{"\n"}'` (should return "True")
3. **Test connectivity**:
   ```bash
   # Query via API server proxy
   oc get --raw "/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/-/ready"
   ```
   Expected response: `OK`
4. **Check NetworkPolicies**: Ensure no policies block egress from Kiali's namespace

### Empty Graph Despite Having Metrics

**Symptom**: Metrics appear in workload details but graph is empty

**Possible causes**:

1. **Time range**: Graph query may be for recent data not yet in Thanos
2. **Missing source/destination labels**: Verify Istio metrics have proper labels
3. **Query scope mismatch**: Check `query_scope` cluster names match actual `cluster` label values

### Ambient Mode: No HTTP Metrics

**Symptom**: Ambient mode workloads show TCP traffic in Kiali but no HTTP metrics (response codes, latency)

**Possible causes**:

1. **No waypoint deployed**: Ztunnel only provides L4 (TCP) metrics. Deploy a waypoint proxy for L7 (HTTP) visibility.

2. **Missing waypoint PodMonitor**: Even with a waypoint, metrics won't be collected without a PodMonitor:
   - Verify waypoint pod exists: `oc get pods -n <namespace> -l gateway.networking.k8s.io/gateway-class-name=istio-waypoint`
   - Create PodMonitor in the waypoint's namespace (same config as sidecar PodMonitor)

3. **Missing allowlist in waypoint namespace**: Create the `observability-metrics-custom-allowlist` ConfigMap in the namespace where the waypoint runs (see [Metrics Allowlist Configuration](#4-metrics-allowlist-configuration))

### Ambient Mode: No Ztunnel Metrics

**Symptom**: Ambient mode workloads show no traffic at all in Kiali

**Possible causes**:

1. **Missing ztunnel PodMonitor**: Create `istio-proxies-monitor` PodMonitor in the ztunnel namespace
2. **Wrong ztunnel namespace**: Verify ztunnel location: `oc get pods -l app=ztunnel -A`
3. **Missing allowlist**: Create `observability-metrics-custom-allowlist` ConfigMap in the ztunnel namespace (see [Metrics Allowlist Configuration](#4-metrics-allowlist-configuration))

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
        retention_period: "14d"
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

- [Red Hat ACM Observability Documentation](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.12/html-single/observability/index)
- [Configuring User Workload Monitoring](https://docs.redhat.com/en/documentation/monitoring_stack_for_red_hat_openshift/4.20/html-single/configuring_user_workload_monitoring/)
- [OpenShift Service Mesh Observability](https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0/html-single/observability/)
- [Istio Standard Metrics](https://istio.io/latest/docs/reference/config/metrics/)
- [Troubleshoot Ztunnel Connectivity (Istio Ambient Mode)](https://istio.io/latest/docs/ambient/usage/troubleshoot-ztunnel/)
- [Connecting Grafana to ACM Observability (Red Hat Blog)](https://www.redhat.com/en/blog/how-your-grafana-can-fetch-metrics-from-red-hat-advanced-cluster-management-observability-observatorium-and-thanos)
- [Kiali Multi-cluster Setup]({{< relref "../multi-cluster" >}})
- [External Kiali Deployment]({{< relref "./external" >}})
- [TLS Configuration]({{< relref "../p8s-jaeger-grafana/tls-configuration" >}})
