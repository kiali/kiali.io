---
title: "TLS Policy"
description: "How Kiali enforces TLS versions, cipher suites, and group preferences for its own server and all outbound clients."
---

Kiali uses one TLS policy for both its inbound server endpoint and every outbound client it creates—HTTP, gRPC, tracing exporters, and OpenID/OAuth HTTP flows. The policy controls TLS versions, cipher suites, and key exchange groups. It is configured in `deployment.tls_config` in the Kiali CR. You decide whether the policy comes from the cluster (OpenShift TLSSecurityProfile) or from explicit settings.

## Configuration Options

| Setting | Description |
|---------|-------------|
| `source` | `auto` (OpenShift only: reads cluster TLSSecurityProfile) or `config` (use explicit settings) |
| `min_version` | Minimum TLS version: `TLSv1.2` or `TLSv1.3` |
| `max_version` | Maximum TLS version: `TLSv1.2` or `TLSv1.3` |
| `cipher_suites` | List of OpenSSL cipher names for TLS 1.2 (ignored for TLS 1.3) |
| `groups` | List of TLS group names (key exchange mechanisms) for both TLS 1.2 and 1.3 |
&nbsp;

### Platform Defaults

- **OpenShift**: `source` defaults to `auto` (uses cluster's TLSSecurityProfile)
- **Non-OpenShift**: `source` defaults to `config` (requires explicit configuration)

## Examples

### OpenShift: Auto-Discover TLS Policy

On OpenShift, set `source: auto` to have Kiali automatically read and enforce the cluster's TLSSecurityProfile from `APIServer/cluster`:

```yaml
spec:
  deployment:
    tls_config:
      source: auto
```

With this configuration, Kiali reads the TLS settings from OpenShift's API Server and enforces them for all connections. If the cluster profile changes, restart the Kiali pod to pick up the new settings.

### Non-OpenShift: Explicit TLS 1.2 and 1.3

For non-OpenShift clusters, or when you want full control over TLS settings, use `source: config` with explicit values:

```yaml
spec:
  deployment:
    tls_config:
      source: config
      min_version: TLSv1.2
      max_version: TLSv1.3
      cipher_suites:
      - ECDHE-RSA-AES128-GCM-SHA256
      - ECDHE-ECDSA-AES128-GCM-SHA256
      - ECDHE-RSA-AES256-GCM-SHA384
      - ECDHE-ECDSA-AES256-GCM-SHA384
      groups:
      - X25519
      - secp256r1
      - secp384r1
```

This allows both TLS 1.2 and TLS 1.3 connections. The cipher suites apply only to TLS 1.2 connections; TLS 1.3 uses a fixed cipher set. Groups apply to both TLS 1.2 and TLS 1.3 handshakes.

### Restrict Key Exchange Groups

To enforce specific key exchange groups, including post-quantum hybrid support:

```yaml
spec:
  deployment:
    tls_config:
      source: config
      min_version: TLSv1.3
      groups:
      - X25519MLKEM768
      - X25519
```

This restricts key exchange to only the listed groups. `X25519MLKEM768` is a post-quantum hybrid mechanism that provides protection against future quantum attacks while maintaining compatibility with current systems.

### TLS 1.3 Only

To enforce TLS 1.3 exclusively (highest security):

```yaml
spec:
  deployment:
    tls_config:
      source: config
      min_version: TLSv1.3
```

When `min_version` is TLS 1.3, Kiali enforces TLS 1.3-only mode. The `cipher_suites` setting is ignored because TLS 1.3 cipher selection is fixed. Groups still apply if specified.

### Secure Defaults (Minimal Configuration)

If you set `source: config` without specifying other values, Kiali applies secure defaults:

```yaml
spec:
  deployment:
    tls_config:
      source: config
```

This enforces TLS 1.2 or higher with Kiali's secure default cipher list for TLS 1.2 connections:

- `ECDHE-ECDSA-AES128-GCM-SHA256`
- `ECDHE-RSA-AES128-GCM-SHA256`
- `ECDHE-ECDSA-AES256-GCM-SHA384`
- `ECDHE-RSA-AES256-GCM-SHA384`
- `ECDHE-ECDSA-CHACHA20-POLY1305`
- `ECDHE-RSA-CHACHA20-POLY1305`

These ciphers use ECDHE for forward secrecy and support both ECDSA and RSA certificates with modern AEAD encryption (AES-GCM and ChaCha20-Poly1305).

When `groups` is not specified, Kiali uses its built-in defaults which include post-quantum key exchange.

## Supported Values

### TLS Versions

TLS 1.0 and 1.1 are **not supported** due to known security vulnerabilities. Attempting to use them will cause Kiali to fail at startup.

Supported version strings (case variations accepted):
- `TLSv1.2` / `TLS1.2` / `VersionTLS12`
- `TLSv1.3` / `TLS1.3` / `VersionTLS13`

### TLS 1.2 Cipher Suites

Specify cipher suites using OpenSSL names:

| Cipher Suite |
|--------------|
| `ECDHE-RSA-AES128-GCM-SHA256` |
| `ECDHE-ECDSA-AES128-GCM-SHA256` |
| `ECDHE-RSA-AES256-GCM-SHA384` |
| `ECDHE-ECDSA-AES256-GCM-SHA384` |
| `ECDHE-RSA-CHACHA20-POLY1305` |
| `ECDHE-ECDSA-CHACHA20-POLY1305` |
| `AES128-GCM-SHA256` |
| `AES256-GCM-SHA384` |
&nbsp;

Unsupported cipher names will cause validation failure at startup.

### TLS Groups

Groups control which key exchange mechanisms are allowed during the TLS handshake:

| Group | Description |
|-------|-------------|
| `X25519` | Curve25519 |
| `secp256r1` | NIST P-256 |
| `secp384r1` | NIST P-384 |
| `secp521r1` | NIST P-521 |
| `X25519MLKEM768` | Post-quantum hybrid |
| `SecP256r1MLKEM768` | Post-quantum hybrid |
| `SecP384r1MLKEM1024` | Post-quantum hybrid |
&nbsp;

Unsupported group names are skipped with a warning. Kiali refuses to start only if all specified groups are unsupported.

## Behavior

### Fail-Fast Safety

Kiali refuses to start if:
- The `source` value is invalid
- `source=auto` is used on a non-OpenShift cluster
- The OpenShift TLSSecurityProfile cannot be read
- An unsupported TLS version or cipher suite is specified
- All specified groups are unsupported (no usable key exchange mechanisms)

### Enforcement Scope

The resolved TLS policy applies to:
- Kiali server's inbound TLS configuration
- All outbound HTTP clients (Prometheus, Grafana, tracing exporters, auth flows)
- All outbound gRPC clients

TLS versions and cipher suites apply to TLS 1.2 connections. Groups apply to both TLS 1.2 and TLS 1.3 handshakes.

### Skip-Verify Behavior

Disabling TLS certificate verification on external services (e.g., `insecure_skip_verify`) only bypasses certificate validation. TLS versions, cipher suites, and groups are still enforced according to the policy.

### Policy Refresh

The TLS policy is resolved **once at startup** and cached for the lifetime of the Kiali process. When using `source=auto`, if the OpenShift TLSSecurityProfile changes, you must **restart the Kiali pod** for changes to take effect.

## Logging

On startup, Kiali logs which TLS policy source is active and the resolved min/max versions, cipher count, and groups count. Check these logs to verify the policy in effect or troubleshoot startup failures.
