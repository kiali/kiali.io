---
title: "Example Install"
weight: 70
---

This is a quick example of installing Kiali. This example will install the operator and two Kiali Servers - one server will require the user to enter credentials at a login screen in order to obtain read-write access and the second server will allow anonymous read-only access.

For this example, assume there is a Minikube Kubernetes cluster running with an
Istio control plane installed in the namespace `istio-system` and
the Istio Bookinfo Demo installed in the namespace `bookinfo`:

```
$ kubectl get deployments.apps -n istio-system
NAME                   READY   UP-TO-DATE   AVAILABLE   AGE
grafana                1/1     1            1           8h
istio-egressgateway    1/1     1            1           8h
istio-ingressgateway   1/1     1            1           8h
istiod                 1/1     1            1           8h
jaeger                 1/1     1            1           8h
prometheus             1/1     1            1           8h

$ kubectl get deployments.apps -n bookinfo
NAME             READY   UP-TO-DATE   AVAILABLE   AGE
details-v1       1/1     1            1           21m
productpage-v1   1/1     1            1           21m
ratings-v1       1/1     1            1           21m
reviews-v1       1/1     1            1           21m
reviews-v2       1/1     1            1           21m
reviews-v3       1/1     1            1           21m
```

## Install Kiali Operator via Helm Chart

First, the Kiali Operator will be installed in the `kiali-operator` namespace using the [operator helm chart]({{< ref "/docs/installation/installation-guide/install-with-helm#operator-only-install" >}}):

```bash
$ helm repo add kiali https://kiali.org/helm-charts
$ helm repo update kiali
$ helm install \
    --namespace kiali-operator \
    --create-namespace \
    kiali-operator \
    kiali/kiali-operator
```

## Install Kiali Server via Operator

Next, the first Kiali Server will be installed. This server will require the user to enter a Kubernetes token in order to log into the Kiali dashboard and will provide the user with read-write access. To do this, a Kiali CR will be created that looks like this (file: `kiali-cr-token.yaml`):

```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: istio-system
spec:
  auth:
    strategy: "token"
  deployment:
    accessible_namespaces: ["bookinfo"]
    view_only_mode: false
  server:
    web_root: "/kiali"
```

This Kiali CR will command the operator to deploy the Kiali Server in the same namespace where the Kiali CR is (`istio-system`). The operator will configure the server to: respond to requests to the web root path of `/kiali`, enable read-write access, use the authentication strategy of `token`, and be given access to the `bookinfo` namespace:

```bash
$ kubectl apply -f kiali-cr-token.yaml
```

## Get the Status of the Installation

The status of a particular Kiali Server installation can be found by examining the `status` field of its corresponding Kiali CR. For example:

```bash
$ kubectl get kiali kiali -n istio-system -o jsonpath='{.status}'
```

When the installation has successfully completed, the `status` field will look something like this (when formatted):

```json
$ kubectl get kiali kiali -n istio-system -o jsonpath='{.status}' | jq
{
  "conditions": [
    {
      "ansibleResult": {
        "changed": 21,
        "completion": "2021-10-20T19:17:35.519131",
        "failures": 0,
        "ok": 102,
        "skipped": 90
      },
      "lastTransitionTime": "2021-10-20T19:17:12Z",
      "message": "Awaiting next reconciliation",
      "reason": "Successful",
      "status": "True",
      "type": "Running"
    }
  ],
  "deployment": {
    "accessibleNamespaces": "bookinfo,istio-system",
    "instanceName": "kiali",
    "namespace": "istio-system"
  },
  "environment": {
    "isKubernetes": true,
    "kubernetesVersion": "1.20.2",
    "operatorVersion": "v1.41.0"
  },
  "progress": {
    "duration": "0:00:20",
    "message": "7. Finished all resource creation"
  }
}
```

## Access the Kiali Server UI

The Kiali Server UI is accessed by pointing a browser to the Kiali Server endpoint and requesting the web root `/kiali`:

```bash
xdg-open http://$(minikube ip)/kiali
```

Because the `auth.strategy` was set to `token`, that URL will display the Kiali login screen that will require a Kubernetes token in order to authenticate with the server. For this example, you can use the token that belongs to the Kiali service account itself:

```bash
$ kubectl get secret -n istio-system $(kubectl get sa kiali-service-account -n istio-system -o jsonpath='{.secrets[0].name}') -o jsonpath='{.data.token}' | base64 -d
```

The output of that command above can be used to log into the Kiali login screen.

## Install a Second Kiali Server

The second Kiali Server will next be installed. This server will not require the user to enter any login credentials but will only provide a view-only look at the service mesh. To do this, a Kiali CR will be created that looks like this (file: `kiali-cr-anon.yaml`):

```yaml
apiVersion: kiali.io/v1alpha1
kind: Kiali
metadata:
  name: kiali
  namespace: kialianon
spec:
  installation_tag: "Kiali - View Only"
  istio_namespace: "istio-system"
  auth:
    strategy: "anonymous"
  deployment:
    accessible_namespaces: ["bookinfo"]
    view_only_mode: true
    instance_name: "kialianon"
  server:
    web_root: "/kialianon"
```

This Kiali CR will command the operator to deploy the Kiali Server in the same namespace where the Kiali CR is (`kialianon`). The operator will configure the server to: respond to requests to the web root path of `/kialianon`, disable read-write access, not require the user to authenticate, have a unique instance name of `kialianon` and be given access to the `bookinfo` namespace. The Kiali UI will also show a custom title in the browser tab so the user is aware they are looking at a "view only" Kiali dashboard. The unique `deployment.instance_name` is needed in order for this Kiali Server to be able to share access to the Bookinfo application with the first Kiali Server.

```bash
$ kubectl create namespace kialianon
$ kubectl apply -f kiali-cr-anon.yaml
```

The UI for this second Kiali Server is accessed by pointing a browser to the Kiali Server endpoint and requesting the web root `/kialianon`. Note that no credentials are required to gain access to this Kiali Server UI because `auth.strategy` was set to `anonymous`; however, the user will not be able to modify anything via the Kiali UI - it is strictly "view only":

```bash
xdg-open http://$(minikube ip)/kialianon
```

## Reconfigure Kiali Server

A Kial Server can be reconfigured by simply editing its Kiali CR. The Kiali Operator will perform all the necessary tasks to complete the reconfiguration and reboot the Kiali Server pod when necessary. For example, to change the web root for the Kiali Server:

```bash
$ kubectl patch kiali kiali -n istio-system --type merge --patch '{"spec":{"server":{"web_root":"/specialkiali"}}}'
```

The Kiali Operator will update the necessary resources (such as the Kiali ConfigMap) and will reboot the Kiali Server pod to pick up the new configuration.

## Uninstall Kiali Server

To uninstall a Kiali Server installation, simply delete the Kiali CR. The Kiali Operator will then perform all the necessary tasks to remove all remnants of the associated Kiali Server.

```bash
kubectl delete kiali kiali -n istio-system
```

## Uninstall Kiali Operator

To uninstall the Kiali Operator, use `helm uninstall` and then manually remove the Kiali CRD.

{{% alert color="warning" %}}
You must delete all Kiali CRs in the cluster prior to uninstalling the Kiali Operator. If you fail to do this, uninstalling the operator will hang and remnants of Kiali Server installations will remain in your cluster and you will be required to perform some [manual steps]({{< ref "/docs/installation/installation-guide/install-with-helm#known-problem-uninstall-hangs-unable-to-delete-the-kiali-cr" >}}) to clean it up.
{{% /alert %}}

```bash
$ kubectl delete kiali --all --all-namespaces
$ helm uninstall --namespace kiali-operator kiali-operator
$ kubectl delete crd kialis.kiali.io
```
