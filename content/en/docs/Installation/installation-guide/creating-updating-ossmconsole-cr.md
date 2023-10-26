---
title: "The OSSMConsole CR"
description: "Creating and updating the OSSMConsole CR."
weight: 45
---

OpenShift ServiceMesh Console (aka OSSMC) provides a Kiali integration with the OpenShift Console; in other words it provides Kiali functionality within the context of the OpenShift Console. OSSMC is applicable only within OpenShift environments.

The main component of OSSMC is a plugin that gets installed inside the OpenShift Console. Prior to installing this plugin, you are required to have already installed the Kiali Operator and Kiali Server in your OpenShift environment. Please the [Installation Guide](/docs/installation/installation-guide/) for details.

{{% alert color="warning" %}}
There are no helm charts available to install OSSMC. You must utilize the Kiali Operator to install it. Installing the Kiali Operator on OpenShift is very easy due to the Operator Lifecycle Manager (OLM) functionality that comes with OpenShift out-of-box. Simply elect to install the Kiali Operator from the Red Hat or Community Catalog from the OperatorHub page in OpenShift Console.
{{% /alert %}}

The Kiali Operator watches the _OSSMConsole Custom Resource_ ([OSSMConsole CR](/docs/configuration/ossmconsoles.kiali.io)), a custom resource that contains the OSSMC deployment configuration. Creating, updating, or removing a OSSMConsole CR will trigger the Kiali Operator to install, update, or remove OSSMC.

{{% alert color="warning" %}}
*Never* manually edit resources created by the Kiali Operator, only edit the OSSMConsole CR.
{{% /alert %}}

## Creating the OSSMConsole CR to Install the OSSMC Plugin

With the Kiali Operator and Kial Server installed and running, you can install the OSSMC plugin in one of two ways - either via the OpenShift Console or via the "oc" CLI. Both methods are described below. You choose the method you want to use.

### Installing via OpenShift Console

From the Kiali Operator details page in the OpenShift Console, create an instance of the "OpenShift Service Mesh Console" resource. Accept the defaults on the installation form and press "Create".

![Install Plugin](/images/documentation/installation/installation-guide/01-ui-install-cr.png)

### Installing via "oc" CLI

To instruct the Kiali Operator to install the plugin, simply create a small OSSMConsole CR. A minimal CR can be created like this:

```bash
cat <<EOM | oc apply -f -
apiVersion: kiali.io/v1alpha1
kind: OSSMConsole
metadata:
  namespace: openshift-operators
  name: ossmconsole
EOM
```

Note that the operator will deploy the plugin resources in the same namespace where you create this OSSMConsole CR - in this case `openshift-operators` but you can create the CR in any namespace.

For a complete list of configuration options available within the OSSMConsole CR, see the [OSSMConsole CR Reference](/docs/configuration/ossmconsoles.kiali.io).

To confirm your OSSMConsole CR is valid, you can utilize the [OSSMConsole CR validation tool](/docs/configuration/ossmconsoles.kiali.io/#validating-your-ossmconsole-cr).

### Installation Status

After the plugin is installed, you can see the "OSSMConsole" resource that was created in the OpenShift Console UI. Within the operator details page in the OpenShift Console UI, select the _OpenShift Service Mesh Console_ tab to view the resource that was created and its status. The CR status field will provide you with any error messages should the deployment of OSSMC fail.

![Installed Plugin](/images/documentation/installation/installation-guide/02-ui-installed-cr.png)

Once the operator has finished processing the OSSMConsole CR, you must then wait for the OpenShift Console to load and initialize the plugin. This may take a minute or two. You will know when the plugin is ready when the OpenShift Console pops up this message - when you see this message, refresh the browser window to reload the OpenShift Console:

![Plugin Ready](/images/documentation/installation/installation-guide/03-ui-installed-cr-plugin-ready.png)

## Uninstalling OSSMC

This section will describe how to uninstall the OpenShift Service Mesh Console plugin. You can uninstall the plugin in one of two ways - either via the OpenShift Console or via the "oc" CLI. Both methods are described in the sections below. You choose the method you want to use.

{{% alert color="warning" %}}
If you intend to also uninstall the Kiali Operator, it is very important to first uninstall the OSSMConsole CR and then uninstall the operator. If you uninstall the operator before ensuring the OSSMConsole CR is deleted then you may have difficulty removing that CR and its namespace. If this occurs then you must manually remove the finalizer on the CR in order to delete it and its namespace. You can do this via: `oc patch ossmconsoles <CR name> -n <CR namespace> -p '{"metadata":{"finalizers": []}}' --type=merge `
{{% /alert %}}

### Uninstalling via OpenShift Console

Remove the OSSMConsole CR by navigating to the operator details page in the OpenShift Console UI. From the operator details page, select the _OpenShift Service Mesh Console_ tab and then select the Delete option in the kebab menu.

![Uninstall Plugin](/images/documentation/installation/installation-guide/04-ui-uninstall-cr.png)

### Uninstalling via "oc" CLI

Remove the OSSMConsole CR via `oc delete ossmconsoles <CR name> -n <CR namespace>`. To make sure any and all CRs are deleted from any and all namespaces, you can run this command:

```sh
for r in $(oc get ossmconsoles --ignore-not-found=true --all-namespaces -o custom-columns=NS:.metadata.namespace,N:.metadata.name --no-headers | sed 's/  */:/g'); do oc delete ossmconsoles -n $(echo $r|cut -d: -f1) $(echo $r|cut -d: -f2); done
```
