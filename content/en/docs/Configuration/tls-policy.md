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

{{% alert color="warning" %}}
On OpenShift, `source: config` is rejected by the Kiali Operator when the cluster TLS adherence is strict. See [Cluster TLS Adherence](#cluster-tls-adherence).
{{% /alert %}}

## Examples

### OpenShift: Auto-Discover TLS Policy

On OpenShift, set `source: auto` to have Kiali automatically read and enforce the cluster's TLSSecurityProfile from `APIServer/cluster`:

```yaml
spec:
  deployment:
    tls_config:
      source: auto
```

With this configuration, Kiali reads the TLS settings from OpenShift's API Server and enforces them for all connections. Not every cluster sets a TLS security profile — the `spec.tlsSecurityProfile` field on `APIServer/cluster` is optional. When it is not set, Kiali uses the `Intermediate` profile, which is the same default OpenShift itself applies. The `Intermediate` profile enforces TLS 1.2 or higher, uses the six ECDHE cipher suites for TLS 1.2 connections (the same list as Kiali's [secure defaults](#secure-defaults-minimal-configuration); TLS 1.3 cipher suites are managed by Go and are not configurable), and allows the `X25519MLKEM768`, `X25519`, `secp256r1`, and `secp384r1` key exchange groups.

If the cluster profile changes, the Kiali Operator detects the change and restarts the Kiali pod so the new settings take effect (see [Policy Refresh](#policy-refresh)). If you installed the Kiali Server without the operator (for example, with the server Helm chart), you must restart the pod manually.

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

Note that with an operator-managed install using `source=auto`, if the cluster profile later changes to one Kiali rejects at startup (for example, the `Old` profile, which requires TLS 1.0 or 1.1 that the Kiali Server does not allow), the Kiali Operator still restarts the server but the restarted server will stay in `CrashLoopBackOff` until the cluster profile is valid again.

### Enforcement Scope

The resolved TLS policy applies to:
- Kiali server's inbound TLS configuration
- All outbound HTTP clients (Prometheus, Grafana, tracing exporters, auth flows)
- All outbound gRPC clients

TLS versions and cipher suites apply to TLS 1.2 connections. Groups apply to both TLS 1.2 and TLS 1.3 handshakes.

### Skip-Verify Behavior

Disabling TLS certificate verification on external services (e.g., `insecure_skip_verify`) only bypasses certificate validation. TLS versions, cipher suites, and groups are still enforced according to the policy.

### Policy Refresh

The TLS policy is resolved **once at startup** and cached for the lifetime of the Kiali process. When using `source=auto` and the OpenShift TLSSecurityProfile changes:

- **Operator-managed installs**: the Kiali Operator watches `APIServer/cluster` and restarts the Kiali pod automatically when the TLS security profile changes, so the new policy is picked up without manual action.
- **Other installs** (for example, the Kiali Server Helm chart): you must manually restart the Kiali pod for changes to take effect.

### Cluster TLS Adherence

{{% alert color="info" %}}
This section is specific to OpenShift clusters only.
{{% /alert %}}

OpenShift clusters can set a cluster-wide TLS adherence option (`spec.tlsAdherence` on `APIServer/cluster`) who values can be:

- `LegacyAdheringComponentsOnly` (the default): components *may* honor the cluster TLS security profile but are not required to.
- `StrictAllComponents`: every component *must* honor the cluster TLS security profile.

Kiali always honors the cluster profile when `source` is `auto`, in both adherence modes. But the Kiali CR has an escape hatch: `source: config` overrides the cluster profile with your own TLS settings. Under strict adherence that override is not allowed — the Kiali Operator rejects the Kiali CR: the reconciliation fails with an error message in the CR status, and the running Kiali server deployment is removed rather than serve TLS outside the cluster's policy.

Recovery is automatic. The next successful reconciliation re-creates the deployment once you either set `deployment.tls_config.source` back to `auto` (or remove the setting) or your cluster administrator relaxes the adherence to `LegacyAdheringComponentsOnly`. If strict adherence is enabled after Kiali is already running with `source: config`, the operator stops the server the same way until the configuration is brought back into compliance.

Any adherence value other than exactly `LegacyAdheringComponentsOnly` — including values the operator does not recognize — is treated as strict.

## Logging

On startup, Kiali logs which TLS policy source is active and the resolved min/max versions, cipher count, and groups count. Check these logs to verify the policy in effect or troubleshoot startup failures.
