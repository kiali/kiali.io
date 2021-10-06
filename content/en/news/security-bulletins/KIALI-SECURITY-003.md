---
title: "KIALI-SECURITY-003 - Installation into ad-hoc namespaces"
date: 2021-05-11T11:00:00-06:00
type: docs
weight: -3
---

## Description

* **Disclosure date**: May 11, 2021
* **Affected Releases**: prior to 1.33.0
* **Impact Score**: [6.6 - AV:N/AC:L/PR:H/UI:N/S:C/C:L/I:L/A:L](https://nvd.nist.gov/vuln-metrics/cvss/v3-calculator?vector=AV:N/AC:L/PR:H/UI:N/S:C/C:L/I:L/A:L&version=3.1)

A vulnerability was found in the Kiali Operator allowing installation of a specified image into any namespace.

Kiali users are exposed to this vulnerability if all the following conditions are met:

* Kiali operator is used for installation.
* Kiali CR was edited to install an image into an unapproved namespace.

This vulnerability is filed as
[CVE-2021-3495](https://access.redhat.com/security/cve/CVE-2021-3495)

## Mitigation

If you can update:

* Update to Kiali Operator v1.33.0 or later.

If you can not update:

* Ensure only trusted individuals can create or edit a Kiali CRs (resources of kind "kiali").

