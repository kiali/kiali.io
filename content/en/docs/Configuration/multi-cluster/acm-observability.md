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

This guide explains how to configure Kiali running on the hub cluster to query these aggregated metrics through ACM's Observatorium API using mTLS (mutual TLS) authentication.

## Architecture

### Components

**On the Hub Cluster:**
- **Kiali**: Management console for service mesh (queries metrics)
- **ACM Observability Service**: Centralized observability platform
  - **Observatorium API**: External HTTPS endpoint with mTLS authentication
  - **Thanos**: Metrics storage and query engine (Query, Query Frontend, Receive, Store)
- **Metrics Collectors**: Push metrics from hub cluster's Prometheus to Thanos every 5 minutes

**On Managed Clusters (Hub + Spokes):**
- **User Workload Monitoring (UWM)**: OpenShift's Prometheus for user workloads
- **PodMonitor/ServiceMonitor**: Scrape Istio sidecar and control plane metrics
- **Metrics Allowlist ConfigMaps**: Define which metrics ACM should collect

### Metrics Flow

```
Istio Envoy Sidecar (generates metrics)
  ↓ exposes on :15020/stats/prometheus
User Workload Monitoring Prometheus (scrapes every 30s)
  ↓ stores locally
ACM Metrics Collector (queries UWM Prometheus)
  ↓ pushes every 5 minutes
ACM Thanos Receive → Thanos Store
  ↓ queries via
Thanos Query Frontend
  ↓ proxied by
Observatorium API (HTTPS/mTLS)
  ↓ queries
Kiali
```

**Expected Latency**: 5-6 minutes from traffic generation to visibility in Kiali due to the 5-minute push interval.

## Prerequisites

### 1. ACM Observability Service

ACM MultiClusterObservability must be installed on the hub cluster:

```bash
# Verify ACM Observability is running
oc get mco observability -n open-cluster-management-observability

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

Create ServiceMonitor and PodMonitor resources to collect Istio metrics. These must be created in **each namespace** with Istio sidecars because OpenShift monitoring ignores `namespaceSelector` in these resources.

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

**PodMonitor for Istio proxies** (in every mesh namespace):

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
      sourceLabels: [__meta_kubernetes_pod_container_name]
      regex: "istio-proxy"
    - action: keep
      sourceLabels: [__meta_kubernetes_pod_annotationpresent_prometheus_io_scrape]
    - sourceLabels: [__meta_kubernetes_namespace]
      action: replace
      targetLabel: namespace
```

See: [Configuring OpenShift Monitoring with Service Mesh](https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0/html-single/observability/index)

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
    - istio_tcp_sent_bytes_total
    - istio_tcp_received_bytes_total
    - istio_tcp_connections_opened_total
    - istio_tcp_connections_closed_total
```

**Critical**: The ConfigMap must be in the **source namespace** where metrics originate (e.g., `istio-system`, application namespaces), **NOT** in `open-cluster-management-observability`.

See: [Adding user workload metrics](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.9/html/observability/customizing-observability#adding-user-workload-metrics)

## Configuration

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

### Step 2: Extract Server CA Certificate

Extract the CA certificate that signed the Observatorium API server certificate. Try these locations in order until you find one:

```bash
# Primary: observability-client-ca-certs (recommended)
oc get secret observability-client-ca-certs \
  -n open-cluster-management-issuer \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > server-ca.crt

# Fallback: observability-server-ca-certs (ca.crt key)
oc get secret observability-server-ca-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > server-ca.crt

# Fallback: observability-server-ca-certs (tls.crt key)
oc get secret observability-server-ca-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.tls\.crt}' | base64 -d > server-ca.crt
```

### Step 3: Create Kubernetes Resources

**Create the mTLS certificate secret** in Kiali's namespace:

```bash
oc create secret generic acm-observability-certs \
  -n istio-system \
  --from-file=tls.crt=tls.crt \
  --from-file=tls.key=tls.key
```

**Create the CA bundle ConfigMap** in Kiali's namespace:

```bash
oc create configmap kiali-cabundle \
  -n istio-system \
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
      # Use Observatorium API route (not internal Thanos service)
      url: "https://observatorium-api-open-cluster-management-observability.apps-crc.testing/api/metrics/v1/default"

      auth:
        type: none  # mTLS authentication at TLS layer, no Authorization header
        cert_file: "secret:acm-observability-certs:tls.crt"
        key_file: "secret:acm-observability-certs:tls.key"

      # Enable Thanos proxy mode
      thanos_proxy:
        enabled: true
        retention_period: "7d"
        scrape_interval: "30s"
```

**Using Server Helm Chart:**

```bash
helm install kiali kiali-server \
  --namespace istio-system \
  --set external_services.prometheus.url="https://observatorium-api-open-cluster-management-observability.apps-crc.testing/api/metrics/v1/default" \
  --set external_services.prometheus.auth.type="none" \
  --set external_services.prometheus.auth.cert_file="secret:acm-observability-certs:tls.crt" \
  --set external_services.prometheus.auth.key_file="secret:acm-observability-certs:tls.key" \
  --set external_services.prometheus.thanos_proxy.enabled="true" \
  --set external_services.prometheus.thanos_proxy.retention_period="7d" \
  --set external_services.prometheus.thanos_proxy.scrape_interval="30s"
```

## Important Configuration Notes

### Choosing Between Observatorium API and Internal Thanos Services

You have two options for connecting Kiali to ACM metrics:

**Option 1: Observatorium API Route (HTTPS with mTLS)**
```yaml
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

This guide focuses on the Observatorium API approach with mTLS authentication.

### Metrics Latency

ACM collects metrics from each cluster's Prometheus and pushes to Thanos **every 5 minutes**. This means:

- **Recent metrics (last 0-5 minutes)**: Not yet visible in Kiali (still in local Prometheus)
- **Historical metrics (older than 5-6 minutes)**: Available in Kiali through Thanos

**To see data in Kiali**, query time ranges that include data older than 5-6 minutes:
- ✅ "Last 10 minutes" - will show data from 5-10 minutes ago
- ✅ "Last 30 minutes" - will show data from 5-30 minutes ago
- ❌ "Last 5 minutes" - may appear empty if all traffic is very recent

This latency is inherent to ACM's architecture and applies to all managed clusters.

### Thanos Proxy Mode

Enable `thanos_proxy` when using ACM/Thanos:

```yaml
external_services:
  prometheus:
    thanos_proxy:
      enabled: true
      retention_period: "7d"  # How far back Thanos retains data
      scrape_interval: "30s"  # Scrape interval (should match your PodMonitor interval)
```

When `enabled: true`, Kiali uses the configured `scrape_interval` and `retention_period` values directly, rather than querying Prometheus's `/api/v1/status/config` and `/api/v1/status/runtimeinfo` endpoints to discover them. This is necessary because Thanos does not expose these Prometheus configuration endpoints.

**Why these values matter:**
- **`scrape_interval`**: Used by Kiali's UI to determine appropriate time window sizes and rate calculations
- **`retention_period`**: Used to limit time range queries to available data

## Multi-Cluster Setup

For multi-cluster service mesh deployments with ACM:

### 1. Metrics Aggregation (Handled by ACM)

ACM automatically aggregates metrics from all managed clusters. Each cluster's metrics include a `cluster` label with the cluster name (from the ManagedCluster resource).

Kiali can filter metrics by cluster using `query_scope`. The `query_scope` configuration adds label filters to every Prometheus query:

```yaml
external_services:
  prometheus:
    # Example 1: Filter to a single cluster
    query_scope:
      cluster: "east-cluster"

    # Example 2: Filter to multiple clusters (using regex)
    query_scope:
      cluster: "east-cluster|west-cluster"

    # Example 3: Filter by mesh_id and cluster
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

Create remote cluster secrets as described in the [multi-cluster setup guide]({{< relref "../" >}}).

### 3. External Deployment Model

For multi-cluster with ACM, deploy Kiali externally on the hub cluster:

```yaml
clustering:
  ignore_home_cluster: true  # Kiali is external to mesh

kubernetes_config:
  cluster_name: "hub"  # Unique name for hub cluster
```

See the [External Kiali]({{< relref "./external" >}}) guide for complete external deployment instructions.

## Certificate Management

### Automatic Rotation

ACM-issued certificates (stored in the `observability-grafana-certs` secret in the ACM observability namespace) have 1-year validity and are automatically rotated by ACM before expiration. When certificates are rotated:

1. ACM updates the `observability-grafana-certs` secret in `open-cluster-management-observability` namespace
2. You must update the `acm-observability-certs` secret in Kiali's namespace with the new certificate data by re-running the extraction commands from [Step 1: Obtain mTLS Certificates from ACM](#step-1-obtain-mtls-certificates-from-acm) (or automate this with a CronJob/operator that watches ACM's secret and copies the data)
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
oc get secret acm-observability-certs -n istio-system

# Check certificate expiration
oc get secret acm-observability-certs -n istio-system \
  -o jsonpath='{.data.tls\.crt}' | base64 -d | \
  openssl x509 -noout -enddate

# Verify CA bundle
oc get configmap kiali-cabundle -n istio-system \
  -o jsonpath='{.data.additional-ca-bundle\.pem}' | \
  openssl x509 -noout -subject
```

### Check Kiali Logs

Verify certificates are loaded successfully:

```bash
oc logs -n istio-system deployment/kiali | grep -i "credential\|certificate"

# Expected output:
# INF Loaded [1] valid CA certificate(s) from [/kiali-cabundle/additional-ca-bundle.pem]
# DBG Credential file path configured: [/kiali-override-secrets/prometheus-cert/tls.crt]
# DBG Credential file path configured: [/kiali-override-secrets/prometheus-key/tls.key]
```

### Test Metrics

1. **Generate mesh traffic** in one of your managed clusters
2. **Wait 5-10 minutes** for metrics to propagate to Thanos
3. **Access Kiali UI** and navigate to a workload
4. **Select time range** that includes data older than 5-6 minutes (e.g., "Last 30 minutes")
5. **Verify metrics** appear in the Metrics tab and traffic graph

### Verify Metrics in Thanos Directly

Test that metrics exist in Thanos (from within the hub cluster):

```bash
# Query Thanos directly (internal HTTP endpoint)
oc run test-thanos --image=curlimages/curl:latest \
  -n open-cluster-management-observability --rm -i --restart=Never -- \
  curl -s "http://observability-thanos-query-frontend.open-cluster-management-observability.svc:9090/api/v1/query?query=istio_requests_total" | \
  grep -o '"istio_requests_total"'
```

## Troubleshooting

### No Metrics Displayed

**Symptom**: Kiali shows empty graphs and "No metrics" in dashboards.

**Causes and Solutions**:

1. **Time range too recent**: Metrics have 5-6 minute latency
   - **Solution**: Query time ranges older than 5-6 minutes

2. **Metrics not allowlisted**: ACM doesn't collect metrics by default
   - **Solution**: Create `observability-metrics-custom-allowlist` ConfigMap with `uwl_metrics_list.yaml` key in **source namespace**
   - **Verify**: Check metrics collector logs for "metrics pushed successfully"

3. **PodMonitor missing**: Prometheus not scraping Istio sidecars
   - **Solution**: Create `istio-proxies-monitor` PodMonitor in **each mesh namespace**
   - **Verify**: Check targets in Prometheus UI

4. **UWM not enabled**: User Workload Monitoring not configured
   - **Solution**: Enable `enableUserWorkload: true` in `cluster-monitoring-config`
   - **Verify**: `oc get pods -n openshift-user-workload-monitoring`

### TLS/Certificate Errors

**Symptom**: Kiali logs show "x509: certificate signed by unknown authority" or "tls: bad certificate"

**Solutions**:

1. **Verify CA bundle**: Ensure `kiali-cabundle` ConfigMap has the correct CA
   ```bash
   oc get configmap kiali-cabundle -n istio-system -o yaml
   ```

2. **Check certificate chain**: Verify client cert is signed by expected CA
   ```bash
   oc get secret acm-observability-certs -n istio-system \
     -o jsonpath='{.data.tls\.crt}' | base64 -d | \
     openssl x509 -noout -issuer
   ```

3. **Verify projected volume** (OpenShift only): Check both ConfigMaps are mounted
   ```bash
   oc exec -n istio-system deploy/kiali -- ls -la /kiali-cabundle/
   # Should show: additional-ca-bundle.pem, service-ca.crt
   ```

### Connection Refused / Timeout

**Symptom**: Kiali cannot reach Observatorium API

**Solutions**:

1. **Verify route exists**: `oc get route observatorium-api -n open-cluster-management-observability`
2. **Check ACM is ready**: `oc get mco observability` (status should be Ready=True)
3. **Test connectivity**: Use curl from a pod to test the route
4. **Check NetworkPolicies**: Ensure no policies block egress from istio-system

### Empty Graph Despite Having Metrics

**Symptom**: Metrics appear in workload details but graph is empty

**Possible causes**:

1. **Time range**: Graph query may be for recent data not yet in Thanos
2. **Missing source/destination labels**: Verify Istio metrics have proper labels
3. **Query scope mismatch**: Check `query_scope` cluster names match actual `cluster` label values

## Production Considerations

### High Availability

For production deployments:

1. **Run multiple Kiali replicas** for redundancy
2. **Monitor ACM Observability** component health
3. **Set up alerts** for certificate expiration (< 30 days)
4. **Configure resource limits** appropriate for query load

### Performance

- **Thanos Query**: ACM Observability scales Thanos components based on load
- **Retention**: Configure `retention_period` based on your needs (default 7 days)
- **Query scope**: Use `query_scope` to limit queries to relevant clusters

### Security

- **Never use `insecure_skip_verify: true`** in production
- **Rotate certificates** before expiration
- **Monitor certificate validity**: Set up alerts for certificates expiring within 30 days
- **Use RBAC**: Ensure Kiali service account has minimum required permissions

## Reference: Complete Working Example

This example represents a fully configured Kiali installation using ACM Observability:

```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: istio-system
spec:
  deployment:
    logger:
      log_level: info
    image_pull_policy: Always

  auth:
    strategy: openshift

  clustering:
    ignore_home_cluster: true  # External deployment

  kubernetes_config:
    cluster_name: hub

  external_services:
    prometheus:
      url: "https://observatorium-api-open-cluster-management-observability.apps-crc.testing/api/metrics/v1/default"

      auth:
        type: none
        cert_file: "secret:acm-observability-certs:tls.crt"
        key_file: "secret:acm-observability-certs:tls.key"

      thanos_proxy:
        enabled: true
        retention_period: "7d"
        scrape_interval: "30s"
```

**Required Kubernetes resources:**

```yaml
---
# mTLS client certificates (from ACM)
apiVersion: v1
kind: Secret
metadata:
  name: acm-observability-certs
  namespace: istio-system
type: Opaque
data:
  tls.crt: <base64-encoded-certificate>
  tls.key: <base64-encoded-key>

---
# Server CA trust (from ACM)
apiVersion: v1
kind: ConfigMap
metadata:
  name: kiali-cabundle
  namespace: istio-system
data:
  additional-ca-bundle.pem: |
    -----BEGIN CERTIFICATE-----
    <ACM Observability CA certificate>
    -----END CERTIFICATE-----
```

## Additional Resources

- [Red Hat ACM Observability Documentation](https://docs.redhat.com/en/documentation/red_hat_advanced_cluster_management_for_kubernetes/2.9/html/observability/)
- [Configuring User Workload Monitoring](https://docs.redhat.com/en/documentation/monitoring_stack_for_red_hat_openshift/4.20/html-single/configuring_user_workload_monitoring/)
- [OpenShift Service Mesh Observability](https://docs.redhat.com/en/documentation/red_hat_openshift_service_mesh/3.0/html-single/observability/)
- [Connecting Grafana to ACM Observability (Red Hat Blog)](https://www.redhat.com/en/blog/how-your-grafana-can-fetch-metrics-from-red-hat-advanced-cluster-management-observability-observatorium-and-thanos)
- [Kiali Multi-cluster Setup]({{< relref "../" >}})
- [External Kiali Deployment]({{< relref "./external" >}})
- [TLS Configuration]({{< relref "../p8s-jaeger-grafana/tls-configuration" >}})
