---
title: "TLS Configuration"
description: >
  This page describes how to configure TLS certificates for Kiali's connections to external services.
weight: 10
---

## Overview

When Kiali connects to external services (Prometheus, Grafana, Jaeger/Tempo, Perses) over HTTPS, it needs to verify the TLS certificates presented by those services. By default, Kiali trusts the system certificate authorities (CAs) that are built into the container image.

If your external services use certificates issued by a private CA (such as an internal corporate CA, a service mesh CA, or self-signed certificates), you need to configure Kiali to trust those additional CAs.

## Adding Custom Certificate Authorities

Kiali uses a **global CA bundle** mechanism to trust additional certificate authorities. All custom CAs are added to a single certificate pool that applies to all HTTPS connections Kiali makes to external services.

### On Kubernetes

To add custom CAs, create a ConfigMap named `<kiali-instance-name>-cabundle` in the Kiali namespace. The default instance name is `kiali`, so the ConfigMap would be named `kiali-cabundle`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kiali-cabundle
  namespace: istio-system  # Or your Kiali namespace
data:
  additional-ca-bundle.pem: |
    -----BEGIN CERTIFICATE-----
    MIIDxTCCAq2gAwIBAgIQAqxcJmoLQ...
    ... (your CA certificate) ...
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    MIIDyTCCArGgAwIBAgIRAJ4K...
    ... (additional CA certificates if needed) ...
    -----END CERTIFICATE-----
```

{{% alert color="info" %}}
**Key name**: The key must be `additional-ca-bundle.pem`. You can include multiple CA certificates in PEM format in the same file.

**Alternative keys**: You can also use `openid-server-ca.crt` or (on OpenShift) `oauth-server-ca.crt` as key names. While these names suggest specific purposes, all CAs are loaded into Kiali's global certificate pool and trusted for all TLS connections. Using `additional-ca-bundle.pem` is recommended for clarity.

**For OpenShift OAuth authentication**: On OpenShift, you can alternatively create a separate ConfigMap named `<instance-name>-oauth-cabundle` with the key `oauth-server-ca.crt`. See the [OpenShift authentication]({{< relref "../authentication/openshift#using-an-internal-or-self-signed-certificate" >}}) documentation for details. However, adding your CA to `kiali-cabundle` under `additional-ca-bundle.pem` achieves the same result.
{{% /alert %}}

### On OpenShift

On OpenShift, the Kiali Operator automatically creates the `kiali-cabundle` ConfigMap with the annotation `service.beta.openshift.io/inject-cabundle: "true"`. This tells OpenShift to automatically inject the cluster's service CA into the ConfigMap.

This means that by default, Kiali on OpenShift already trusts:
- The system CAs
- The OpenShift service CA (used by services with serving certificates)

If you need to add additional CAs beyond the OpenShift service CA, you can edit the ConfigMap to add your CAs:

```bash
kubectl edit configmap kiali-cabundle -n istio-system
```

Add your CA certificates under the `additional-ca-bundle.pem` key (the OpenShift-injected `service-ca.crt` key will remain and continue to work).

## How It Works

When Kiali starts, it loads certificates from:

1. **System certificate pool**: The default trusted CAs from the container's operating system
2. **Additional CA bundle**: Certificates from `/kiali-cabundle/additional-ca-bundle.pem` (if present)
3. **OpenShift service CA** (OpenShift only): Certificates from `/kiali-cabundle/service-ca.crt` (automatically injected)
4. **OpenID server CA** (OpenID auth only): Certificates from `/kiali-cabundle/openid-server-ca.crt` (if present)

All these certificates are combined into a single certificate pool used for all HTTPS connections to external services.

{{% alert color="success" %}}
**Automatic refresh**: Kiali watches CA bundle files for changes using filesystem notifications (fsnotify) and automatically refreshes the certificate pool without requiring a pod restart. When you update the ConfigMap, Kubernetes propagates the changes to the mounted volume based on the kubelet's sync interval (default: 60 seconds). Once the files are updated on disk, Kiali detects and applies them immediately. Total propagation time is typically 0-90 seconds after the ConfigMap update.
{{% /alert %}}

## Skipping Certificate Verification

If you need to temporarily skip certificate verification (for testing purposes only), you can set `insecure_skip_verify: true` in the authentication configuration for each external service:

```yaml
spec:
  external_services:
    prometheus:
      auth:
        insecure_skip_verify: true
    grafana:
      auth:
        insecure_skip_verify: true
    tracing:
      auth:
        insecure_skip_verify: true
```

{{% alert color="danger" %}}
**Security warning**: Disabling certificate verification makes Kiali vulnerable to man-in-the-middle attacks. Only use this option for testing purposes, never in production.
{{% /alert %}}

## Common Scenarios

### Internal Corporate CA

If your organization has an internal CA that issues certificates for internal services:

1. Obtain the root CA certificate (public part only) from your security team
2. Create the ConfigMap with the CA certificate as shown above

### Self-Signed Certificates

For development or testing environments using self-signed certificates:

1. Export the certificate from your service (usually the same certificate that was generated)
2. Create the ConfigMap with that certificate

### Istio Service Mesh mTLS

If your external services are part of the Istio service mesh and use Istio's mTLS:

- Kiali typically accesses these services through their Kubernetes service names, which may bypass the sidecar
- If you need to go through the mesh, you may need to add Istio's root CA to the bundle

### cert-manager Issued Certificates

If you use cert-manager with a private CA:

1. The CA certificate is typically stored in a Secret (e.g., `my-ca-secret` with key `ca.crt`)
2. Extract the CA and add it to the ConfigMap:

```bash
kubectl get secret my-ca-secret -n cert-manager -o jsonpath='{.data.ca\.crt}' | base64 -d > ca.crt
kubectl create configmap kiali-cabundle -n istio-system --from-file=additional-ca-bundle.pem=ca.crt
```

## Troubleshooting

### Certificate Errors in Logs

If you see errors like `x509: certificate signed by unknown authority` in Kiali logs:

1. Verify the ConfigMap exists and has the correct name
2. Check that the key is exactly `additional-ca-bundle.pem`
3. Ensure the certificate is in valid PEM format
4. Verify the CA certificate is the correct one (the root or intermediate CA that signed the service's certificate)

### Verifying the ConfigMap is Mounted

Check that the ConfigMap is properly mounted in the Kiali pod:

```bash
kubectl exec -n istio-system deploy/kiali -- ls -la /kiali-cabundle/
```

You should see your CA bundle file listed.

### Testing Certificate Chain

To verify your CA certificate is correct, you can test it outside of Kiali:

```bash
# Get the server's certificate chain
openssl s_client -connect prometheus.istio-system:9090 -showcerts

# Verify against your CA
openssl verify -CAfile your-ca.pem server-cert.pem
```