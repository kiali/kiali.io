
---
title: Security Bulletins
linkTitle: Security Bulletins
type: docs
weight: 2
---

{{% alert color="info" %}}
NOTE: Kiali takes security seriously and encourages users to report security concerns.

If you run a security scan on Kiali software and would like to report a security scan report to the Kiali team, we only ask that you first verify that your scan is correctly validating the latest release and that the results are valid.  Security report investigation often takes priority over scheduled work and can be time consuming for the Kiali maintainers to research and validate.  So, please verify that your submitted report accurately reflects the Kiali software being scanned, and that the reported security issue(s) actually affect Kiali or one of its dependencies.
{{% /alert %}}

Kiali releases every three weeks and so generally resolves CVEs in new releases only.  Golang vulnerabilities are typically resolved in a timely way, as the Go version for release builds increments fairly often. Occasionally, critical CVEs may be resolved in patch releases for supported versions.  Additionally, not every CVE reported against a Kiali dependency is actually a vulnerability.  For reported CVEs that are proven not to affect Kiali, see the table below:

{{<security-cve-table>}}

<br />

For Kiali-specific vulnerabilities there will be releases made as needed.  At release time a security bulletin will be release as well. For prior bulletins see below:

