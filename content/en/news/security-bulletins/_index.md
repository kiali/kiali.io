
---
title: Security Bulletins
linkTitle: Security Bulletins
type: docs
weight: 2
---

{{% alert color="info" %}}
NOTE: Kiali takes security seriously and encourages users to report security concerns.

If you run a security scan on Kiali software and would like to report a security scan report to the Kiali team, we only ask that you first verify that your scan is correctly validating the latest release and that the results are valid. Because the Kiali team takes security reports seriously, they often take priority over current work being done, and it takes the Kiali team a long time to research and validate them. So please make sure you verify that any reports you submit are reporting an accurate reflection of the Kiali software being scanned and that the security issues being reported actually affect Kiali or one of its dependencies.
{{% /alert %}}

Kiali releases every three weeks and so generally resolves CVEs in new releases only.  Golang vulnerabilities are typically resolved in a timely way, as the Go version for release builds increments fairly often. Occasionally, critical CVEs may be resolved in patch releases for supported versions.  Additionally, not every CVE reported against a Kiali dependency is actually a vulnerability.  For reported CVEs that are proven not to affect Kiali, see the table below:

{{<security-cve-table>}}

<br />

For Kiali-specific vulnerabilities there will be releases made as needed.  At release time a security bulletin will be release as well. For prior bulletins see below:

