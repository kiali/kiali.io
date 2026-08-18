---
title: "The OSSMConsole CR"
description: "Creating and updating the OSSMConsole CR."
weight: 45
---

OpenShift ServiceMesh Console (aka OSSMC) provides a Kiali integration with the OpenShift Console; in other words it provides Kiali functionality within the context of the OpenShift Console when a Kiali server is connected to the plugin. OSSMC is applicable only within OpenShift environments.

The main component of OSSMC is a plugin that gets installed inside the OpenShift Console. Prior to installing this plugin, you must install the Kiali Operator. A Kiali Server is optional for the initial plugin install — without it, OSSMC still provides **Istios** and **Kialis** pages for navigating multiple mesh instances from the console. See [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/). Please see the [Installation Guide](/docs/installation/installation-guide/) for Kiali Operator installation details.

{{% alert color="warning" %}}
There are no helm charts available to install OSSMC. You must utilize the Kiali Operator to install it. Installing the Kiali Operator on OpenShift is very easy due to the Operator Lifecycle Manager (OLM) functionality that comes with OpenShift out-of-box. Simply elect to install the Kiali Operator from the Red Hat or Community Catalog from the OperatorHub page in OpenShift Console.
{{% /alert %}}

The Kiali Operator watches the _OSSMConsole Custom Resource_ ([OSSMConsole CR](/docs/configuration/ossmconsoles.kiali.io)), a custom resource that contains the OSSMC deployment configuration. Creating, updating, or removing a OSSMConsole CR will trigger the Kiali Operator to install, update, or remove OSSMC.

{{% alert color="warning" %}}
*Never* manually edit resources created by the Kiali Operator, only edit the OSSMConsole CR.
{{% /alert %}}

## Creating the OSSMConsole CR to Install the OSSMC Plugin

With the Kiali Operator installed, you can install the OSSMC plugin in one of two ways — either via the OpenShift Console or via the `oc` CLI. Both methods are described below. You choose the method you want to use.

A Kiali Server is not required for installation. If no Kiali instance is connected to the plugin, OSSMC provides **Istios** and **Kialis** for multi-mesh navigation in the console (see [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/)). To enable Kiali-powered observability pages, connect a Kiali instance after installation — see [Connecting a Kiali instance to the console](#connecting-a-kiali-instance-to-the-console) below.

{{% alert color="warning" %}}
When a Kiali server is connected to the plugin (a Kiali instance is connected or auto-discovered), you should specify the `spec.version` field of the OSSMConsole CR, and its value must be the same version as that of the Kiali Server (i.e. it must match the `spec.version` of the Kiali Server's Kiali CR). Normally, you can just set `spec.version` to `default` which tells the Kiali Operator to install OSSMC whose version is the same as that of the operator itself. Alternatively, you may specify one of the
[supported versions](https://github.com/kiali/kiali-operator/blob/master/playbooks/ossmconsole-default-supported-images.yml) in the format `vX.Y`.

This version matching requirement does not apply when OSSMC is used without a connected Kiali server.
{{% /alert %}}

### Installing via OpenShift Console

From the Kiali Operator details page in the OpenShift Console, create an instance of the "OpenShift Service Mesh Console" resource. Accept the defaults on the installation form and press "Create".

![Install Plugin](/images/documentation/ossmc/01-ui-install-cr.png)

### Installing via "oc" CLI

To instruct the Kiali Operator to install the plugin, simply create a small OSSMConsole CR. A minimal CR can be created like this:

```bash
cat <<EOM | oc apply -f -
apiVersion: kiali.io/v1alpha1
kind: OSSMConsole
metadata:
  namespace: openshift-operators
  name: ossmconsole
spec:
  version: default
EOM
```

Note that the operator will deploy the plugin resources in the same namespace where you create this OSSMConsole CR - in this case `openshift-operators` but you can create the CR in any namespace.

For a complete list of configuration options available within the OSSMConsole CR, see the [OSSMConsole CR Reference](/docs/configuration/ossmconsoles.kiali.io).

To confirm your OSSMConsole CR is valid, you can utilize the [OSSMConsole CR validation tool](/docs/configuration/ossmconsoles.kiali.io/#validating-your-ossmconsole-cr).

### Installation Status

After the plugin is installed, you can see the "OSSMConsole" resource that was created in the OpenShift Console UI. Within the operator details page in the OpenShift Console UI, select the _OpenShift Service Mesh Console_ tab to view the resource that was created and its status. The CR status field will provide you with any error messages should the deployment of OSSMC fail.

![Installed Plugin](/images/documentation/ossmc/02-ui-installed-cr.png)

Once the operator has finished processing the OSSMConsole CR, you must then wait for the OpenShift Console to load and initialize the plugin. This may take a minute or two. You will know when the plugin is ready when the OpenShift Console pops up this message - when you see this message, refresh the browser window to reload the OpenShift Console:

![Plugin Ready](/images/documentation/ossmc/03-ui-installed-cr-plugin-ready.png)

## Installing without a connected Kiali server

You can install OSSMC without connecting a Kiali server to the plugin. In that case, the Service Mesh menu provides **Istio control planes** and **Kiali instances** so you can navigate multiple mesh instances from the OpenShift Console. See [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/) for what those pages provide.

A minimal OSSMConsole CR is sufficient when no Kiali server exists on the cluster and auto-discovery finds nothing to connect to:

```yaml
apiVersion: kiali.io/v1alpha1
kind: OSSMConsole
metadata:
  name: ossmconsole
  namespace: openshift-operators
spec:
  version: default
```

To leave the plugin disconnected from Kiali explicitly (for example, when Kiali exists on the cluster but should not be used by OSSMC), set `spec.kiali` as follows:

```yaml
spec:
  kiali:
    autoDiscover: false
    serviceName: ""
    serviceNamespace: ""
    servicePort: 0
```

## Connecting a Kiali instance to the console

To enable OSSMC pages that require a Kiali server, connect a Kiali server to the plugin. You can do this in two ways:

1. **OpenShift Console UI** — Open **Service Mesh** → **Kiali instances**, select a Kiali instance, and click **Connect**. This patches the OSSMConsole CR with the Kiali service name and namespace. See [Navigating Multiple Meshes](/docs/ossmc/navigating-multiple-meshes/#kiali-instances) for details.
2. **OSSMConsole CR** — Set `spec.kiali.serviceName`, `spec.kiali.serviceNamespace`, and `spec.kiali.servicePort` to match the Kiali service. Alternatively, leave those fields empty and set `spec.kiali.autoDiscover` to `true` to let the operator discover Kiali from its OpenShift Route.

After connecting, refresh the OpenShift Console if pages that require Kiali do not appear immediately. The Kiali Operator must reconcile the OSSMConsole CR before OSSMC can connect. You may have to wait for a small amount of time and refresh the browser window to see those pages.

## Disconnecting from a Kiali server

To disconnect OSSMC from a Kiali server (**Istio control planes** and **Kiali instances** remain available for multi-mesh navigation):

1. **OpenShift Console UI** — On the **Kiali instances** detail page for the connected instance, click **Disconnect**.
2. **OSSMConsole CR** — Set `spec.kiali.autoDiscover` to `false` and clear `spec.kiali.serviceName`, `spec.kiali.serviceNamespace`, and set `spec.kiali.servicePort` to `0`.

## Uninstalling OSSMC

This section will describe how to uninstall the OpenShift Service Mesh Console plugin. You can uninstall the plugin in one of two ways - either via the OpenShift Console or via the "oc" CLI. Both methods are described in the sections below. You choose the method you want to use.

{{% alert color="warning" %}}
If you intend to also uninstall the Kiali Operator, it is very important to first uninstall the OSSMConsole CR and then uninstall the operator. If you uninstall the operator before ensuring the OSSMConsole CR is deleted then you may have difficulty removing that CR and its namespace. If this occurs then you must manually remove the finalizer on the CR in order to delete it and its namespace. You can do this via: `oc patch ossmconsoles <CR name> -n <CR namespace> -p '{"metadata":{"finalizers": []}}' --type=merge `
{{% /alert %}}

### Uninstalling via OpenShift Console

Remove the OSSMConsole CR by navigating to the operator details page in the OpenShift Console UI. From the operator details page, select the _OpenShift Service Mesh Console_ tab and then select the Delete option in the kebab menu.

![Uninstall Plugin](/images/documentation/ossmc/04-ui-uninstall-cr.png)

### Uninstalling via "oc" CLI

Remove the OSSMConsole CR via `oc delete ossmconsoles <CR name> -n <CR namespace>`. To make sure any and all CRs are deleted from any and all namespaces, you can run this command:

```sh
for r in $(oc get ossmconsoles --ignore-not-found=true --all-namespaces -o custom-columns=NS:.metadata.namespace,N:.metadata.name --no-headers | sed 's/  */:/g'); do oc delete ossmconsoles -n $(echo $r|cut -d: -f1) $(echo $r|cut -d: -f2); done
```
