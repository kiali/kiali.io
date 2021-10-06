---
title: "KIALI-SECURITY-002 - Authentication bypass when using the OpenID login strategy"
date: 2021-03-4T11:00:00-06:00
type: docs
weight: -2
---

## Description

* **Disclosure date**: March 5, 2021
* **Affected Releases**: 1.26.0, 1.26.1, 1.26.2, 1.27.0, 1.28.0, 1.28.1, 1.29.0, 1.29.1, 1.30.0
* **Impact Score**: [7.0 - AV:N/AC:L/PR:N/UI:N/S:C/C:L/I:L/A:N/E:F/RL:X/RC:C](https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator?vector=AV:N/AC:L/PR:N/UI:N/S:C/C:L/I:L/A:N/E:F/RL:X/RC:C&version=3.1)

A vulnerability was found in Kiali allowing an attacker to bypass the
authentication mechanism. The vulnerability lets an attacker build forged
credentials and use them to gain unauthorized access to Kiali.

Kiali users are exposed to this vulnerability if all the following conditions are met:

* Kiali is setup with the `openid` authentication strategy.
* As a result of configurations in both Kiali and your OpenID server, Kiali uses the
  _implicit flow_ of the OpenID specification to negotiate authentication.
* Kiali is setup with RBAC turned off.

This vulnerability is filed as
[CVE-2021-20278](https://access.redhat.com/security/cve/CVE-2021-20278)

## Mitigation

If you can update:

* Update to Kiali v1.31.0 or later.
* If you need an earlier version, only Kiali 1.26.3 and 1.29.2 are fixed.

If you are locked with an older version of Kiali, you have three options:

* Configure Kiali to use the _authorization code_ flow of the OpenID specification; or
* Configure Kiali to use the _implicit flow_ of the OpenID specification *and* enable RBAC; or
* Configure Kiali to use any of the other available authentication mechanisms.

