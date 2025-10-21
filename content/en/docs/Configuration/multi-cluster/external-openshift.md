---
title: "External Kiali on OpenShift"
description: "Deploy Kiali on a management cluster to observe a remote service mesh"
weight: 10
---

External Kiali deployment model for OpenShift where Kiali runs on a separate management cluster from the Istio service mesh, allowing for dedicated observability management and reduced resource consumption on mesh clusters.

## Overview

### Architecture

The External Kiali architecture uses a two-cluster model:

- **Management Cluster**: Hosts Kiali (and optionally Prometheus and other observability tools)
- **Mesh Cluster(s)**: Runs Istio control plane, data plane, and applications

This separation allows for:
- Dedicated management of mesh observability
- Reduced resource consumption on mesh clusters
- Centralized visibility across multiple mesh clusters
- Improved security isolation

### Component Communication

The communication flow in an External Kiali deployment:

- **Kiali → Mesh Cluster API**: Via service account token authentication (stored in remote cluster secret)
- **Kiali → Prometheus**: Via OpenShift Route with HTTPS (if Prometheus is on mesh cluster)
- **Users → Kiali**: Via OpenShift OAuth authentication

## Prerequisites

### Required

- Two OpenShift clusters with cluster-admin access
- `oc` CLI tool installed and configured
- `kubectl` contexts configured for both clusters (or ability to switch contexts)
- Access to both cluster's API servers from your local machine

### Optional

- `helm` CLI tool (if using Helm installation method)
- `jq` CLI tool (for helper commands and scripting)

## Installation Overview

This guide walks through the complete process of setting up External Kiali on OpenShift:

1. **Prepare the Mesh Cluster**: Install Istio, certificates, and observability tools
2. **Expose Prometheus**: Create OpenShift Route for external access
3. **Create Remote Access Resources**: Set up RBAC and authentication for Kiali
4. **Create Remote Cluster Secret**: Configure management cluster to access mesh cluster
5. **Install Kiali**: Deploy Kiali on the management cluster
6. **Verify Installation**: Test connectivity and access

{{% alert color="info" %}}
Throughout this guide, replace `<mgmt-cluster-context>` and `<mesh-cluster-context>` with your actual OpenShift cluster context names.
{{% /alert %}}

## Step 1: Prepare the Mesh Cluster

### 1.1 Create Certificates for Istio

Istio requires CA certificates for secure mTLS communication. Create a root CA and mesh cluster certificates:

```bash
# Set up certificate directory
CERTS_DIR="/tmp/istio-multicluster-certs"
mkdir -p "${CERTS_DIR}"
cd "${CERTS_DIR}"

# Download Istio for certificate generation tools
ISTIO_VERSION="1.27.2"
curl -L https://istio.io/downloadIstio | ISTIO_VERSION=${ISTIO_VERSION} sh -
ISTIO_DIR="${CERTS_DIR}/istio-${ISTIO_VERSION}"

# Generate root CA
make -f ${ISTIO_DIR}/tools/certs/Makefile.selfsigned.mk root-ca

# Generate mesh cluster certificates
make -f ${ISTIO_DIR}/tools/certs/Makefile.selfsigned.mk mesh-cacerts
```

This creates the following certificate files in `${CERTS_DIR}/mesh/`:
- `ca-cert.pem` - Mesh cluster CA certificate
- `ca-key.pem` - Mesh cluster CA private key
- `root-cert.pem` - Root CA certificate
- `cert-chain.pem` - Certificate chain

### 1.2 Create istio-system Namespace

Switch to your mesh cluster context and create the Istio namespace:

```bash
# Switch to mesh cluster
oc config use-context <mesh-cluster-context>

# Set environment variables
ISTIO_NAMESPACE="istio-system"
NETWORK_MESH="network-mesh"

# Create namespace with network label
oc create namespace ${ISTIO_NAMESPACE}
oc label namespace ${ISTIO_NAMESPACE} topology.istio.io/network=${NETWORK_MESH} --overwrite
```

### 1.3 Install Certificates

Create a Kubernetes secret containing the CA certificates:

```bash
oc create secret generic cacerts -n ${ISTIO_NAMESPACE} \
  --from-file=${CERTS_DIR}/mesh/ca-cert.pem \
  --from-file=${CERTS_DIR}/mesh/ca-key.pem \
  --from-file=${CERTS_DIR}/mesh/root-cert.pem \
  --from-file=${CERTS_DIR}/mesh/cert-chain.pem
```

### 1.4 Install Istio via Sail Operator

On OpenShift, Istio is installed using the Sail Operator. Install the operator from the OpenShift OperatorHub:

**Via OpenShift Console:**
1. Navigate to **Operators** → **OperatorHub**
2. Search for "**Red Hat OpenShift Service Mesh**" or "**Sail Operator**"
3. Click **Install**
4. Select installation mode and namespace
5. Click **Install**

**Via CLI:**

```bash
# Create namespace for Sail Operator
oc create namespace openshift-operators

# Create subscription (if not already present)
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: sailoperator
  namespace: openshift-operators
spec:
  channel: stable
  name: sailoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
```

Wait for the Sail Operator to be ready, then create the Istio control plane:

```bash
MESH_ID="mesh-external"

oc apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: Istio
metadata:
  name: default
  namespace: ${ISTIO_NAMESPACE}
spec:
  version: v${ISTIO_VERSION}
  namespace: ${ISTIO_NAMESPACE}
  values:
    global:
      meshID: ${MESH_ID}
      multiCluster:
        clusterName: mesh
      network: ${NETWORK_MESH}
EOF
```

Wait for the Istio control plane to be ready:

```bash
oc wait --for=condition=Ready istio/default -n ${ISTIO_NAMESPACE} --timeout=600s
```

### 1.5 Install IstioCNI (Required for OpenShift)

OpenShift requires IstioCNI due to Security Context Constraints (SCC). Create the IstioCNI custom resource:

```bash
# Create istio-cni namespace
oc create namespace istio-cni

# Create IstioCNI resource
oc apply -f - <<EOF
apiVersion: sailoperator.io/v1
kind: IstioCNI
metadata:
  name: default
spec:
  version: v${ISTIO_VERSION}
  namespace: istio-cni
EOF
```

Wait for IstioCNI to be ready:

```bash
oc wait --for=condition=Ready istiocni/default --timeout=300s
```

{{% alert color="info" %}}
IstioCNI is required on OpenShift to handle pod networking without requiring elevated privileges. Without it, the Istio sidecar injection will fail due to SCC restrictions.
{{% /alert %}}

### 1.6 Install Observability Addons

Install Prometheus and Jaeger using Istio's addon manifests:

```bash
# Install Prometheus
oc apply -f ${ISTIO_DIR}/samples/addons/prometheus.yaml -n ${ISTIO_NAMESPACE}

# Install Jaeger
oc apply -f ${ISTIO_DIR}/samples/addons/jaeger.yaml -n ${ISTIO_NAMESPACE}

# Wait for deployments to be ready
oc wait --for=condition=available --timeout=300s \
  deployment/prometheus -n ${ISTIO_NAMESPACE}
oc wait --for=condition=available --timeout=300s \
  deployment/jaeger -n ${ISTIO_NAMESPACE}
```

{{% alert color="warning" %}}
These addon manifests are for demonstration purposes. For production deployments, consider using the Prometheus Operator or other production-grade observability solutions.
{{% /alert %}}

## Step 2: Expose Prometheus for External Access

### 2.1 Create OpenShift Route

Kiali on the management cluster needs to access Prometheus on the mesh cluster. Create an OpenShift Route with edge TLS termination:

```bash
# Create route for Prometheus
oc create route edge prometheus \
  --service=prometheus \
  --insecure-policy=Redirect \
  -n ${ISTIO_NAMESPACE}

# Get the route hostname
MESH_PROM_ADDRESS=$(oc get route prometheus -n ${ISTIO_NAMESPACE} -o jsonpath='{.spec.host}')
echo "Prometheus accessible at: https://${MESH_PROM_ADDRESS}"
```

Test the route:

```bash
curl -k https://${MESH_PROM_ADDRESS}/api/v1/query?query=up
```

{{% alert color="info" %}}
The route uses edge TLS termination with OpenShift's automatically generated certificates (typically self-signed in development environments). Kiali will need to use `insecure_skip_verify: true` to connect to this route. For production environments, consider configuring custom certificates.
{{% /alert %}}

Save the `MESH_PROM_ADDRESS` value as you'll need it when configuring Kiali on the management cluster.

## Step 3: Create Remote Cluster Access Resources

Kiali needs specific resources on the mesh cluster to authenticate and query the cluster's API. You have two options for creating these resources:

- **Option A**: Use Kiali Server Helm Chart (requires Helm)
- **Option B**: Use Kiali Operator via OLM (no Helm required)

Both options create the same resources (ServiceAccount, ClusterRole, ClusterRoleBinding, and OAuthClient), just through different mechanisms.

### 3.1 Option A: Using Kiali Server Helm Chart

**When to use**: Lightweight approach, no operator needed on mesh cluster, comfortable with Helm.

First, ensure you're on the mesh cluster context:

```bash
oc config use-context <mesh-cluster-context>
```

Pull the Kiali Server helm chart:

```bash
helm repo add kiali https://kiali.org/helm-charts
helm repo update kiali
```

Create the namespace where remote resources will be installed:

```bash
KIALI_NAMESPACE="kiali-server"
oc create namespace ${KIALI_NAMESPACE}
```

Get the management cluster domain for configuring the OAuth redirect URI:

```bash
# Temporarily switch to management cluster
oc config use-context <mgmt-cluster-context>
MGMT_DOMAIN=$(oc get ingresses.config/cluster -o jsonpath='{.spec.domain}')

# Calculate redirect URI
KIALI_REDIRECT_URI="https://kiali-${KIALI_NAMESPACE}.${MGMT_DOMAIN}/api/auth/callback/mesh"
echo "OAuth Redirect URI: ${KIALI_REDIRECT_URI}"

# Switch back to mesh cluster
oc config use-context <mesh-cluster-context>
```

Install the remote resources using the Kiali Server helm chart in `remote_cluster_resources_only` mode:

```bash
helm upgrade --install kiali-remote-resources kiali/kiali-server \
  --namespace ${KIALI_NAMESPACE} \
  --set auth.strategy=openshift \
  --set "auth.openshift.redirect_uris[0]=${KIALI_REDIRECT_URI}" \
  --set deployment.remote_cluster_resources_only=true \
  --set deployment.instance_name=kiali \
  --set deployment.namespace=${KIALI_NAMESPACE} \
  --set deployment.view_only_mode=false
```

This creates:
- **ServiceAccount**: `kiali` (in `kiali-server` namespace)
- **ClusterRole**: `kiali` (cluster-wide read/write permissions)
- **ClusterRoleBinding**: `kiali` (binds the role to the service account)
- **OAuthClient**: `kiali-kiali-server` (for OpenShift OAuth authentication)

{{% alert color="info" %}}
The `remote_cluster_resources_only: true` setting tells the helm chart to create ONLY the RBAC and OAuth resources, without deploying a Kiali server pod. This is exactly what we need for external Kiali.
{{% /alert %}}

Proceed to [section 3.3](#33-create-service-account-token-secret) to create the service account token secret.

### 3.2 Option B: Using Kiali Operator via OLM

**When to use**: Prefer operator-managed resources, familiar with OLM, no Helm installed.

#### Install Kiali Operator

Ensure you're on the mesh cluster context:

```bash
oc config use-context <mesh-cluster-context>
```

**Via OpenShift Console:**
1. Navigate to **Operators** → **OperatorHub**
2. Search for "**Kiali Operator**"
3. Select the operator (package name: `kiali-ossm`)
4. Click **Install**
5. Select **A specific namespace on the cluster**
6. Choose or create namespace: `kiali-operator`
7. Click **Install**

**Via CLI:**

```bash
# Create namespace for Kiali Operator
KIALI_OPERATOR_NAMESPACE="kiali-operator"
oc create namespace ${KIALI_OPERATOR_NAMESPACE}

# Create subscription
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-operator
  namespace: ${KIALI_OPERATOR_NAMESPACE}
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  config:
    env:
    - name: ALLOW_ALL_ACCESSIBLE_NAMESPACES
      value: "true"
    - name: ACCESSIBLE_NAMESPACES_LABEL
      value: ""
EOF
```

Wait for the operator to be ready:

```bash
oc wait --for=condition=available --timeout=300s \
  deployment/kiali-operator -n ${KIALI_OPERATOR_NAMESPACE}
```

Wait for the Kiali CRD to be established:

```bash
oc wait --for condition=established --timeout=300s crd/kialis.kiali.io
```

#### Create Kiali CR with remote_cluster_resources_only

Create the namespace for Kiali resources:

```bash
KIALI_NAMESPACE="kiali-server"
oc create namespace ${KIALI_NAMESPACE}
```

Get the management cluster domain for OAuth redirect:

```bash
# Temporarily switch to management cluster
oc config use-context <mgmt-cluster-context>
MGMT_DOMAIN=$(oc get ingresses.config/cluster -o jsonpath='{.spec.domain}')

# Calculate redirect URI
KIALI_REDIRECT_URI="https://kiali-${KIALI_NAMESPACE}.${MGMT_DOMAIN}/api/auth/callback/mesh"
echo "OAuth Redirect URI: ${KIALI_REDIRECT_URI}"

# Switch back to mesh cluster
oc config use-context <mesh-cluster-context>
```

Create the Kiali CR:

```bash
oc apply -f - <<EOF
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: ${KIALI_NAMESPACE}
spec:
  auth:
    strategy: openshift
    openshift:
      redirect_uris:
      - ${KIALI_REDIRECT_URI}
  deployment:
    instance_name: kiali
    namespace: ${KIALI_NAMESPACE}
    remote_cluster_resources_only: true
    view_only_mode: false
EOF
```

Wait for the Kiali CR to be reconciled:

```bash
# The operator will create resources but NOT create a deployment
# Check that the Kiali CR status shows success
oc get kiali kiali -n ${KIALI_NAMESPACE} -o jsonpath='{.status.conditions[?(@.type=="Successful")].status}'
```

This creates:
- **ServiceAccount**: `kiali-service-account` (in `kiali-server` namespace)
- **ClusterRole**: `kiali` (cluster-wide read/write permissions)
- **ClusterRoleBinding**: `kiali` (binds the role to the service account)
- **OAuthClient**: `kiali-kiali-server` (for OpenShift OAuth authentication)

{{% alert color="warning" %}}
Note the different ServiceAccount name: The Operator method creates `kiali-service-account`, while the Helm method creates `kiali`. Remember which method you used for the next step.
{{% /alert %}}

### 3.3 Create Service Account Token Secret

After using **either Option A or B**, you need to create a service account token secret manually. Kubernetes 1.24+ no longer auto-generates long-lived tokens, so you must create a secret explicitly.

First, determine the ServiceAccount name based on your installation method:
- **Option A (Helm)**: ServiceAccount name is `kiali`
- **Option B (Operator)**: ServiceAccount name is `kiali-service-account`

Create the token secret:

```bash
# Set this based on your installation method
# For Helm (Option A):
SA_NAME="kiali"
# For Operator (Option B):
# SA_NAME="kiali-service-account"

oc apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: ${KIALI_NAMESPACE}
  annotations:
    kubernetes.io/service-account.name: ${SA_NAME}
type: kubernetes.io/service-account-token
EOF
```

Wait for the token to be generated:

```bash
# This will wait until the token field is populated
echo "Waiting for token to be generated..."
for i in {1..30}; do
  TOKEN=$(oc get secret kiali -n ${KIALI_NAMESPACE} -o jsonpath='{.data.token}' 2>/dev/null || echo "")
  if [ -n "${TOKEN}" ]; then
    echo "✓ Service account token generated successfully"
    break
  fi
  echo -n "."
  sleep 2
done

if [ -z "${TOKEN}" ]; then
  echo "✗ ERROR: Service account token was not generated"
  exit 1
fi
```

## Step 4: Create Remote Cluster Secret on Management Cluster

Now that the mesh cluster has the necessary resources, you need to create a secret on the management cluster that contains the credentials to access the mesh cluster.

### 4.1 Extract Token and Cluster Info from Mesh Cluster

Ensure you're on the mesh cluster context:

```bash
oc config use-context <mesh-cluster-context>
```

Extract the service account token:

```bash
KIALI_TOKEN=$(oc get secret kiali -n ${KIALI_NAMESPACE} -o jsonpath='{.data.token}' | base64 -d)
```

Get the mesh cluster API server URL:

```bash
MESH_API_URL=$(oc whoami --show-server)
echo "Mesh cluster API: ${MESH_API_URL}"
```

Get the cluster CA certificate:

```bash
MESH_CA_DATA=$(oc get secret kiali -n ${KIALI_NAMESPACE} -o jsonpath='{.data.ca\.crt}')
```

### 4.2 Create Secret on Management Cluster

Switch to the management cluster:

```bash
oc config use-context <mgmt-cluster-context>
```

Create the `kiali-server` namespace on the management cluster:

```bash
KIALI_NAMESPACE="kiali-server"
oc create namespace ${KIALI_NAMESPACE}
```

Create the remote cluster secret:

```bash
cat <<EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali-remote-cluster-secret-mesh
  namespace: ${KIALI_NAMESPACE}
  labels:
    kiali.io/multiCluster: "true"
  annotations:
    kiali.io/cluster: mesh
stringData:
  mesh: |
    apiVersion: v1
    kind: Config
    preferences: {}
    current-context: mesh
    contexts:
    - name: mesh
      context:
        cluster: mesh
        user: mesh
    users:
    - name: mesh
      user:
        token: ${KIALI_TOKEN}
    clusters:
    - name: mesh
      cluster:
        insecure-skip-tls-verify: true
        server: ${MESH_API_URL}
        certificate-authority-data: ${MESH_CA_DATA}
EOF
```

Verify the secret was created:

```bash
oc get secret kiali-remote-cluster-secret-mesh -n ${KIALI_NAMESPACE}
```

{{% alert color="info" %}}
The `kiali.io/multiCluster: "true"` label tells the Kiali Operator to auto-discover this secret. The `kiali.io/cluster` annotation specifies the cluster name as "mesh".
{{% /alert %}}

{{% alert color="warning" %}}
This example uses `insecure-skip-tls-verify: true` which is common in development environments with self-signed certificates. For production deployments, consider using proper CA certificates by including the `certificate-authority-data` field with valid CA data and removing the `insecure-skip-tls-verify` field.
{{% /alert %}}

## Step 5: Install Kiali on Management Cluster

Now install Kiali on the management cluster. Again, you have two installation options:

- **Option A**: Use Kiali Operator via OLM (no Helm required)
- **Option B**: Use Helm

Both options achieve the same result—a running Kiali instance that monitors the remote mesh cluster.

### 5.1 Option A: Using Kiali Operator via OLM

**When to use**: No Helm installed, prefer OpenShift-native operator installation.

Ensure you're on the management cluster context:

```bash
oc config use-context <mgmt-cluster-context>
```

#### Install Kiali Operator

**Via OpenShift Console:**
1. Navigate to **Operators** → **OperatorHub**
2. Search for "**Kiali Operator**"
3. Select the operator (package name: `kiali-ossm`)
4. Click **Install**
5. Select **A specific namespace on the cluster**
6. Choose or create namespace: `kiali-operator`
7. Click **Install**

**Via CLI:**

```bash
# Create namespace for Kiali Operator
KIALI_OPERATOR_NAMESPACE="kiali-operator"
oc create namespace ${KIALI_OPERATOR_NAMESPACE}

# Create subscription
oc apply -f - <<EOF
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-operator
  namespace: ${KIALI_OPERATOR_NAMESPACE}
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
  config:
    env:
    - name: ALLOW_ALL_ACCESSIBLE_NAMESPACES
      value: "true"
    - name: ACCESSIBLE_NAMESPACES_LABEL
      value: ""
EOF
```

Wait for the operator to be ready:

```bash
oc wait --for=condition=available --timeout=300s \
  deployment/kiali-operator -n ${KIALI_OPERATOR_NAMESPACE}
```

Wait for the Kiali CRD to be established:

```bash
oc wait --for condition=established --timeout=300s crd/kialis.kiali.io
```

#### Create Kiali CR

Prepare the configuration values:

```bash
KIALI_NAMESPACE="kiali-server"
MGMT_DOMAIN=$(oc get ingresses.config/cluster -o jsonpath='{.spec.domain}')
KIALI_WEB_FQDN="kiali-${KIALI_NAMESPACE}.${MGMT_DOMAIN}"

# Use the MESH_PROM_ADDRESS from Step 2.1
MESH_PROM_URL="https://${MESH_PROM_ADDRESS}"

echo "Kiali will be accessible at: https://${KIALI_WEB_FQDN}"
echo "Prometheus URL: ${MESH_PROM_URL}"
```

Create the Kiali CR:

```bash
oc apply -f - <<EOF
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: ${KIALI_NAMESPACE}
spec:
  auth:
    strategy: openshift
  clustering:
    ignore_home_cluster: true
  deployment:
    cluster_wide_access: true
    logger:
      log_level: info
    namespace: ${KIALI_NAMESPACE}
  external_services:
    custom_dashboards:
      enabled: true
    grafana:
      enabled: false
    prometheus:
      url: "${MESH_PROM_URL}"
      auth:
        insecure_skip_verify: true
    tracing:
      enabled: false
  kubernetes_config:
    cluster_name: mgmt
  server:
    web_fqdn: "${KIALI_WEB_FQDN}"
    web_root: /
    web_schema: https
EOF
```

Key configuration settings explained:

- `clustering.ignore_home_cluster: true` - Tells Kiali not to monitor the management cluster
- `kubernetes_config.cluster_name: mgmt` - Sets a unique name for the management cluster
- `deployment.cluster_wide_access: true` - Allows Kiali to access resources across all namespaces
- `external_services.prometheus.url` - Points to the Prometheus route on the mesh cluster
- `external_services.prometheus.auth.insecure_skip_verify: true` - Accepts self-signed certificates
- `external_services.grafana.enabled: false` - Disables Grafana (not present on mgmt cluster)
- `external_services.tracing.enabled: false` - Disables tracing (not present on mgmt cluster)

Wait for Kiali to be deployed:

```bash
oc wait --for=condition=available --timeout=300s \
  deployment/kiali -n ${KIALI_NAMESPACE}
```

Proceed to [Step 6](#step-6-verify-installation) to verify the installation.

### 5.2 Option B: Using Helm

**When to use**: Helm is already installed, prefer Helm-based installations.

Ensure you're on the management cluster context:

```bash
oc config use-context <mgmt-cluster-context>
```

Add the Kiali Helm repository:

```bash
helm repo add kiali https://kiali.org/helm-charts
helm repo update kiali
```

Prepare the configuration values:

```bash
KIALI_NAMESPACE="kiali-server"
KIALI_OPERATOR_NAMESPACE="kiali-operator"
MGMT_DOMAIN=$(oc get ingresses.config/cluster -o jsonpath='{.spec.domain}')
KIALI_WEB_FQDN="kiali-${KIALI_NAMESPACE}.${MGMT_DOMAIN}"

# Use the MESH_PROM_ADDRESS from Step 2.1
MESH_PROM_URL="https://${MESH_PROM_ADDRESS}"

echo "Kiali will be accessible at: https://${KIALI_WEB_FQDN}"
echo "Prometheus URL: ${MESH_PROM_URL}"
```

Install Kiali Operator with Kiali CR via Helm:

```bash
helm upgrade --install kiali-operator kiali/kiali-operator \
  --namespace ${KIALI_OPERATOR_NAMESPACE} \
  --create-namespace \
  --set cr.create=true \
  --set cr.namespace=${KIALI_NAMESPACE} \
  --set cr.spec.auth.strategy=openshift \
  --set cr.spec.clustering.ignore_home_cluster=true \
  --set cr.spec.deployment.cluster_wide_access=true \
  --set cr.spec.deployment.logger.log_level=info \
  --set cr.spec.deployment.namespace=${KIALI_NAMESPACE} \
  --set cr.spec.external_services.custom_dashboards.enabled=true \
  --set cr.spec.external_services.grafana.enabled=false \
  --set cr.spec.external_services.prometheus.url="${MESH_PROM_URL}" \
  --set cr.spec.external_services.prometheus.auth.insecure_skip_verify=true \
  --set cr.spec.external_services.tracing.enabled=false \
  --set cr.spec.kubernetes_config.cluster_name=mgmt \
  --set cr.spec.server.web_fqdn="${KIALI_WEB_FQDN}" \
  --set cr.spec.server.web_root=/ \
  --set cr.spec.server.web_schema=https
```

Wait for Kiali to be deployed:

```bash
oc wait --for=condition=available --timeout=300s \
  deployment/kiali -n ${KIALI_NAMESPACE}
```

## Step 6: Verify Installation

### 6.1 Check Kiali Deployment

Verify that Kiali is running on the management cluster:

```bash
oc config use-context <mgmt-cluster-context>

# Check deployment status
oc get deployment kiali -n ${KIALI_NAMESPACE}

# Check pod status
oc get pods -n ${KIALI_NAMESPACE} -l app.kubernetes.io/name=kiali

# Check Kiali CR status
oc get kiali kiali -n ${KIALI_NAMESPACE} -o jsonpath='{.status.conditions[?(@.type=="Successful")].status}'
```

Get the Kiali route URL:

```bash
KIALI_ROUTE=$(oc get route kiali -n ${KIALI_NAMESPACE} -o jsonpath='{.spec.host}')
echo "Kiali UI: https://${KIALI_ROUTE}"
```

Check Kiali logs for any errors:

```bash
oc logs deployment/kiali -n ${KIALI_NAMESPACE} --tail=50
```

Look for log entries indicating successful connection to the mesh cluster:

```
Connected to cluster: mesh
Prometheus is accessible at: https://...
```

### 6.2 Access Kiali

1. Open your browser to the Kiali route URL: `https://${KIALI_ROUTE}`

2. You will be redirected to OpenShift OAuth login. Log in with your **management cluster** credentials.

3. After successful authentication, you should see the Kiali dashboard.

4. Verify mesh cluster connectivity:
   - Look for the cluster selector dropdown in the top navigation (if you have a multi-cluster setup)
   - Select the "mesh" cluster from the dropdown
   - Navigate to **Graph**, **Applications**, **Workloads**, or **Services**
   - You should see resources from the mesh cluster

5. Verify Prometheus connectivity:
   - Navigate to **Graph** and select a namespace
   - If you see traffic metrics and graphs, Prometheus is connected correctly
   - Check for any error messages about metrics being unavailable

{{% alert color="success" %}}
If you see mesh cluster resources and metrics, congratulations! Your External Kiali deployment is working correctly.
{{% /alert %}}

{{% alert color="warning" %}}
If you don't see any resources from the mesh cluster, proceed to the [Troubleshooting](#troubleshooting) section.
{{% /alert %}}

## Configuration Reference

### Key Kiali CR Settings for External Deployment

The following table summarizes the critical configuration settings for External Kiali on OpenShift:

| Setting | Value | Purpose |
|---------|-------|---------|
| `clustering.ignore_home_cluster` | `true` | Instructs Kiali not to monitor the management cluster where it's deployed |
| `kubernetes_config.cluster_name` | `mgmt` | Sets a unique identifier for the management cluster |
| `deployment.cluster_wide_access` | `true` | Grants Kiali access to all namespaces on remote clusters |
| `deployment.namespace` | `kiali-server` | Namespace where Kiali server is deployed |
| `auth.strategy` | `openshift` | Uses OpenShift OAuth for authentication |
| `external_services.prometheus.url` | `https://<mesh-prom-route>` | URL to Prometheus on mesh cluster (via Route) |
| `external_services.prometheus.auth.insecure_skip_verify` | `true` | Accepts self-signed certificates from OpenShift routes |
| `external_services.grafana.enabled` | `false` | Disables Grafana (not present on mgmt cluster) |
| `external_services.tracing.enabled` | `false` | Disables tracing (not present on mgmt cluster) |
| `server.web_fqdn` | `kiali-<namespace>.<domain>` | The fully-qualified domain name where Kiali is accessible |
| `server.web_schema` | `https` | The HTTP schema (http or https) used to serve Kiali |
| `server.web_root` | `/` | Root path for Kiali web UI |

### Remote Resources Configuration

When using `deployment.remote_cluster_resources_only: true` on the mesh cluster:

- **Purpose**: Creates only RBAC and authentication resources without deploying a Kiali server pod
- **Use case**: External Kiali deployments where Kiali runs on a separate management cluster
- **Resources created**:
  - ServiceAccount (name varies by installation method)
  - ClusterRole with appropriate permissions
  - ClusterRoleBinding
  - OAuthClient for OpenShift authentication
- **No Kiali deployment**: The operator/helm chart will NOT create a Kiali server pod

**ServiceAccount names by installation method**:
- Helm chart (Option A): `kiali`
- Operator (Option B): `kiali-service-account`

## Troubleshooting

### Kiali Cannot Connect to Mesh Cluster

**Symptoms**: Kiali UI shows no resources from mesh cluster, or displays connection errors.

**Check the remote cluster secret**:

```bash
oc config use-context <mgmt-cluster-context>
oc get secret kiali-remote-cluster-secret-mesh -n ${KIALI_NAMESPACE}
```

If the secret doesn't exist, recreate it following [Step 4.2](#42-create-secret-on-management-cluster).

**Verify the secret contains valid data**:

```bash
oc get secret kiali-remote-cluster-secret-mesh -n ${KIALI_NAMESPACE} -o jsonpath='{.data.mesh}' | base64 -d
```

Ensure the kubeconfig has the correct API server URL, token, and CA certificate.

**Test the token is valid on the mesh cluster**:

```bash
oc config use-context <mesh-cluster-context>
TOKEN=$(oc get secret kiali -n ${KIALI_NAMESPACE} -o jsonpath='{.data.token}' | base64 -d)

# Test authentication with the token
oc whoami --token="${TOKEN}"

# Test API access
oc get namespaces --token="${TOKEN}"
```

If the token is invalid or expired, recreate the token secret following [Step 3.3](#33-create-service-account-token-secret).

**Check Kiali logs for connection errors**:

```bash
oc config use-context <mgmt-cluster-context>
oc logs deployment/kiali -n ${KIALI_NAMESPACE} | grep -i "cluster\|error"
```

Look for errors related to authentication, authorization, or network connectivity.

**Verify RBAC permissions on mesh cluster**:

```bash
oc config use-context <mesh-cluster-context>

# Check if ServiceAccount exists
oc get sa kiali -n ${KIALI_NAMESPACE}
# or if using operator method:
# oc get sa kiali-service-account -n ${KIALI_NAMESPACE}

# Check ClusterRole and ClusterRoleBinding
oc get clusterrole kiali
oc get clusterrolebinding kiali
```

### Kiali Cannot Access Prometheus

**Symptoms**: Kiali UI shows "Metrics unavailable" or graphs are empty.

**Test Prometheus route directly**:

```bash
oc config use-context <mesh-cluster-context>
MESH_PROM_ADDRESS=$(oc get route prometheus -n ${ISTIO_NAMESPACE} -o jsonpath='{.spec.host}')

# Test route accessibility
curl -k https://${MESH_PROM_ADDRESS}/api/v1/query?query=up
```

If this fails, check that the Prometheus route exists and is configured correctly:

```bash
oc get route prometheus -n ${ISTIO_NAMESPACE}
```

**Check Kiali's Prometheus configuration**:

```bash
oc config use-context <mgmt-cluster-context>
oc get kiali kiali -n ${KIALI_NAMESPACE} -o jsonpath='{.spec.external_services.prometheus}'
```

Verify that:
- `url` points to the correct Prometheus route
- `insecure_skip_verify` is set to `true` (if using self-signed certs)

**Check Kiali logs for Prometheus connection errors**:

```bash
oc logs deployment/kiali -n ${KIALI_NAMESPACE} | grep -i prometheus
```

**Verify Prometheus is running on mesh cluster**:

```bash
oc config use-context <mesh-cluster-context>
oc get deployment prometheus -n ${ISTIO_NAMESPACE}
oc get pods -n ${ISTIO_NAMESPACE} -l app=prometheus
```

**Test network connectivity from management to mesh cluster**:

```bash
# From your local machine or a pod on the management cluster
curl -k https://${MESH_PROM_ADDRESS}/api/v1/query?query=up
```

If this fails, there may be network policies or firewall rules blocking traffic between clusters.

### OAuth Authentication Fails

**Symptoms**: Unable to log in to Kiali, OAuth errors, or redirect loop.

**Verify OAuth client exists on mesh cluster**:

```bash
oc config use-context <mesh-cluster-context>
oc get oauthclient kiali-${KIALI_NAMESPACE}
```

If it doesn't exist, the remote resources were not created correctly. Revisit [Step 3](#step-3-create-remote-cluster-access-resources).

**Check OAuth redirect URIs**:

```bash
oc get oauthclient kiali-${KIALI_NAMESPACE} -o jsonpath='{.redirectURIs}'
```

The redirect URI should match:
```
https://kiali-<kiali-namespace>.<mgmt-cluster-domain>/api/auth/callback/mesh
```

If it doesn't match, update the OAuthClient:

```bash
# Get the correct redirect URI
MGMT_DOMAIN=$(oc --context=<mgmt-cluster-context> get ingresses.config/cluster -o jsonpath='{.spec.domain}')
KIALI_REDIRECT_URI="https://kiali-${KIALI_NAMESPACE}.${MGMT_DOMAIN}/api/auth/callback/mesh"

# Update OAuthClient
oc patch oauthclient kiali-${KIALI_NAMESPACE} --type=json \
  -p "[{\"op\": \"replace\", \"path\": \"/redirectURIs\", \"value\": [\"${KIALI_REDIRECT_URI}\"]}]"
```

**Check Kiali route on management cluster**:

```bash
oc config use-context <mgmt-cluster-context>
oc get route kiali -n ${KIALI_NAMESPACE}
```

Ensure the route hostname matches the domain used in the redirect URI.

**Verify Kiali CR auth configuration**:

```bash
oc get kiali kiali -n ${KIALI_NAMESPACE} -o jsonpath='{.spec.auth}'
```

Ensure `strategy` is set to `openshift`.

**Check Kiali logs for auth errors**:

```bash
oc logs deployment/kiali -n ${KIALI_NAMESPACE} | grep -i "auth\|oauth"
```

**Clear browser cookies and try again**:

Sometimes stale OAuth cookies can cause authentication issues. Clear your browser cookies for the Kiali route domain and try logging in again.

## Cleanup

### Remove Kiali from Management Cluster

To completely remove Kiali from the management cluster:

```bash
oc config use-context <mgmt-cluster-context>

# Delete Kiali CR (this will trigger operator to clean up Kiali deployment)
oc delete kiali kiali -n ${KIALI_NAMESPACE}

# Wait for Kiali deployment to be deleted
oc wait --for=delete deployment/kiali -n ${KIALI_NAMESPACE} --timeout=120s

# Delete remote cluster secret
oc delete secret kiali-remote-cluster-secret-mesh -n ${KIALI_NAMESPACE}

# If using OLM, delete the subscription
oc delete subscription kiali-operator -n ${KIALI_OPERATOR_NAMESPACE}

# Delete the CSV (ClusterServiceVersion) to remove the operator
oc delete csv -n ${KIALI_OPERATOR_NAMESPACE} \
  $(oc get csv -n ${KIALI_OPERATOR_NAMESPACE} -o name | grep kiali-operator)

# If using Helm, uninstall the release
# helm uninstall kiali-operator -n ${KIALI_OPERATOR_NAMESPACE}

# Delete namespaces
oc delete namespace ${KIALI_NAMESPACE}
oc delete namespace ${KIALI_OPERATOR_NAMESPACE}
```

### Remove Resources from Mesh Cluster

To remove the remote access resources from the mesh cluster:

```bash
oc config use-context <mesh-cluster-context>

# If you used Operator method (Option B):
oc delete kiali kiali -n ${KIALI_NAMESPACE}
oc delete subscription kiali-operator -n ${KIALI_OPERATOR_NAMESPACE}
oc delete csv -n ${KIALI_OPERATOR_NAMESPACE} \
  $(oc get csv -n ${KIALI_OPERATOR_NAMESPACE} -o name | grep kiali-operator)

# If you used Helm method (Option A):
# helm uninstall kiali-remote-resources -n ${KIALI_NAMESPACE}

# Delete the token secret
oc delete secret kiali -n ${KIALI_NAMESPACE}

# Delete the OAuthClient
oc delete oauthclient kiali-${KIALI_NAMESPACE}

# Delete the namespace
oc delete namespace ${KIALI_NAMESPACE}

# If you also want to remove Istio and observability tools:
# oc delete istio default -n ${ISTIO_NAMESPACE}
# oc delete istiocni default
# oc delete namespace istio-cni
# oc delete namespace ${ISTIO_NAMESPACE}
```

{{% alert color="warning" %}}
Deleting Istio and the `istio-system` namespace will remove the entire service mesh from the cluster. Only do this if you're sure you want to completely remove Istio.
{{% /alert %}}

## Comparison with Standard Multi-Cluster

Understanding the differences between External Kiali and standard multi-cluster deployments:

| Aspect | Standard Multi-Cluster | External Kiali |
|--------|----------------------|----------------|
| **Kiali Location** | Co-located with an Istio control plane | Separate management cluster (no Istio) |
| **Home Cluster Monitoring** | Yes, monitors the cluster where Kiali runs | No (`ignore_home_cluster: true`) |
| **Istio on Kiali Cluster** | Required | Not required |
| **Prometheus Location** | Can be anywhere with aggregated metrics | Recommended on management cluster or exposed via route |
| **Primary Use Case** | Unified visibility across mesh clusters | Dedicated observability management cluster |
| **Resource Impact** | Kiali consumes resources on a mesh cluster | Kiali resource consumption is separated from mesh |
| **Complexity** | Moderate | Higher (requires cross-cluster communication setup) |
| **Security Isolation** | Observability tools run alongside mesh | Complete separation of observability and mesh planes |
| **Scalability** | Limited by mesh cluster resources | Independent scaling of observability infrastructure |

**When to use External Kiali**:
- You want to dedicate a cluster for observability tools
- You need to reduce resource consumption on mesh clusters
- You require security isolation between mesh and observability
- You manage multiple mesh clusters from a central location
- You want independent scaling of observability infrastructure

**When to use Standard Multi-Cluster**:
- You have a single mesh cluster with Kiali co-located
- You want simpler deployment and management
- Cross-cluster network communication is restricted
- You don't have resources for a dedicated management cluster
