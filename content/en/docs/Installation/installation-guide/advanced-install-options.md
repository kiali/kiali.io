---
title: "Advanced Install"
description: "Advanced installation options."
weight: 60
---

## Multiple Istio control planes in the same cluster

Currently, Kiali can manage only one Istio control plane. However, there are
certain cases where you may have more than one Istio control plane in your
cluster. One of such cases is when performing a
[Canary upgrade of Istio](https://istio.io/latest/docs/setup/upgrade/canary/).

In these cases, you will need to configure in Kiali which control plane you
want to manage. This is done by configuring the name of the components of the
control plane. This is configured in the Kiali CR and the default values are
the following:

```yaml
spec:
  external_services:
    istio:
      config_map_name: "istio"
      istiod_deployment_name: "istiod"
      istio_sidecar_injector_config_map_name: "istio-sidecar-injector"
```

If you want to manage both Istio control planes, simply install two Kiali
instances and point each one to a different Istio control plane.

## Installing a Kiali Server of a different version than the Operator

When you install the Kiali Operator, it will be configured to install a Kiali
Server that is the same version as the operator itself. For example, if you
have Kiali Operator v1.34.0 installed, that operator will install Kiali Server
v1.34.0. If you upgrade (or downgrade) the Kiali Operator, the operator will in
turn upgrade (or downgrade) the Kiali Server.

There are certain use-cases in which you want the Kiali Operator to install a
Kiali Server whose version is different than the operator version. Read the
following section _<<Using a custom image registry>>_ section to learn how to
configure this setup.

## Using a custom image registry

Kiali is released and published to the [Quay.io container image registry](https://quay.io/). There is a [repository hosting the Kiali operator images](https://quay.io/repository/kiali/kiali-operator) and [another one for the Kiali server images](https://quay.io/repository/kiali/kiali).

If you need to mirror the Kiali container images to some other registry, you still can use Helm to install the Kiali operator as follows:

```
$ helm install \
    --namespace kiali-operator \
    --create-namespace \
    --set image.repo=your.custom.registry/owner/kiali-operator-repo
    --set image.tag=your_custom_tag
    --set allowAdHocKialiImage=true
    kiali-operator \
    kiali/kiali-operator
```

{{% alert color="warning" %}}
Notice the `--set allowAdHocKialiImage=true` which allows specifying a
custom image in the Kiali CR. For security reasons, this is disabled by
default.
{{% /alert %}}

Then, when creating the Kiali CR, use the following attributes:

```yaml
spec:
  deployment:
    image_name: your.custom.registry/owner/kiali-server-repo
    image_version: your_custom_tag
```

### Change the default image

As explained earlier, when you install the Kiali Operator, it will be
configured to install a Kiali Server whose image will be pulled from quay.io
and whose version will be the same as the operator. You can ask the operator to
use a different image by setting `spec.deployment.image_name` and
`spec.deployment.image_version` within the Kiali CR (as explained above).

However, you may wish to alter this default behavior exhibited by the operator.
In other words, you may want the operator to install a different Kiali Server
image by default. For example, if you have an air-gapped environment with its
own image registry that contains its own copy of the Kiali Server image, you
will want the operator to install a Kiali Server that uses that image by
default, as opposed to `quay.io/kiali/kiali`. By configuring the operator to do
this, you will not force the authors of Kiali CRs to have to explicitly define
the `spec.deployment.image_name` setting and you will not need to enable the
`allowAdHocKialiImage` setting in the operator.

To change the default Kiali Server image installed by the operator, set the
environment variable `RELATED_IMAGE_kiali_default` in the Kiali Operator
deployment.  The value of that environment variable must be the full image tag
in the form `repoName/orgName/imageName:versionString` (e.g.
`my.internal.registry.io/mykiali/mykialiserver:v1.50.0`). You can do this when
you install the operator via helm:

```
$ helm install \
    --namespace kiali-operator \
    --create-namespace \
    --set "env[0].name=RELATED_IMAGE_kiali_default" \
    --set "env[0].value=my.internal.registry.io/mykiali/mykialiserver:v1.50.0" \
    kiali-operator \
    kiali/kiali-operator
```


## Development Install

This option installs the _latest_ Kiali Operator and Kiali Server images which
are built from the master branches of Kiali GitHub repositories. This option is
good for demo and development installations.

```
helm install \
  --set cr.create=true \
  --set cr.namespace=istio-system \
  --set cr.spec.deployment.image_version=latest \
  --set image.tag=latest \
  --namespace kiali-operator \
  --create-namespace \
  kiali-operator \
  kiali/kiali-operator
```
