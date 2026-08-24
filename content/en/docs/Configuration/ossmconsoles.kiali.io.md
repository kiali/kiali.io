---
title: OSSMConsole CR Reference
linkTitle: OSSMConsole CR Reference
description: |
  Reference page for the OSSMConsole CR.
  The Kiali Operator will watch for a resource of this type and install the OSSM Console plugin according to that resource's configuration. Only one resource of this type should exist at any one time.
technical_name: ossmconsoles.kiali.io
source_repository: https://github.com/kiali/kiali-operator
source_repository_ref: master
---



<div class="crd-schema-version">


<h3 id="example-cr">Example CR</h3>
<em>(all values shown here are the defaults unless otherwise noted)</em>

```yaml
apiVersion: kiali.io/v1alpha1
kind: OSSMConsole
metadata:
  name: ossmconsole
  annotations:
    ansible.sdk.operatorframework.io/verbosity: "1"
spec:
  version: "default"

  deployment:
    imageDigest: ""
    imageName: ""
    imagePullPolicy: "IfNotPresent"
    # default: image_pull_secrets is an empty list
    imagePullSecrets: ["image.pull.secret"]
    imageVersion: ""
    namespace: ""

  # default: internal is an empty object (techPreview is disabled)
  # internal:
  #   techPreview: true

  kiali:
    autoDiscover: true
    serviceName: ""
    serviceNamespace: ""
    servicePort: 0
```


### Validating your OSSMConsole CR

The OSSMConsole CR has a CRD Schema so it will be validated when you create or update it in your cluster.

<h3 id="property-details">Properties</h3>


<div class="property depth-0">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec">.spec</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>This is the CRD for the resources called OSSMConsole CRs. The OpenShift Service Mesh Console Operator will watch for resources of this type and when it detects an OSSMConsole CR has been added, deleted, or modified, it will install, uninstall, and update the associated OSSM Console installation.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment">.spec.deployment</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.imageDigest">.spec.deployment.imageDigest</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>If <code>deployment.imageVersion</code> is a digest hash, this value indicates what type of digest it is. A typical value would be &lsquo;sha256&rsquo;. Note: do NOT prefix this value with a &lsquo;@&rsquo;.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.imageName">.spec.deployment.imageName</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Determines which OSSM Console image to download and install. If you set this to a specific name (i.e. you do not leave it as the default empty string), you must make sure that image is supported by the operator. If empty, the operator will use a known supported image name based on which <code>version</code> was defined. Note that, as a security measure, a cluster admin may have configured the operator to ignore this setting. A cluster admin may do this to ensure the operator only installs a single, specific OSSM Console version, thus this setting may have no effect depending on how the operator itself was configured.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.imagePullPolicy">.spec.deployment.imagePullPolicy</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The Kubernetes pull policy for the OSSM Console deployment. This is overridden to be &lsquo;Always&rsquo; if <code>deployment.imageVersion</code> is set to &lsquo;latest&rsquo;.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.imagePullSecrets">.spec.deployment.imagePullSecrets</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(array)</span>

</div>

<div class="property-description">
<p>The names of the secrets to be used when container images are to be pulled.</p>

</div>

</div>
</div>

<div class="property depth-3">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.imagePullSecrets[*]">.spec.deployment.imagePullSecrets[*]</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.imageVersion">.spec.deployment.imageVersion</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>Determines which version of OSSM Console to install.
Choose &lsquo;lastrelease&rsquo; to use the last OSSM Console release.
Choose &lsquo;latest&rsquo; to use the latest image (which may or may not be a released version of the OSSM Console).
Choose &lsquo;operator_version&rsquo; to use the image whose version is the same as the operator version.
Otherwise, you can set this to any valid OSSM Console version (such as &lsquo;v1.0&rsquo;) or any valid OSSM Console
digest hash (if you set this to a digest hash, you must indicate the digest in <code>deployment.imageDigest</code>).
Note that if this is set to &lsquo;latest&rsquo; then the <code>deployment.imagePullPolicy</code> will be set to &lsquo;Always&rsquo;.
If you set this to a specific version (i.e. you do not leave it as the default empty string),
you must make sure that image is supported by the operator.
If empty, the operator will use a known supported image version based on which &lsquo;version&rsquo; was defined.
Note that, as a security measure, a cluster admin may have configured the operator to
ignore this setting. A cluster admin may do this to ensure the operator only installs
a single, specific OSSM Console version, thus this setting may have no effect depending on how the
operator itself was configured.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.deployment.namespace">.spec.deployment.namespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The namespace into which OSSM Console is to be installed. If this is empty or not defined, the default will be the namespace where the OSSMConsole CR is located. Currently the only namespace supported is the namespace where the OSSMConsole CR is located.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.internal">.spec.internal</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>Unstructured section for internal testing and debugging features. Not officially supported - fields here may change or be removed without notice.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali">.spec.kiali</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali.autoDiscover">.spec.kiali.autoDiscover</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(boolean)</span>

</div>

<div class="property-description">
<p>Controls whether the operator will opportunistically auto-discover a Kiali installation via its OpenShift Route when none of <code>kiali.serviceName</code>, <code>kiali.serviceNamespace</code>, and <code>kiali.servicePort</code> are set. If those three settings are all empty and this is set to <code>false</code>, OSSM Console is installed without Kiali integration rather than attempting discovery. This setting has no effect if all three of <code>kiali.serviceName</code>, <code>kiali.serviceNamespace</code>, and <code>kiali.servicePort</code> are explicitly set (auto-discovery is already skipped in that case, and the explicitly configured Kiali installation is used). Setting this to <code>false</code> while only some (not all, and not none) of those three settings are specified is invalid and will fail reconciliation. Defaults to <code>true</code>.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali.serviceName">.spec.kiali.serviceName</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The internal Kiali service that the OpenShift Console will use to proxy API calls. If empty and <code>kiali.autoDiscover</code> is <code>true</code> (the default), an attempt will be made to auto-discover it from the Kiali OpenShift Route. If none of <code>kiali.serviceName</code>, <code>kiali.serviceNamespace</code>, and <code>kiali.servicePort</code> are set and no Kiali installation can be auto-discovered (or <code>kiali.autoDiscover</code> is <code>false</code>), OSSM Console will still be installed, but without Kiali integration. If any of these three settings are explicitly set, a Kiali installation matching that configuration is required and the install will fail if it cannot be found or its version does not match. See <code>kiali.autoDiscover</code> for what happens when only some (not all) of these three settings are specified.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali.serviceNamespace">.spec.kiali.serviceNamespace</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The namespace where the Kiali service is deployed. If empty and <code>kiali.autoDiscover</code> is <code>true</code> (the default), an attempt will be made to auto-discover it from the Kiali OpenShift Route. It will assume that the OpenShift Route and the Kiali service are deployed in the same namespace. If none of <code>kiali.serviceName</code>, <code>kiali.serviceNamespace</code>, and <code>kiali.servicePort</code> are set and no Kiali installation can be auto-discovered (or <code>kiali.autoDiscover</code> is <code>false</code>), OSSM Console will still be installed, but without Kiali integration. If any of these three settings are explicitly set, a Kiali installation matching that configuration is required and the install will fail if it cannot be found or its version does not match. See <code>kiali.autoDiscover</code> for what happens when only some (not all) of these three settings are specified.</p>

</div>

</div>
</div>

<div class="property depth-2">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.kiali.servicePort">.spec.kiali.servicePort</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(integer)</span>

</div>

<div class="property-description">
<p>The internal port used by the Kiali service for the API. If empty and <code>kiali.autoDiscover</code> is <code>true</code> (the default), an attempt will be made to auto-discover it from the Kiali OpenShift Route. If none of <code>kiali.serviceName</code>, <code>kiali.serviceNamespace</code>, and <code>kiali.servicePort</code> are set and no Kiali installation can be auto-discovered (or <code>kiali.autoDiscover</code> is <code>false</code>), OSSM Console will still be installed, but without Kiali integration. If any of these three settings are explicitly set, a Kiali installation matching that configuration is required and the install will fail if it cannot be found or its version does not match. See <code>kiali.autoDiscover</code> for what happens when only some (not all) of these three settings are specified.</p>

</div>

</div>
</div>

<div class="property depth-1">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".spec.version">.spec.version</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(string)</span>

</div>

<div class="property-description">
<p>The version of the Ansible role that will be executed in order to install OSSM Console.
This also indirectly determines the version of OSSM Console that will be installed.
You normally will want to use <code>default</code> since this is the only officially supported value today.</p>

<p>If not specified, the value of <code>default</code> is assumed which means the most recent Ansible role is used;
thus the most recent release of OSSM Console will be installed.</p>

<p>Refer to this file to see what the valid values are for this <code>version</code> field (as defined in the master branch),
<a href="https://github.com/kiali/kiali-operator/blob/master/playbooks/ossmconsole-default-supported-images.yml">https://github.com/kiali/kiali-operator/blob/master/playbooks/ossmconsole-default-supported-images.yml</a></p>

<p>This <code>version</code> setting affects the defaults of the <code>deployment.imageName</code> and
<code>deployment.imageVersion</code> settings. See the documentation for those settings below for
additional details. In short, this <code>version</code> setting will dictate which version of the
OSSM Console image will be deployed by default. However, if you explicitly set <code>deployment.imageName</code>
and/or <code>deployment.imageVersion</code> to reference your own custom image, that will override the
default OSSM Console image to be installed; therefore, you are responsible for ensuring those settings
are compatible with the Ansible role that will be executed in order to install OSSM Console (i.e. your
custom OSSM Console image must be compatible with the rest of the configuration and resources the
operator will install).</p>

</div>

</div>
</div>

<div class="property depth-0">
<div class="property-header">
<hr/>
<h3 class="property-path" id=".status">.status</h3>
</div>
<div class="property-body">
<div class="property-meta">
<span class="property-type">(object)</span>

</div>

<div class="property-description">
<p>The processing status of this CR as reported by the OpenShift Service Mesh Console Operator.</p>

</div>

</div>
</div>





</div>



