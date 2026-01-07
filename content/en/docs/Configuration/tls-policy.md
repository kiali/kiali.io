---
title: "TLS Policy"
description: "How Kiali enforces TLS versions and cipher suites for its own server and all outbound clients."
---

## Overview
Kiali uses one TLS policy for both its inbound server endpoint and every outbound client it creates—HTTP, gRPC, tracing exporters, and OpenID/OAuth HTTP flows. The policy lives in `deployment.tls_config` in the Kiali CR. You decide whether the policy comes from the cluster (OpenShift TLSSecurityProfile) or from explicit settings. If the configuration is invalid or the profile cannot be read, Kiali fails fast rather than silently relaxing TLS.

## Configuration
- `deployment.tls_config.source` (required) accepts `auto` or `config`. If `auto`, Kiali (on OpenShift) reads and enforces `APIServer/cluster` `spec.tlsSecurityProfile`; startup fails on read errors or when running on non-OpenShift clusters. If `config`, Kiali skips auto-discovery and uses only the explicit values you set.
- `deployment.tls_config.min_version` and `max_version` set the allowed TLS versions (for example, `TLSv1.2` or `TLSv1.3`). When you select TLS 1.3, Kiali sets both Min and Max to TLS 1.3 and ignores `cipher_suites` because the Go TLS 1.3 cipher set is fixed.
- `deployment.tls_config.cipher_suites` lists OpenSSL cipher names for TLS 1.2. Unsupported names fail validation; if you leave this empty, Kiali applies a secure default list.
- If `source=config` is set and the other fields are left empty, Kiali enforces TLS 1.2 or higher and uses its secure default TLS 1.2 cipher list (TLS 1.3 continues to use Go’s fixed ciphers automatically).

### Defaults
- OpenShift: `source=auto` (uses cluster profile).
- Non-OpenShift: `source=config` (explicit configuration).

### Supported values
- TLS versions (TLS 1.0 and 1.1 are **not supported** due to known security vulnerabilities and will cause startup failure):
  - `TLSv1.2` / `TLS1.2` / `VersionTLS12`
  - `TLSv1.3` / `TLS1.3` / `VersionTLS13`
- TLS 1.2 cipher suites (OpenSSL names):
  - `ECDHE-RSA-AES128-GCM-SHA256`
  - `ECDHE-ECDSA-AES128-GCM-SHA256`
  - `ECDHE-RSA-AES256-GCM-SHA384`
  - `ECDHE-ECDSA-AES256-GCM-SHA384`
  - `ECDHE-RSA-CHACHA20-POLY1305`
  - `ECDHE-ECDSA-CHACHA20-POLY1305`
  - `AES128-GCM-SHA256`
  - `AES256-GCM-SHA384`

## Behavior and Enforcement
- Fail-fast safety: Kiali refuses to start if the `source` value is invalid, if `source=auto` is used with non-OpenShift clusters, or if the OpenShift profile cannot be read (error messages will suggest switching to `source=config` when appropriate).
- Enforcement scope: The resolved policy applies to the Kiali server's own TLS configuration and to all outbound HTTP clients (Prometheus, Grafana, tracing exporters, auth flows, etc.) as well as outbound gRPC clients.
- Enforcement rules: The chosen policy sets the TLS min/max versions; TLS 1.3 ignores `cipher_suites`, while TLS 1.2 uses the configured or default cipher list. Skip-verify only bypasses certificate validation—TLS versions and ciphers are still enforced.

## Logging
On startup, Kiali logs which TLS policy source is active and the resolved min/max versions and cipher count. This helps verify the policy in effect and aids troubleshooting when startup fails due to policy errors.
