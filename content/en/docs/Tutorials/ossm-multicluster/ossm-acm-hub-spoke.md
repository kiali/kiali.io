---
title: "MultiCluster on OpenShift"
description: "Install ACM, import a spoke cluster, deploy OSSM 3 with ambient and sidecar demo apps, and configure Kiali to query aggregated metrics from ACM's central Thanos."
weight: 25
---

This guide sets up a two-cluster OpenShift environment from scratch where:

- The **hub cluster** runs Red Hat **Advanced Cluster Management (ACM)** for fleet management and centralized metrics collection (ACM Observability / Thanos)
- The **spoke cluster** is imported into ACM and runs OpenShift Service Mesh 3 (OSSM 3) with Kiali
- The spoke mesh has two demo application namespaces: one using Istio ambient mode (via the `ZTunnel` CR), one using Istio sidecar injection
- Kiali queries metrics via the ACM Observatorium API on the hub cluster (mTLS), giving it access to Istio metrics collected and forwarded by ACM from the spoke's User Workload Monitoring Prometheus

The result is a working Kiali installation that shows traffic graphs, metrics, and mesh topology across both the ambient-mode and sidecar-mode workloads running on the spoke.

---

## Prerequisites

Before starting, you need:

1. **Hub cluster** kubeconfig context named `ossm-kiali-hub` — every `oc` command in this guide that targets the hub passes `--context=ossm-kiali-hub`
2. **Spoke cluster** kubeconfig context named `ossm-kiali-spoke` — every `oc` command that targets the spoke passes `--context=ossm-kiali-spoke`
3. `oc` CLI installed and both contexts present in `~/.kube/config` (or `KUBECONFIG`). Verify with:
   ```bash
   oc --context=ossm-kiali-hub   whoami --show-server
   oc --context=ossm-kiali-spoke whoami --show-server
   ```
4. `openssl` installed locally (for generating Istio CA certificates)
5. Both clusters must be OpenShift 4.14 or later (required for OSSM 3)
6. Both clusters must have access to Red Hat OperatorHub (i.e., connected to the Red Hat operator catalog)
7. `jq` available locally (used in verification commands)

---

## Environment Setup

Set these variables in your shell before running any commands. They are referenced throughout this guide.

```bash
# Name for the spoke cluster in ACM (must be a valid Kubernetes resource name)
export SPOKE_CLUSTER_NAME="spoke"

# Istio version to install. Must be a version supported by the installed OSSM operator.
# After installing the operator (Phase 3.2), you can list supported versions with:
#   oc --context=ossm-kiali-spoke get crd istios.sailoperator.io \
#     -o jsonpath='{.spec.versions[0].schema.openAPIV3Schema.properties.spec.properties.version.enum}'
# Must also be >= 1.27.3 for ambient mode with the ZTunnel CR.
export ISTIO_VERSION="1.28.6"

# meshID - arbitrary identifier for this mesh
export MESH_ID="mesh1"

# MinIO credentials for in-cluster Thanos object storage (ACM Observability)
# These are only used inside the cluster — no external storage account is required
export MINIO_ACCESS_KEY="minio"
export MINIO_SECRET_KEY="minio123"
```

Verify both kubeconfig contexts are reachable:

```bash
oc --context=ossm-kiali-hub   whoami --show-server
oc --context=ossm-kiali-spoke whoami --show-server
```

---

## Phase 1: ACM on the Hub Cluster

### 1.1 Install ACM Operator

Detect the latest available ACM channel, then create the `open-cluster-management` namespace and install the operator via OLM. ACM channels follow the naming pattern `release-X.Y` (e.g. `release-2.17`):

```bash
ACM_CHANNEL=$(oc --context=ossm-kiali-hub get packagemanifest advanced-cluster-management \
  -n openshift-marketplace \
  -o jsonpath='{.status.channels[*].name}' | \
  tr ' ' '\n' | sort -V | tail -1)
echo "Using ACM channel: ${ACM_CHANNEL}"

oc --context=ossm-kiali-hub create namespace open-cluster-management 2>/dev/null || true

oc --context=ossm-kiali-hub apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
  name: open-cluster-management
  namespace: open-cluster-management
spec:
  targetNamespaces:
  - open-cluster-management
EOF

oc --context=ossm-kiali-hub apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: acm-operator-subscription
  namespace: open-cluster-management
spec:
  sourceNamespace: openshift-marketplace
  source: redhat-operators
  channel: ${ACM_CHANNEL}
  installPlanApproval: Automatic
  name: advanced-cluster-management
EOF
```

Wait for the ACM operator to install its CRDs. The `multiclusterhubs` CRD being `Established` confirms the operator is running and ready:

```bash
until oc --context=ossm-kiali-hub get crd \
  multiclusterhubs.operator.open-cluster-management.io &>/dev/null; do
  echo "Waiting for MCH CRD to appear..."
  sleep 5
done

oc --context=ossm-kiali-hub wait crd/multiclusterhubs.operator.open-cluster-management.io \
  --for=condition=Established \
  --timeout=300s
```

### 1.2 Create the MultiClusterHub

Wait for the operator pod to be fully ready before creating the MultiClusterHub. The MCH CR is validated by an admission webhook served by the operator — applying the CR before the webhook endpoint is ready causes an immediate rejection:

```bash
until oc --context=ossm-kiali-hub get pods \
  -l name=multiclusterhub-operator \
  -n open-cluster-management \
  --no-headers 2>/dev/null | grep -q .; do
  sleep 5
done

oc --context=ossm-kiali-hub wait pod \
  -l name=multiclusterhub-operator \
  -n open-cluster-management \
  --for=condition=Ready \
  --timeout=300s
```

```bash
oc --context=ossm-kiali-hub apply -f - <<'EOF'
apiVersion: operator.open-cluster-management.io/v1
kind: MultiClusterHub
metadata:
  name: multiclusterhub
  namespace: open-cluster-management
spec: {}
EOF
```

Wait for ACM to be fully ready. This typically takes 5–10 minutes on a fresh cluster:

```bash
echo "Waiting for MultiClusterHub to reach Running status..."
while true; do
  PHASE=$(oc --context=ossm-kiali-hub get mch multiclusterhub \
    -n open-cluster-management \
    -o jsonpath='{.status.phase}' 2>/dev/null)
  if [ "${PHASE}" = "Running" ]; then
    echo "MultiClusterHub is Running"
    break
  fi
  echo "  Current phase: ${PHASE} — waiting..."
  sleep 15
done
```

### 1.3 Verify ACM is Ready

```bash
oc --context=ossm-kiali-hub get multiclusterhub multiclusterhub -n open-cluster-management \
  -o jsonpath='{.status.phase}{"\n"}'
# Expected: Running
```

### 1.4 Enable ACM Observability (MultiClusterObservability)

ACM Observability collects metrics from all managed clusters and stores them in Thanos on the hub. Kiali will query these aggregated metrics via the Observatorium API.

ACM needs an S3-compatible object store as its Thanos backend. This guide deploys MinIO in-cluster so that no external storage account is required.

Create the observability namespace:

```bash
oc --context=ossm-kiali-hub create namespace open-cluster-management-observability 2>/dev/null || true
```

Deploy MinIO as a single-pod in-cluster object store:

```bash
oc --context=ossm-kiali-hub apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
  namespace: open-cluster-management-observability
spec:
  replicas: 1
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
      - name: minio
        image: quay.io/minio/minio:latest
        args:
        - server
        - /data
        - --console-address
        - ":9001"
        env:
        - name: MINIO_ROOT_USER
          value: "${MINIO_ACCESS_KEY}"
        - name: MINIO_ROOT_PASSWORD
          value: "${MINIO_SECRET_KEY}"
        ports:
        - containerPort: 9000
          name: api
        - containerPort: 9001
          name: console
        volumeMounts:
        - name: data
          mountPath: /data
        readinessProbe:
          httpGet:
            path: /minio/health/ready
            port: 9000
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /minio/health/live
            port: 9000
          initialDelaySeconds: 10
          periodSeconds: 5
      volumes:
      - name: data
        emptyDir: {}
---
apiVersion: v1
kind: Service
metadata:
  name: minio
  namespace: open-cluster-management-observability
spec:
  ports:
  - port: 9000
    name: api
    targetPort: 9000
  - port: 9001
    name: console
    targetPort: 9001
  selector:
    app: minio
EOF
```

Wait for MinIO to be ready, then create the Thanos bucket inside it:

```bash
oc --context=ossm-kiali-hub rollout status deployment/minio \
  -n open-cluster-management-observability \
  --timeout=120s

MINIO_POD=$(oc --context=ossm-kiali-hub get pods -n open-cluster-management-observability \
  -l app=minio -o jsonpath='{.items[0].metadata.name}')
oc --context=ossm-kiali-hub exec -n open-cluster-management-observability "${MINIO_POD}" -- mkdir -p /data/thanos
```

Create the Thanos object storage secret pointing at the in-cluster MinIO:

```bash
oc --context=ossm-kiali-hub apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: thanos-object-storage
  namespace: open-cluster-management-observability
type: Opaque
stringData:
  thanos.yaml: |
    type: s3
    config:
      bucket: thanos
      endpoint: minio.open-cluster-management-observability.svc:9000
      insecure: true
      access_key: ${MINIO_ACCESS_KEY}
      secret_key: ${MINIO_SECRET_KEY}
EOF
```

Create the `MultiClusterObservability` CR. This deploys Thanos, Observatorium, and the metrics collector add-on on all managed clusters. The retention is set to 14 days across all Thanos resolutions — this is both the Thanos minimum safe value (≥10d required for 5m→1h downsampling) and the value Kiali's `retention_period` is configured to match:

```bash
oc --context=ossm-kiali-hub apply -f - <<'EOF'
apiVersion: observability.open-cluster-management.io/v1beta2
kind: MultiClusterObservability
metadata:
  name: observability
spec:
  observabilityAddonSpec: {}
  storageConfig:
    metricObjectStorage:
      name: thanos-object-storage
      key: thanos.yaml
    alertmanagerStorageSize: 1Gi
    compactStorageSize: 10Gi
    receiveStorageSize: 10Gi
    ruleStorageSize: 1Gi
    storeStorageSize: 10Gi
  advanced:
    retentionConfig:
      retentionResolution1h: 14d
      retentionResolution5m: 14d
      retentionResolutionRaw: 14d
    alertmanager:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    compact:
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    grafana:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    observatoriumAPI:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    query:
      replicas: 1
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    queryFrontend:
      replicas: 1
      resources:
        requests:
          cpu: 50m
          memory: 64Mi
    queryFrontendMemcached:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    rbacQueryProxy:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
    receive:
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    rule:
      replicas: 1
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    store:
      replicas: 1
      resources:
        requests:
          cpu: 50m
          memory: 128Mi
    storeMemcached:
      replicas: 1
      resources:
        requests:
          cpu: 20m
          memory: 64Mi
EOF
```

Wait for ACM Observability to be ready. This can take 5–10 minutes as Thanos components start up:

```bash
echo "Waiting for MultiClusterObservability to be ready..."
while true; do
  READY=$(oc --context=ossm-kiali-hub get mco observability \
    -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || echo "Unknown")
  if [ "${READY}" = "True" ]; then
    echo "MultiClusterObservability is Ready"
    break
  fi
  echo "  Ready=${READY} — waiting..."
  sleep 15
done
```

Verify the Observatorium API route exists:

```bash
oc --context=ossm-kiali-hub get route observatorium-api \
  -n open-cluster-management-observability \
  -o jsonpath='{.spec.host}{"\n"}'
```

### 1.5 Create Istio Metrics Allowlist

ACM only forwards metrics that are explicitly allowlisted. Create this ConfigMap on the hub — ACM automatically distributes it to every managed cluster (including the spoke once imported) so that the spoke's UWM Prometheus metrics collector sends Istio metrics to hub Thanos:

```bash
oc --context=ossm-kiali-hub apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: observability-metrics-custom-allowlist
  namespace: open-cluster-management-observability
data:
  uwl_metrics_list.yaml: |
    names:
    # HTTP/gRPC metrics - from sidecars and waypoint proxies
    - istio_requests_total
    - istio_request_bytes_bucket
    - istio_request_bytes_count
    - istio_request_bytes_sum
    - istio_request_duration_milliseconds_bucket
    - istio_request_duration_milliseconds_count
    - istio_request_duration_milliseconds_sum
    - istio_request_messages_total
    - istio_response_bytes_bucket
    - istio_response_bytes_count
    - istio_response_bytes_sum
    - istio_response_messages_total
    # TCP metrics - from sidecars, waypoint proxies, and ztunnel
    - istio_tcp_connections_closed_total
    - istio_tcp_connections_opened_total
    - istio_tcp_received_bytes_total
    - istio_tcp_sent_bytes_total
    # Ztunnel-specific (Ambient L4 proxy)
    - workload_manager_active_proxy_count
    - istio_build
    # Pilot/control plane metrics
    - pilot_proxy_convergence_time_sum
    - pilot_proxy_convergence_time_count
    - pilot_services
    - pilot_xds
    - pilot_xds_pushes
    # Envoy proxy metrics
    - envoy_cluster_upstream_cx_active
    - envoy_cluster_upstream_rq_total
    - envoy_listener_downstream_cx_active
    - envoy_listener_http_downstream_rq
    - envoy_server_memory_allocated
    - envoy_server_memory_heap_size
    - envoy_server_uptime
    # Container/process metrics (control plane overview)
    - container_cpu_usage_seconds_total
    - container_memory_working_set_bytes
    - process_cpu_seconds_total
    - process_resident_memory_bytes
EOF
```

---

## Phase 2: Import the Spoke Cluster into ACM

### 2.1 Create the ManagedCluster Resource and Namespace

```bash
oc --context=ossm-kiali-hub create namespace "${SPOKE_CLUSTER_NAME}" 2>/dev/null || true

oc --context=ossm-kiali-hub apply -f - <<EOF
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: ${SPOKE_CLUSTER_NAME}
  labels:
    cloud: auto-detect
    vendor: auto-detect
spec:
  hubAcceptsClient: true
EOF
```

### 2.2 Create the Auto-Import Secret

The simplest way to import a spoke is to give ACM the spoke's kubeconfig directly. ACM's import controller detects the `auto-import-secret` and installs the klusterlet agent on the spoke automatically.

Extract the spoke's kubeconfig context into a standalone file:

```bash
oc config view --context=ossm-kiali-spoke --minify --flatten \
  > /tmp/spoke-kubeconfig.yaml

# Verify it connects to the spoke
oc --kubeconfig=/tmp/spoke-kubeconfig.yaml whoami --show-server
```

Create the auto-import secret on the hub:

```bash
oc --context=ossm-kiali-hub create secret generic auto-import-secret \
  -n "${SPOKE_CLUSTER_NAME}" \
  --from-file=kubeconfig=/tmp/spoke-kubeconfig.yaml
```

ACM consumes and deletes this secret automatically once the klusterlet is installed.

### 2.3 Create a KlusterletAddonConfig

This enables the standard ACM add-ons on the spoke:

```bash
oc --context=ossm-kiali-hub apply -f - <<EOF
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: ${SPOKE_CLUSTER_NAME}
  namespace: ${SPOKE_CLUSTER_NAME}
spec:
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
EOF
```

### 2.4 Wait for the Spoke to Join

```bash
echo "Waiting for ${SPOKE_CLUSTER_NAME} to join and become available..."
while true; do
  STATUS=$(oc --context=ossm-kiali-hub get managedcluster "${SPOKE_CLUSTER_NAME}" \
    -o jsonpath='{range .status.conditions[*]}{.type}={.status}{" "}{end}' 2>/dev/null)
  echo "  Status: ${STATUS}"
  if echo "${STATUS}" | grep -q "ManagedClusterJoined=True" && \
     echo "${STATUS}" | grep -q "ManagedClusterConditionAvailable=True"; then
    echo "${SPOKE_CLUSTER_NAME} is joined and available"
    break
  fi
  sleep 15
done
```

Clean up the temporary kubeconfig:

```bash
rm -f /tmp/spoke-kubeconfig.yaml
```

Verify both clusters are managed:

```bash
oc --context=ossm-kiali-hub get managedclusters
# Should show local-cluster and ${SPOKE_CLUSTER_NAME} both with JOINED=True, AVAILABLE=True
```

---

## Phase 3: OpenShift Service Mesh 3 (Spoke Cluster)

### 3.1 Enable User Workload Monitoring

Check if already enabled:

```bash
oc --context=ossm-kiali-spoke get configmap cluster-monitoring-config \
  -n openshift-monitoring \
  -o jsonpath='{.data.config\.yaml}' 2>/dev/null | \
  grep -q "enableUserWorkload: true" && \
  echo "Already enabled" || echo "Not enabled"
```

If not enabled:

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: cluster-monitoring-config
  namespace: openshift-monitoring
data:
  config.yaml: |
    enableUserWorkload: true
EOF
```

Wait for UWM pods to appear and become ready. The pods take a moment to be created after the ConfigMap is applied:

```bash
until oc --context=ossm-kiali-spoke get pods \
  -l app.kubernetes.io/name=prometheus \
  -n openshift-user-workload-monitoring \
  --no-headers 2>/dev/null | grep -q .; do
  sleep 5
done

oc --context=ossm-kiali-spoke wait pod \
  --for=condition=Ready \
  -l app.kubernetes.io/name=prometheus \
  -n openshift-user-workload-monitoring \
  --timeout=300s
```

### 3.2 Install OpenShift Service Mesh 3 Operator

Install the OSSM 3 operator cluster-wide via OLM. The operator manages Istio control planes across all namespaces:

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-service-mesh-operator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: servicemeshoperator3
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

Wait for the operator pod to appear and become ready:

```bash
until oc --context=ossm-kiali-spoke get pods \
  -l app.kubernetes.io/created-by=servicemeshoperator3 \
  -n openshift-operators \
  --no-headers 2>/dev/null | grep -q .; do
  sleep 5
done

oc --context=ossm-kiali-spoke wait pod \
  --for=condition=Ready \
  -l app.kubernetes.io/created-by=servicemeshoperator3 \
  -n openshift-operators \
  --timeout=300s
```

### 3.3 Create Required Namespaces

The `ztunnel` namespace must have the `istio-discovery: enabled` label so that istiod discovers it and distributes the `istio-ca-root-cert` ConfigMap there — without which ztunnel pods fail to start:

```bash
oc --context=ossm-kiali-spoke create namespace istio-system 2>/dev/null || true
oc --context=ossm-kiali-spoke create namespace istio-cni 2>/dev/null || true
oc --context=ossm-kiali-spoke create namespace ztunnel 2>/dev/null || true

oc --context=ossm-kiali-spoke label namespace ztunnel istio-discovery=enabled
```

### 3.4 Generate and Apply Istio CA Certificates

A self-signed Istio root CA is required for mTLS within the mesh:

```bash
mkdir -p /tmp/istio-certs && cd /tmp/istio-certs

# Root CA key and certificate
openssl genrsa -out root-key.pem 4096

cat > root-ca.conf <<'CONF'
encrypt_key = no
prompt = no
utf8 = yes
default_md = sha256
default_bits = 4096
req_extensions = req_ext
x509_extensions = req_ext
distinguished_name = req_dn
[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints = critical, CA:true
keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment, keyCertSign
[ req_dn ]
O = Istio
CN = Root CA
CONF

openssl req -sha256 -new \
  -key root-key.pem \
  -config root-ca.conf \
  -out root-cert.csr

openssl x509 -req -sha256 -days 3650 \
  -signkey root-key.pem \
  -extensions req_ext -extfile root-ca.conf \
  -in root-cert.csr \
  -out root-cert.pem

# Intermediate CA for the spoke
cat > intermediate.conf <<'CONF'
[ req ]
encrypt_key = no
prompt = no
utf8 = yes
default_md = sha256
default_bits = 4096
req_extensions = req_ext
x509_extensions = req_ext
distinguished_name = req_dn
[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints = critical, CA:true, pathlen:0
keyUsage = critical, digitalSignature, nonRepudiation, keyEncipherment, keyCertSign
subjectAltName=@san
[ san ]
DNS.1 = istiod.istio-system.svc
[ req_dn ]
O = Istio
CN = Intermediate CA
L = spoke
CONF

openssl genrsa -out ca-key.pem 4096

openssl req -new \
  -config intermediate.conf \
  -key ca-key.pem \
  -out cluster-ca.csr

openssl x509 -req -sha256 -days 3650 \
  -CA root-cert.pem \
  -CAkey root-key.pem -CAcreateserial \
  -extensions req_ext -extfile intermediate.conf \
  -in cluster-ca.csr \
  -out ca-cert.pem

cat ca-cert.pem root-cert.pem > cert-chain.pem

cd -
```

Load the CA certificates into the `istio-system` namespace:

```bash
oc --context=ossm-kiali-spoke get secret cacerts -n istio-system &>/dev/null || \
oc --context=ossm-kiali-spoke create secret generic cacerts -n istio-system \
  --from-file=ca-cert.pem=/tmp/istio-certs/ca-cert.pem \
  --from-file=ca-key.pem=/tmp/istio-certs/ca-key.pem \
  --from-file=root-cert.pem=/tmp/istio-certs/root-cert.pem \
  --from-file=cert-chain.pem=/tmp/istio-certs/cert-chain.pem
```

### 3.5 Install IstioCNI

IstioCNI is required on OpenShift for both sidecar and ambient modes. It handles pod network setup:

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: IstioCNI
metadata:
  name: default
spec:
  namespace: istio-cni
  profile: openshift-ambient
  version: v${ISTIO_VERSION}
EOF
```

Wait for IstioCNI to be ready:

```bash
oc --context=ossm-kiali-spoke wait istiocni default \
  --for=condition=Ready \
  --timeout=300s
```

### 3.6 Install the Istio Control Plane

The Istio CR uses the `openshift-ambient` profile and `discoverySelectors` to scope which namespaces Istio manages. The `trustedZtunnelNamespace` field tells istiod where the `ZTunnel` CR will deploy ztunnel:

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: Istio
metadata:
  name: default
spec:
  namespace: istio-system
  profile: openshift-ambient
  updateStrategy:
    type: InPlace
  values:
    global:
      meshID: ${MESH_ID}
    meshConfig:
      discoverySelectors:
      - matchLabels:
          istio-discovery: enabled
    pilot:
      trustedZtunnelNamespace: ztunnel
  version: v${ISTIO_VERSION}
EOF
```

Wait for the Istio control plane to be ready:

```bash
oc --context=ossm-kiali-spoke wait istio default \
  --for=condition=Ready \
  --timeout=300s
```

### 3.7 Install ZTunnel

ZTunnel is the Ambient mode per-node L4 proxy. The dedicated `ZTunnel` CR is the recommended way to manage ztunnel in OSSM 3 — it gives you independent lifecycle control and correctly sets the cluster identity (`clusterName`) directly on the ztunnel DaemonSet.

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: ZTunnel
metadata:
  name: default
spec:
  namespace: ztunnel
  version: v${ISTIO_VERSION}
EOF
```

Wait for the ZTunnel DaemonSet to be ready:

```bash
oc --context=ossm-kiali-spoke wait ztunnel default \
  --for=condition=Ready \
  --timeout=300s

# Confirm ztunnel pods are running on all nodes
oc --context=ossm-kiali-spoke get pods -n ztunnel -l app=ztunnel
```

### 3.8 Configure Istio Metrics Collection

The metrics pipeline for Kiali works in two hops: UWM Prometheus on the spoke scrapes Istio metrics every 30 seconds, then ACM's metrics collector forwards them to hub Thanos every 5 minutes (the default `interval` set in the MCO CR). Kiali queries the hub Thanos via the Observatorium API.

Create the ServiceMonitors and PodMonitors that tell UWM Prometheus what to scrape.

**ServiceMonitor for istiod** (control plane metrics):

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
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
EOF
```

**PodMonitor for ztunnel** (L4 TCP metrics for ambient-mode traffic):

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: ztunnel-monitor
  namespace: ztunnel
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
      replacement: '[\$2]:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '\$2:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "${MESH_ID}"
      targetLabel: mesh_id
EOF
```

---

## Phase 4: Kiali — Metrics Certs (Hub) then Install (Spoke)

Kiali on the spoke queries metrics from the hub's ACM Observatorium API using mTLS. This phase has two parts: first extract the necessary certificates from the hub, then install and configure Kiali on the spoke.

### 4.1 Extract ACM Observatorium Certificates (Hub Cluster)

Get the Observatorium API URL — you will need this for the Kiali CR:

```bash
export OBSERVATORIUM_URL=$(oc --context=ossm-kiali-hub get route observatorium-api \
  -n open-cluster-management-observability \
  -o jsonpath='https://{.spec.host}/api/metrics/v1/default')
echo "Observatorium URL: ${OBSERVATORIUM_URL}"
```

Extract the client certificate and key. ACM automatically creates long-lived (1 year) client certificates in the `observability-grafana-certs` secret:

```bash
oc --context=ossm-kiali-hub get secret observability-grafana-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.tls\.crt}' | base64 -d > /tmp/obs-tls.crt

oc --context=ossm-kiali-hub get secret observability-grafana-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.tls\.key}' | base64 -d > /tmp/obs-tls.key
```

Identify which CA signed the Observatorium API's server certificate, then extract it:

```bash
HOST=$(oc --context=ossm-kiali-hub get route observatorium-api \
  -n open-cluster-management-observability \
  -o jsonpath='{.spec.host}')

echo | openssl s_client \
  -connect "${HOST}:443" \
  -servername "${HOST}" \
  -showcerts 2>/dev/null | openssl x509 -noout -issuer
```

If the issuer CN is `observability-server-ca-certificate`:

```bash
oc --context=ossm-kiali-hub get secret observability-server-ca-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/obs-server-ca.crt
```

If the issuer CN is `observability-client-ca-certificate`:

```bash
oc --context=ossm-kiali-hub get secret observability-client-ca-certs \
  -n open-cluster-management-observability \
  -o jsonpath='{.data.ca\.crt}' | base64 -d > /tmp/obs-server-ca.crt
```

### 4.2 Create Cert Resources on the Spoke

Load the extracted certificates into the `istio-system` namespace where Kiali runs on the spoke:

Create the mTLS client certificate secret:

```bash
oc --context=ossm-kiali-spoke create secret generic acm-observability-certs \
  -n istio-system \
  --from-file=tls.crt=/tmp/obs-tls.crt \
  --from-file=tls.key=/tmp/obs-tls.key
```

Create the CA bundle ConfigMap so Kiali trusts the Observatorium API's server certificate:

```bash
oc --context=ossm-kiali-spoke create configmap kiali-cabundle \
  -n istio-system \
  --from-file=additional-ca-bundle.pem=/tmp/obs-server-ca.crt
```

### 4.3 Install the Kiali Operator (Spoke)

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

Wait for the Kiali operator pod to appear and become ready:

```bash
until oc --context=ossm-kiali-spoke get pods \
  -l app.kubernetes.io/name=kiali-operator \
  -n openshift-operators \
  --no-headers 2>/dev/null | grep -q .; do
  sleep 5
done

oc --context=ossm-kiali-spoke wait pod \
  --for=condition=Ready \
  -l app.kubernetes.io/name=kiali-operator \
  -n openshift-operators \
  --timeout=300s
```

### 4.4 Install Kiali

Kiali is deployed in `istio-system` and queries metrics from the hub's Observatorium API using the mTLS certificates created above. The `openshift` auth strategy integrates Kiali with OpenShift OAuth so users log in with their OpenShift credentials.

The `scrape_interval: "5m"` matches the default ACM metrics collection interval. The `retention_period: "14d"` matches the retention configured in the MCO CR above:

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: istio-system
spec:
  auth:
    strategy: openshift
  deployment:
    cluster_wide_access: true
    instance_name: kiali
    namespace: istio-system
    replicas: 1
  external_services:
    grafana:
      enabled: false
    prometheus:
      auth:
        cert_file: secret:acm-observability-certs:tls.crt
        key_file: secret:acm-observability-certs:tls.key
        type: none
        use_kiali_token: false
      thanos_proxy:
        enabled: true
        retention_period: "14d"
        scrape_interval: "5m"
      url: "${OBSERVATORIUM_URL}"
  version: default
EOF
```

Wait for the Kiali CR to reconcile successfully:

```bash
oc --context=ossm-kiali-spoke wait kiali kiali \
  -n istio-system \
  --for=condition=Successful \
  --timeout=300s
```

Wait for the Kiali deployment to roll out:

```bash
oc --context=ossm-kiali-spoke rollout status deployment/kiali -n istio-system
```

### 4.5 Install the OpenShift Service Mesh Console Plugin

The `OSSMConsole` CR instructs the Kiali Operator to register a console plugin that adds the **Service Mesh** menu to the OpenShift console, providing an integrated Kiali view within the OCP UI:

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
apiVersion: kiali.io/v1alpha1
kind: OSSMConsole
metadata:
  name: ossmconsole
  namespace: istio-system
spec: {}
EOF

until oc --context=ossm-kiali-spoke get ossmconsole ossmconsole \
  -n istio-system \
  -o jsonpath='{.status.conditions[?(@.type=="Successful")].status}' 2>/dev/null | grep -q "True"; do
  echo "Waiting for OSSMConsole reconciliation..."
  sleep 10
done
echo "OSSMConsole ready"
```

---

## Phase 5: Demo Applications (Spoke Cluster)

Two demo namespaces are created: one in ambient mode (ztunnel handles L4), one with sidecar injection (envoy proxy per pod). Both namespaces are labeled `istio-discovery: enabled` so that istiod's `discoverySelectors` includes them.

### 5.1 Ambient Demo App — Helloworld

This namespace uses ambient mode. Ztunnel provides L4 TCP mTLS automatically — no sidecar containers are injected. The demo deploys the standard Istio `helloworld` application in two versions (`v1` and `v2`), which allows Kiali to show version-differentiated traffic distribution in the topology graph.

Create the `ambient-demo` namespace with the ambient mode and discovery labels:

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
apiVersion: v1
kind: Namespace
metadata:
  name: ambient-demo
  labels:
    istio.io/dataplane-mode: ambient
    istio-discovery: enabled
EOF
```

Deploy the `helloworld` service and both versions using the OSSM sample manifests:

```bash
ISTIO_MINOR=$(echo "${ISTIO_VERSION}" | cut -d. -f1-2)

# Download the helloworld manifest once to avoid GitHub rate limits on repeated requests
curl -sL "https://raw.githubusercontent.com/openshift-service-mesh/istio/release-${ISTIO_MINOR}/samples/helloworld/helloworld.yaml" \
  -o /tmp/helloworld.yaml

oc --context=ossm-kiali-spoke apply -n ambient-demo -l service=helloworld -f /tmp/helloworld.yaml
oc --context=ossm-kiali-spoke apply -n ambient-demo -l version=v1 -f /tmp/helloworld.yaml
oc --context=ossm-kiali-spoke apply -n ambient-demo -l version=v2 -f /tmp/helloworld.yaml
rm -f /tmp/helloworld.yaml
```

Wait for both versions to be ready:

```bash
oc --context=ossm-kiali-spoke wait deployment/helloworld-v1 \
  -n ambient-demo --for=condition=Available --timeout=120s
oc --context=ossm-kiali-spoke wait deployment/helloworld-v2 \
  -n ambient-demo --for=condition=Available --timeout=120s
```

Deploy a traffic generator that continuously calls the `helloworld` service. Requests are round-robined between v1 and v2 by kube-proxy, which Kiali will show as weighted traffic edges to each version:

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: traffic-gen
  namespace: ambient-demo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: traffic-gen
  template:
    metadata:
      labels:
        app: traffic-gen
    spec:
      containers:
      - name: client
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            curl -s --max-time 5 http://helloworld:5000/hello || echo "failed"
            sleep 2
          done
EOF
```

Verify all pods are running. No pod should have more than one container — ambient mode adds no sidecars:

```bash
oc --context=ossm-kiali-spoke get pods -n ambient-demo
# Each pod should show 1/1 READY (no istio-proxy sidecar)
```

### 5.1.1 Deploy a Waypoint for L7 Metrics

Without a waypoint, ztunnel only processes L4 traffic. Kiali will show traffic edges and TCP-level metrics (`istio_tcp_*`) but **no HTTP details** — no response codes, no latency, no request rates. A waypoint proxy is an Envoy-based L7 proxy that intercepts traffic inside the ambient mesh and produces the full set of HTTP metrics Kiali needs for its traffic graph and workload dashboards.

Deploy a waypoint for the `ambient-demo` namespace. The `istio.io/waypoint-for: service` label tells ztunnel that this waypoint handles traffic addressed to Kubernetes Services (not pod IPs). Valid values are `service`, `workload`, `all`, and `none` — `service` is the default and the right choice here since `traffic-gen` calls `helloworld` via its Service VIP:

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: waypoint
  namespace: ambient-demo
  labels:
    istio.io/waypoint-for: service
spec:
  gatewayClassName: istio-waypoint
  listeners:
  - name: mesh
    port: 15008
    protocol: HBONE
EOF
```

Wait for the waypoint to be programmed, then enroll the namespace — this label tells ztunnel to redirect traffic to services in `ambient-demo` through the waypoint for L7 processing:

```bash
oc --context=ossm-kiali-spoke wait gateway/waypoint \
  -n ambient-demo \
  --for=condition=Programmed=True \
  --timeout=120s

oc --context=ossm-kiali-spoke label namespace ambient-demo \
  istio.io/use-waypoint=waypoint
```

Verify the Gateway and namespace are configured correctly:

```bash
# Confirm the Gateway has istio.io/waypoint-for: service
oc --context=ossm-kiali-spoke get gateway waypoint -n ambient-demo \
  -o jsonpath='waypoint-for={.metadata.labels.istio\.io/waypoint-for}{"\n"}'
# Expected: waypoint-for=service

# Confirm the namespace is enrolled
oc --context=ossm-kiali-spoke get namespace ambient-demo \
  -o jsonpath='use-waypoint={.metadata.labels.istio\.io/use-waypoint}{"\n"}'
# Expected: use-waypoint=waypoint

# Confirm the waypoint pod is running
oc --context=ossm-kiali-spoke get pods -n ambient-demo \
  -l gateway.networking.k8s.io/gateway-name=waypoint
```

After the next ACM collection cycle (~5 minutes), confirm the waypoint is producing L7 HTTP metrics by querying hub Thanos for `reporter=waypoint`:

```bash
oc --context=ossm-kiali-hub get --raw \
  "/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/api/v1/query?query=istio_requests_total%7Breporter%3D%22waypoint%22%7D" \
  | jq '.data.result | length'
# Returns the count of waypoint reporter timeseries — must be > 0
```

{{% alert color="info" %}}
**Double edges in Kiali**: Once the waypoint is active, Kiali will show **two** edges between workloads in `ambient-demo` — one from ztunnel (TCP/L4 metrics) and one from the waypoint (HTTP/L7 metrics). This is expected. Use the **Traffic** menu in the Kiali graph toolbar and select **Waypoint** to filter to L7-only edges, or select **ZTunnel** to see L4-only edges.
{{% /alert %}}

Create a PodMonitor so UWM Prometheus scrapes the waypoint's Envoy metrics:

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: istio-proxies-monitor
  namespace: ambient-demo
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
      replacement: '[\$2]:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '\$2:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "${MESH_ID}"
      targetLabel: mesh_id
EOF
```

### 5.2 Sidecar Demo App — Bookinfo

The [Bookinfo application](https://istio.io/latest/docs/examples/bookinfo/) is the standard Istio demo app. It consists of four microservices (`productpage`, `details`, `ratings`, `reviews`) connected via Envoy sidecar proxies, producing rich L7 HTTP metrics that Kiali uses for its traffic graph and workload views.

Create the `bookinfo` namespace and label it for sidecar injection and Istio discovery:

```bash
oc --context=ossm-kiali-spoke create namespace bookinfo 2>/dev/null || true

oc --context=ossm-kiali-spoke label namespace bookinfo \
  istio-injection=enabled \
  istio-discovery=enabled
```

Deploy the Bookinfo application using the OSSM-maintained sample manifests. The Istio version in the URL should match your installed Istio version:

```bash
ISTIO_MINOR=$(echo "${ISTIO_VERSION}" | cut -d. -f1-2)

oc --context=ossm-kiali-spoke apply -n bookinfo \
  -f "https://raw.githubusercontent.com/openshift-service-mesh/istio/release-${ISTIO_MINOR}/samples/bookinfo/platform/kube/bookinfo.yaml"
```

Wait for all Bookinfo pods to be ready. Each pod should show `2/2` containers (`app` + `istio-proxy` sidecar):

```bash
oc --context=ossm-kiali-spoke wait pods \
  --for=condition=Ready \
  --all \
  -n bookinfo \
  --timeout=180s

oc --context=ossm-kiali-spoke get pods -n bookinfo
```

Verify the app is reachable inside the cluster:

```bash
oc --context=ossm-kiali-spoke exec \
  "$(oc --context=ossm-kiali-spoke get pod -l app=ratings -n bookinfo \
     -o jsonpath='{.items[0].metadata.name}')" \
  -c ratings -n bookinfo -- \
  curl -sS productpage:9080/productpage | grep -o "<title>.*</title>"
# Expected: <title>Simple Bookstore App</title>
```

Expose the Bookinfo productpage externally using Gateway API:

```bash
oc --context=ossm-kiali-spoke apply -n bookinfo \
  -f "https://raw.githubusercontent.com/openshift-service-mesh/istio/release-${ISTIO_MINOR}/samples/bookinfo/gateway-api/bookinfo-gateway.yaml"

oc --context=ossm-kiali-spoke wait \
  --for=condition=Programmed \
  gateway/bookinfo-gateway \
  -n bookinfo \
  --timeout=120s

export BOOKINFO_URL="http://$(oc --context=ossm-kiali-spoke get gateway bookinfo-gateway \
  -n bookinfo \
  -o jsonpath='{.status.addresses[0].value}'):$(oc --context=ossm-kiali-spoke get gateway bookinfo-gateway \
  -n bookinfo \
  -o jsonpath='{.spec.listeners[?(@.name=="http")].port}')/productpage"
echo "Bookinfo URL: ${BOOKINFO_URL}"
```

Open `${BOOKINFO_URL}` in a browser to verify the app. To generate continuous traffic for Kiali's graph without manual browser interaction, deploy a traffic generator:

```bash
oc --context=ossm-kiali-spoke apply -f - <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: traffic-gen
  namespace: bookinfo
spec:
  replicas: 1
  selector:
    matchLabels:
      app: traffic-gen
  template:
    metadata:
      labels:
        app: traffic-gen
    spec:
      containers:
      - name: client
        image: registry.access.redhat.com/ubi9/ubi-minimal:latest
        command: ["/bin/sh", "-c"]
        args:
        - |
          while true; do
            curl -s -o /dev/null -w "%{http_code}\n" --max-time 5 http://productpage:9080/productpage || echo "failed"
            sleep 2
          done
EOF
```

### 5.3 PodMonitor for the Bookinfo Namespace

Sidecar (Envoy proxy) metrics must be scraped by UWM Prometheus. OpenShift UWM does not support `namespaceSelector` in PodMonitors, so a PodMonitor must be created in each namespace that has sidecar-injected pods:

```bash
oc --context=ossm-kiali-spoke apply -f - <<EOF
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: istio-proxies-monitor
  namespace: bookinfo
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
      replacement: '[\$2]:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - action: replace
      regex: (\d+);((([0-9]+?)(\.|$)){4})
      replacement: '\$2:\$1'
      sourceLabels: ["__meta_kubernetes_pod_annotation_prometheus_io_port","__meta_kubernetes_pod_ip"]
      targetLabel: "__address__"
    - sourceLabels: ["__meta_kubernetes_pod_label_app_kubernetes_io_name","__meta_kubernetes_pod_label_app"]
      separator: ";"
      targetLabel: "app"
      action: replace
      regex: "(.+);.*|.*;(.+)"
      replacement: "\${1}\${2}"
    - sourceLabels: ["__meta_kubernetes_pod_label_app_kubernetes_io_version","__meta_kubernetes_pod_label_version"]
      separator: ";"
      targetLabel: "version"
      action: replace
      regex: "(.+);.*|.*;(.+)"
      replacement: "\${1}\${2}"
    - sourceLabels: ["__meta_kubernetes_namespace"]
      action: replace
      targetLabel: namespace
    - action: replace
      replacement: "${MESH_ID}"
      targetLabel: mesh_id
EOF
```

---

## Phase 6: Verification

{{% alert color="info" %}}
**Before running the metrics checks (6.3) and checking the Kiali traffic graph (6.4):** ACM collects metrics from the spoke's UWM Prometheus and forwards them to hub Thanos every 5 minutes (the default collection interval). After deploying the demo apps, wait at least **10 minutes** before expecting metrics to appear — 5 minutes for the first ACM collection cycle, plus another 5 minutes for a second cycle so that Kiali's `rate()` calculations have two data points. The mesh health checks (6.1) and traffic flow checks (6.2) can be run immediately.
{{% /alert %}}

### 6.1 Verify Mesh Components

Check that all Istio and ztunnel components are healthy on the spoke:

```bash
oc --context=ossm-kiali-spoke get istio default
# Should show Ready=True

oc --context=ossm-kiali-spoke get istiocni default
# Should show Ready=True

oc --context=ossm-kiali-spoke get ztunnel default
# Should show Ready=True

oc --context=ossm-kiali-spoke get pods -n istio-system
# istiod pod should be Running

oc --context=ossm-kiali-spoke get pods -n istio-cni
# istio-cni-node pods should be Running on all nodes

oc --context=ossm-kiali-spoke get pods -n ztunnel
# ztunnel pods should be Running on all nodes
```

### 6.2 Verify Traffic is Flowing

Check that traffic-gen pods are successfully sending requests:

```bash
# Ambient demo (expect "Hello version: v1" or "Hello version: v2" responses)
oc --context=ossm-kiali-spoke logs -n ambient-demo deployment/traffic-gen --tail=5

# Sidecar demo (expect HTTP 200 status codes)
oc --context=ossm-kiali-spoke logs -n bookinfo deployment/traffic-gen --tail=5
```

### 6.3 Verify Istio Metrics Are in Hub Thanos

The metrics pipeline has two hops (spoke UWM → hub Thanos), so allow **at least 10 minutes** after the demo apps start generating traffic before checking. Run these queries on the **hub cluster**:

```bash
# List all Istio metric names present in hub Thanos
oc --context=ossm-kiali-hub get --raw \
  "/api/v1/namespaces/open-cluster-management-observability/services/http:observability-thanos-query-frontend:9090/proxy/api/v1/label/__name__/values" \
  | jq -r '.data[]' | grep "^istio_"
```

You should see `istio_tcp_sent_bytes_total`, `istio_tcp_connections_opened_total` (from ztunnel for the ambient namespace) and `istio_requests_total` (from sidecar proxies for the sidecar namespace).

If no Istio metrics appear after 15 minutes, check that the PodMonitors exist and UWM pods are running:

```bash
# Confirm PodMonitors are in place
oc --context=ossm-kiali-spoke get podmonitor,servicemonitor -A | grep -E "ztunnel|istiod|bookinfo|ambient"

# Confirm UWM Prometheus pods are running
oc --context=ossm-kiali-spoke get pods -n openshift-user-workload-monitoring

# Confirm ACM metrics collector is running on the spoke
oc --context=ossm-kiali-spoke get pods -n open-cluster-management-addon-observability
```

### 6.4 Verify ACM Can See the Spoke

On the hub cluster, confirm the spoke cluster is healthy and visible to ACM:

```bash
oc --context=ossm-kiali-hub get managedcluster "${SPOKE_CLUSTER_NAME}"
oc --context=ossm-kiali-hub get managedclusteraddons -n "${SPOKE_CLUSTER_NAME}"
```

### 6.5 Access the Kiali UI

Kiali is accessible in two ways:

**Standalone UI** — the Kiali route URL:

```bash
oc --context=ossm-kiali-spoke get route kiali -n istio-system -o jsonpath='https://{.spec.host}{"\n"}'
```

**OpenShift console** — the **Service Mesh** item in the left-hand menu found at the `spoke` OpenShift console URL:

```bash
oc --context=ossm-kiali-spoke get route console -n openshift-console \
  -o jsonpath='https://{.spec.host}{"\n"}'
```

Open either URL and log in with your OpenShift credentials. You should see:

1. **Overview** page: both `ambient-demo` and `bookinfo` namespaces listed. The `ambient-demo` namespace shows an Ambient badge indicating ztunnel is active.
2. **Traffic Graph**: navigate to the Traffic Graph page and select `ambient-demo` and `bookinfo` from the namespace dropdown at the top. Traffic edges should appear for each namespace:
   - `ambient-demo`: `traffic-gen` → `helloworld` split to `helloworld-v1` and `helloworld-v2`. With the waypoint active you may see **double edges** (ztunnel TCP + waypoint HTTP). To control what is shown, open the **Traffic** menu in the graph toolbar — under the **Ambient** section you will find `Waypoint`, `Ztunnel`, and `Total` toggles. Enable **Waypoint** to see L7 HTTP edges; enable **Ztunnel** to see L4 TCP edges. If only TCP edges appear, the waypoint's L7 metrics may need another ACM collection cycle (~5 minutes) before appearing.
   - `bookinfo`: full L7 graph across `productpage` → `details`, `reviews` → `ratings` with HTTP response codes and latency
3. **Mesh page**: navigate to the Mesh page to see the overall mesh topology — the control plane, ztunnel, and the `istio-system` namespace should all be represented in the mesh graph.

{{% alert color="info" %}}
For Kiali to show the Ambient badge and ztunnel details it needs access to the `ztunnel` namespace. The `cluster_wide_access: true` setting in the Kiali CR (configured in Phase 4) covers this automatically.
{{% /alert %}}

Because Kiali queries ACM's hub Thanos (not the spoke's local Prometheus), there is an inherent **5–10 minute latency** before new traffic appears in the graph. This is the ACM metrics collection interval. After the initial warm-up (~10 minutes), the graph updates continuously on each collection cycle. The most recent data in the graph will always be approximately one collection interval old.

---

## Cleanup

To remove OSSM, Kiali, and demo apps from the spoke:

```bash
oc --context=ossm-kiali-spoke delete gateway waypoint -n ambient-demo
oc --context=ossm-kiali-spoke delete namespace ambient-demo bookinfo
oc --context=ossm-kiali-spoke delete ossmconsole ossmconsole -n istio-system
oc --context=ossm-kiali-spoke delete kiali kiali -n istio-system
oc --context=ossm-kiali-spoke delete secret acm-observability-certs -n istio-system
oc --context=ossm-kiali-spoke delete configmap kiali-cabundle -n istio-system
oc --context=ossm-kiali-spoke delete ztunnel default
oc --context=ossm-kiali-spoke delete istio default
oc --context=ossm-kiali-spoke delete istiocni default
oc --context=ossm-kiali-spoke delete namespace ztunnel istio-system istio-cni
```

To remove ACM Observability from the hub. Delete the MCO first and wait for it to be gone before removing MinIO, so the MCO doesn't try to reconnect to its backing store during deletion:

```bash
oc --context=ossm-kiali-hub delete mco observability
oc --context=ossm-kiali-hub wait mco observability --for=delete --timeout=120s 2>/dev/null || true
oc --context=ossm-kiali-hub delete configmap observability-metrics-custom-allowlist \
  -n open-cluster-management-observability
oc --context=ossm-kiali-hub delete deployment minio -n open-cluster-management-observability
oc --context=ossm-kiali-hub delete service minio -n open-cluster-management-observability
oc --context=ossm-kiali-hub delete secret thanos-object-storage -n open-cluster-management-observability
oc --context=ossm-kiali-hub delete namespace open-cluster-management-observability
```

To detach the spoke from ACM (on the hub). ACM will cascade-delete the `${SPOKE_CLUSTER_NAME}` namespace on the hub automatically:

```bash
oc --context=ossm-kiali-hub delete managedcluster "${SPOKE_CLUSTER_NAME}"
```

Remove ACM from the hub cluster. Deleting the MultiClusterHub cascades and removes all ACM components — this takes 5–15 minutes:

```bash
oc --context=ossm-kiali-hub delete multiclusterhub multiclusterhub \
  -n open-cluster-management

echo "Waiting for MultiClusterHub deletion (5–15 minutes)..."
while oc --context=ossm-kiali-hub get multiclusterhub multiclusterhub \
  -n open-cluster-management &>/dev/null 2>&1; do
  echo "  Still deleting..."
  sleep 15
done
echo "MultiClusterHub deleted"

oc --context=ossm-kiali-hub delete subscription acm-operator-subscription \
  -n open-cluster-management 2>/dev/null || true
oc --context=ossm-kiali-hub delete namespace open-cluster-management --timeout=300s
```

After the spoke's ManagedCluster is deleted, ACM removes the klusterlet agent namespaces from the spoke automatically. Remove any that remain — these are the ACM klusterlet agent (connects to the hub) and its addon controllers:

```bash
oc --context=ossm-kiali-spoke delete namespace \
  open-cluster-management-agent \
  open-cluster-management-agent-addon \
  2>/dev/null || true
```

**Optional — fully remove the OSSM and Kiali operators from the spoke** (skip if other workloads use these operators). You must remove the Subscription, CSV, and CRDs to get a clean uninstall:

```bash
# Remove Subscriptions
oc --context=ossm-kiali-spoke delete subscription kiali-ossm openshift-service-mesh-operator \
  -n openshift-operators

# Remove CSVs (this deletes the operator deployments)
oc --context=ossm-kiali-spoke delete csv \
  -l operators.coreos.com/kiali-ossm.openshift-operators \
  -n openshift-operators
oc --context=ossm-kiali-spoke delete csv \
  -l operators.coreos.com/servicemeshoperator3.openshift-operators \
  -n openshift-operators

# Remove all CRDs installed by the OSSM and Kiali operators
for suffix in sailoperator.io istio.io kiali.io; do
  CRDS=$(oc --context=ossm-kiali-spoke get crd \
    --no-headers -o custom-columns=NAME:.metadata.name 2>/dev/null \
    | grep "\.${suffix}$")
  if [ -n "${CRDS}" ]; then
    echo "${CRDS}" | xargs oc --context=ossm-kiali-spoke delete crd 2>/dev/null || true
  fi
done
```

---

## Notes and Considerations

### 1. Use the ZTunnel CR to Manage Ztunnel

In OSSM 3, the recommended way to deploy ztunnel is via the dedicated `ZTunnel` CR rather than having the `Istio` CR manage it. The `ZTunnel` CR gives independent lifecycle control over the ztunnel DaemonSet and is where cluster identity (`spec.values.ztunnel.multiCluster.clusterName`) and network identity (`spec.values.ztunnel.network`) are set directly on ztunnel. Do **not** set `global.multiCluster.clusterName` in the `Istio` CR when using the `ZTunnel` CR — set it in the `ZTunnel` CR instead.

### 2. discoverySelectors Require Explicit Namespace Labeling

If the `Istio` CR uses `meshConfig.discoverySelectors`, every namespace that should be part of the mesh — including app namespaces and the ztunnel namespace — must carry the matching label (e.g., `istio-discovery: enabled`). Without it, istiod ignores the namespace: sidecar injection won't work and ztunnel won't route ambient traffic.

The `ztunnel` namespace **must** be labeled with `istio-discovery: enabled`. Even though it is referenced via `pilot.trustedZtunnelNamespace`, istiod still needs to discover the namespace via `discoverySelectors` in order to distribute the `istio-ca-root-cert` ConfigMap there — without which ztunnel pods fail to start with a `MountVolume.SetUp failed` error.

### 3. Sidecar PodMonitors Must Be Per-Namespace

OpenShift's User Workload Monitoring does not honor `namespaceSelector` in `PodMonitor` resources. A separate `PodMonitor` named `istio-proxies-monitor` must be created in **every** namespace that has sidecar-injected pods. Forgetting this is the most common reason Kiali shows an empty traffic graph for sidecar-mode namespaces.

### 4. Restricting Kiali's Visible Namespaces with Discovery Selectors

By default, the Kiali CR in this guide uses `cluster_wide_access: true`, which gives Kiali access to — and makes visible — every namespace on the cluster. In an environment with many namespaces this can be noisy and affect performance.

Kiali has its own `deployment.discovery_selectors` that control which namespaces appear in the UI. These are **independent of Istio's `meshConfig.discoverySelectors`** — Kiali does not read Istio's selectors automatically. If you want Kiali to show only mesh namespaces, configure matching selectors in the Kiali CR.

For example, to restrict Kiali to namespaces labeled `istio-discovery: enabled` (the same label used by the Istio CR in this guide):

```yaml
spec:
  deployment:
    cluster_wide_access: true   # keep ClusterRole for performance
    discovery_selectors:
      default:
      - matchLabels:
          istio-discovery: enabled
```

With `cluster_wide_access: true` and `discovery_selectors` set, Kiali retains efficient cluster-wide watches but only surfaces matching namespaces to users in the UI. To apply this, patch the Kiali CR on the spoke:

```bash
oc --context=ossm-kiali-spoke patch kiali kiali -n istio-system --type=merge -p '{
  "spec": {
    "deployment": {
      "discovery_selectors": {
        "default": [{"matchLabels": {"istio-discovery": "enabled"}}]
      }
    }
  }
}'
```

See the [Namespace Management]({{< relref "../../Configuration/namespace-management" >}}) documentation for the full set of options, including per-cluster selectors for multi-cluster deployments.

