---
title: "ACM Observability Integration"
description: "Configure Kiali to use ACM Observability Service for multi-cluster metrics in OpenShift environments."
---

{{% alert color="warning" %}}
**OpenShift Only**: This guide is specifically for Red Hat OpenShift environments using Red Hat Advanced Cluster Management (ACM). ACM is an OpenShift-specific product. For other Kubernetes distributions, you will need to use alternative metrics aggregation solutions such as Prometheus federation.
{{% /alert %}}

## Overview

Red Hat Advanced Cluster Management (ACM) is an OpenShift product that provides a centralized observability solution for multi-cluster OpenShift environments. When using ACM Observability, metrics from multiple clusters are aggregated via User Workload Monitoring (UWM) and made available through a Thanos Querier frontend on the hub cluster.

This guide explains how to configure Kiali deployed on an OpenShift management/hub cluster to query unified metrics from ACM Observability Service using certificate-based authentication with automatic rotation support.

**This solves the limitation** of short-lived (24-hour) OAuth tokens by providing long-lived credentials via certificates that automatically rotate without requiring Kiali pod restarts.

## Architecture

In this deployment model:

- **Hub Cluster**: Hosts Kiali and ACM Observability Service (with Thanos Querier)
- **Spoke Clusters**: Run the service mesh workloads with User Workload Monitoring (UWM) enabled
- **Metrics Flow**: Each spoke cluster's UWM scrapes metrics locally, ACM aggregates them, Kiali queries through Thanos Querier

This architecture provides:
- Horizontal scalability for metrics storage (ACM scales better than single Prometheus)
- Centralized observability without custom Prometheus federation
- Integration with OpenShift's standard observability stack

## Prerequisites

1. **Red Hat OpenShift** clusters (hub and spokes)
   - This solution is designed specifically for OpenShift environments
   - Requires OpenShift 4.x or later

2. **ACM Observability Service** installed and enabled on the hub cluster
   - Typically deployed in `open-cluster-management-observability` namespace
   - Thanos Querier service available at `observability-thanos-querier`

3. **User Workload Monitoring (UWM)** enabled on all spoke clusters
   - OpenShift's built-in User Workload Monitoring feature
   - Configured to scrape service mesh metrics
   - Metrics include cluster label for filtering

4. **Certificate infrastructure** for automatic rotation
   - cert-manager, OpenShift service CA, or ACM certificate management
   - Certificates with appropriate validity period and auto-renewal

5. **Kiali external deployment** configured
   - See [External Kiali deployment guide]({{< relref "." >}})
   - Kiali deployed on hub cluster with `ignore_home_cluster: true`

6. **Remote cluster access** configured for spoke clusters
   - Kiali needs kubeconfig secrets to access spoke clusters for configuration and workload data
   - See [Multi-cluster setup guide]({{< relref ".." >}}) for creating remote cluster secrets
   - Note: Metrics come from Thanos, but workload/config data comes directly from spoke clusters

## Authentication Model

Kiali supports two authentication mechanisms to ACM Observability Service's Thanos Querier, which can be used independently or together:

### mTLS Client Certificates (TLS Layer)

Client certificates (`cert_file`, `key_file`) provide authentication at the TLS layer. Use with `type: none` when certificates are the only authentication method:

```yaml
external_services:
  prometheus:
    auth:
      type: none  # No Authorization header
      cert_file: secret:acm-observability-certs:tls.crt
      key_file: secret:acm-observability-certs:tls.key
```

Add the Thanos CA certificate to the `kiali-cabundle` ConfigMap so that HTTPS server trust is established (see Step 3).

### Bearer Token (Authorization Header)

Bearer tokens provide authentication via HTTP Authorization header. Can be combined with mTLS for defense in depth:

```yaml
external_services:
  prometheus:
    auth:
      type: bearer  # Sends token in Authorization header
      token: secret:acm-bearer-token:token
      cert_file: secret:acm-observability-certs:tls.crt
      key_file: secret:acm-observability-certs:tls.key
```

Again, configure the CA trust chain via the `kiali-cabundle` ConfigMap.

**Important**: The `type` field (none/bearer/basic) controls the **Authorization HTTP header**, not TLS client certificates. mTLS authentication happens at the transport layer independently of the `type` setting.

## Certificate Setup

### Step 1: Obtain or Generate Client Certificates

You need three certificate files:
1. **CA Certificate** (`ca.crt`) - The CA that signed the Thanos Querier's server certificate
2. **Client Certificate** (`tls.crt`) - Kiali's client certificate for mTLS authentication
3. **Client Private Key** (`tls.key`) - The private key for the client certificate

The CA certificate is referenced by the `kiali-cabundle` ConfigMap, while the client certificate/key are supplied via the `acm-observability-certs` secret.

**Recommended approach**: Use cert-manager or OpenShift service CA to generate certificates signed by a CA trusted by ACM Observability Service. Consult your ACM administrator for:
- The CA to use for signing client certificates
- The CA certificate to verify the Thanos Querier server

**For development/testing only**, you can create self-signed certificates:

```bash
# WARNING: Self-signed certs require configuring ACM to trust them - not recommended for production

# Generate CA
openssl req -x509 -newkey rsa:4096 -keyout ca.key -out ca.crt -days 365 -nodes -subj "/CN=Test CA"

# Generate client cert signed by CA
openssl req -newkey rsa:4096 -keyout kiali-client.key -out kiali-client.csr -nodes -subj "/CN=kiali.istio-system.svc"
openssl x509 -req -in kiali-client.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out kiali-client.crt -days 365
```

### Step 2: Create Kubernetes Secret

Store the client certificate and key in a Kubernetes secret in the Kiali deployment namespace:

```bash
oc create secret generic acm-observability-certs \
  -n istio-system \
  --from-file=tls.crt=/path/to/kiali-client.crt \
  --from-file=tls.key=/path/to/kiali-client.key
```

Where:
- `tls.crt` = Kiali's client certificate (for client authentication)
- `tls.key` = Kiali's client private key (for client authentication)

**Note**: The secret keys (`tls.crt`, `tls.key`) can be any name—they will be preserved when mounted to the Kiali pod. If you use different key names, update the `secret:` references in your Kiali CR accordingly.

### Step 3: Provide the CA bundle via `kiali-cabundle`

Add the Thanos/ACM CA certificate to the `kiali-cabundle` ConfigMap so Kiali trusts the server's certificate:

```bash
oc create configmap kiali-cabundle \
  -n istio-system \
  --from-file=additional-ca-bundle.pem=/path/to/thanos-server-ca.crt
```

If the ConfigMap already exists (for example, because the operator created it), merge the PEM data into the existing `additional-ca-bundle.pem` key instead of recreating the resource.

For more details about CA bundle configuration, see the [TLS Configuration]({{< relref "../../p8s-jaeger-grafana/tls-configuration" >}}) page.

### Step 4: Configure Certificate Auto-Rotation

For automatic certificate rotation with cert-manager:

```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: kiali-observability-client
  namespace: istio-system
spec:
  secretName: acm-observability-certs
  duration: 2160h  # 90 days
  renewBefore: 360h  # Renew 15 days before expiry
  issuerRef:
    name: acm-ca-issuer  # Must reference an existing Issuer or ClusterIssuer
    kind: Issuer
  commonName: kiali.istio-system.svc
  dnsNames:
  - kiali.istio-system.svc
  - kiali.istio-system.svc.cluster.local
```

**Note**: You must create an Issuer or ClusterIssuer (e.g., `acm-ca-issuer`) that can sign certificates accepted by ACM Observability Service. Consult your ACM or OpenShift administrator for the appropriate CA issuer to use.

When cert-manager renews the certificate, the secret is updated. Kubernetes automatically updates the mounted files in the Kiali pod (typically within 60 seconds). Kiali reads certificates on each TLS handshake, so new connections automatically use the updated certificates **without requiring a pod restart**.

## Complete Configuration

### Overview

A complete ACM-based setup requires:
1. **Prometheus/Thanos configuration** - Point to ACM Observability Service (this guide)
2. **Remote cluster secrets** - Access spoke clusters for workload/config data (see [multi-cluster setup]({{< relref ".." >}}))
3. **External deployment settings** - Configure Kiali as external to the mesh

### Kiali CR Example

Configure Kiali to use ACM Observability Service:

```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: istio-system
spec:
  clustering:
    ignore_home_cluster: true  # External deployment mode
  kubernetes_config:
    cluster_name: hub  # Unique name for hub cluster
  external_services:
    prometheus:
      # Point to ACM Observability Service's Thanos Querier
      url: https://observability-thanos-querier.open-cluster-management-observability.svc:9090

      auth:
        # Scenario 1: mTLS only
        type: none
        cert_file: secret:acm-observability-certs:tls.crt
        key_file: secret:acm-observability-certs:tls.key

        # Scenario 2: mTLS + Bearer Token (uncomment if needed)
        # type: bearer
        # token: secret:acm-bearer-token:token

      # Enable Thanos proxy settings
      thanos_proxy:
        enabled: true
        retention_period: 7d
        scrape_interval: 30s
```

### Configuration Fields Explained

**URL**: Points to the Thanos Querier service in the ACM Observability namespace. Default port is typically 9090 or 10902 depending on your ACM version.

**CA trust**: Add the Thanos CA certificate to the `kiali-cabundle` ConfigMap (Step 3). Per-service `auth.ca_file` settings are deprecated and ignored.

**auth.cert_file**: Client certificate for mTLS authentication. When the secret is updated (certificate rotation), Kiali automatically uses the new certificate on next connection.

**auth.key_file**: Client private key matching the certificate. Must be from the same secret as cert_file.

**auth.type**: Controls the Authorization HTTP header:
- `none`: No Authorization header (use for mTLS-only authentication)
- `bearer`: Sends token in Authorization header (use with `auth.token`)
- `basic`: Sends username/password in Authorization header

**thanos_proxy.enabled**: Set to `true` when querying through Thanos. This adjusts how Kiali constructs PromQL queries.

## Finding the Thanos Querier URL

To find the ACM Observability Service URL in your cluster:

```bash
# Check if ACM Observability is installed
oc get deployment -n open-cluster-management-observability observability-thanos-querier

# Get the service details
oc get svc -n open-cluster-management-observability observability-thanos-querier

# Typical internal URL
https://observability-thanos-querier.open-cluster-management-observability.svc:9090
```

## Automatic Credential Rotation

Kiali supports automatic credential rotation without pod restart for all secret-backed credentials:

1. **Certificate/Key Updates**: When certificates are rotated (by cert-manager, ACM, etc.), the secret is updated
2. **Kubernetes Mount Update**: Kubernetes updates the mounted files in the Kiali pod (typically 0-60 seconds, based on kubelet sync interval)
3. **Kiali Auto-Detection**: Kiali reads certificates from the filesystem on each TLS handshake
4. **No Restart Required**: New connections automatically use updated certificates

This applies to:
- CA certificates stored in the `kiali-cabundle` ConfigMap
- Client certificates (`cert_file`, `key_file`)
- Bearer tokens (`token`)
- Basic auth credentials (`username`, `password`)

## Verification

### 1. Check Kiali Logs

After deploying, check that credentials are loaded:

```bash
oc logs -n istio-system deployment/kiali -c kiali | grep -i credential

# Expected output:
# Credential file path configured: [/kiali-override-secrets/prometheus-cert/tls.crt]
# Credential file path configured: [/kiali-override-secrets/prometheus-key/tls.key]
```

### 2. Test Metrics Queries

Access the Kiali UI and verify that metrics are displayed for workloads across clusters. Check that the traffic graph shows cross-cluster traffic if applicable.

### 3. Verify Certificate Rotation

Update the certificate secret and monitor Kiali:

```bash
# Update the secret (example with cert-manager doing auto-renewal)
# Wait 1-2 minutes for Kubernetes to update the mounted files

# Check Kiali continues to work without restart
oc get pods -n istio-system -l app.kubernetes.io/name=kiali

# Verify metrics still load in the UI
```

## Troubleshooting

### Certificate Validation Failures

If you see errors like "x509: certificate signed by unknown authority":
- Verify the `kiali-cabundle` ConfigMap contains the CA that signed the Thanos Querier server certificate
- Check that the CA cert is properly formatted PEM

### mTLS Handshake Failures

If you see "tls: failed to load client certificate":
- Verify `cert_file` and `key_file` point to valid certificate and key
- Ensure the certificate and key match (same keypair)
- Check file permissions allow Kiali to read the files

### No Metrics Displayed

If Kiali loads but shows no metrics:
- Verify the Thanos Querier URL is correct and accessible from Kiali pod
- Check `query_scope` cluster names match your ACM managed cluster names
- Verify UWM is properly scraping metrics on spoke clusters
- Check ACM Observability Service is aggregating metrics from spoke clusters

### Secret Not Mounted

If credentials aren't loaded:
- Verify the secret exists in the Kiali namespace
- Check the Kiali CR uses the correct `secret:` pattern
- Examine Kiali pod volumes: `oc describe pod -n istio-system <kiali-pod>`
- Ensure the secret keys match the names in the `secret:` pattern

### Authentication Method Unclear

If you're unsure which authentication method to use:
- Check ACM Observability Service documentation for your version
- Try mTLS first (`type: none` with certificates) - this is the long-lived solution
- Bearer tokens may work but could have expiration issues (the problem this feature solves)
- Contact your ACM administrator to determine the required auth method

## Related Links

- [ACM Observability Documentation](https://access.redhat.com/documentation/en-us/red_hat_advanced_cluster_management_for_kubernetes/)
- [External Kiali Deployment]({{< relref "." >}})
- [Multi-cluster Configuration]({{< relref "../" >}})
- [Kiali CR Reference](/docs/configuration/kialis.kiali.io/)
