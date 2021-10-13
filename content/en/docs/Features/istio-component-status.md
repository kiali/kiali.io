---
title: "Istio Status"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 9
---

## Istio Component Status

The Istio service mesh architecture is comprised of several components, from istiod to Jaeger. Each component must work as expected for the mesh to work well overall. Kiali regularly checks the status of each Istio component to ensure the mesh is healthy.

![Istio components status: components not healthy or found](/images/documentation/features/istio-components-1.24.png "Istio components status: components not healthy or found")

A component *status* will be one of: `Not found`, `Unreachable`, `Not healthy` and `Healthy`. The `Not found` status means that Kiali is not able to find the deployment. The `Unreachable` status means that Kiali hasn't been succesfuly able to communicate with the component (Prometheus, Grafana and Jaeger). The `Not healthy` status means that the deployment doesn't have the desired amount of replicas running. The `Healthy` status is when the component is not in the previous ones, plus, healthy components won't be shown in the list.

Regarding the *severity* of each component, there are only to options: `core` or `add-on`. The `core` components are those shown as errors (in red) whereas the `add-ons` are displayed as warnings (in orange).

By default, Kiali checks the following components installed in the control plane namespace: istiod, ingress, egress; and prometheus, grafana and jaeger accessible thought their services.

## Certificates Information Indicators

In some situations, it would be useful to get information about the certificates used by internal mTLS, for example:

* Know whether the default CA is used or if there is another CA configured
* Check the certificates issuer and their validity timestamps to troubleshoot any issue with certificates

The certificates shown depends on how Istio is configured. The following cases are possible:

* Using Istio CA certificates (default), the information shown is from a secret named *istio-ca-secret*
* Using https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/[Plug in CA certificates, window=_blank], the information shown is from a secret named *cacerts*
* Using https://istio.io/latest/docs/tasks/security/cert-management/dns-cert/[DNS certificates, window=_blank], the information shown is from reading many secrets found in Istio configuration

The following is an example of viewing the default case:

![Certificates information](/images/documentation/features/certificates-information-indicators.png "Certificates information")

Note that displaying this configuration requires permissions to read secrets (*istio-ca-secret* by default, possibly *cacerts* or any secret configured when using DNS certificates).

Having these permissions may concern users. For this reason, this feature is implemented as a feature flag and not only can be disabled, avoiding any extra permissions to read secrets, but also a list of secrets can be configured to explicitly grant read permissions for some secrets in the control plane namespace. By default, this feature is enabled with a Kiali CR configuration equivalent to the following:

```yaml
spec:
  kiali_feature_flags:
    certificates_information_indicators:
      enabled: true
      secrets:
      - cacerts
      - istio-ca-secret
```

You can extend this default configuration with additional secrets, remove secrets you don't want, or disable the feature.

If you add additional secrets, the Kiali operator _also_ needs the same privileges in order to configure Kiali successfully. If you used the [Helm Charts]({{< ref "/docs/installation/installation-guide/install-with-helm" >}}) to install the operator, specify the `secretReader` value with the required secrets:

```
$ helm install \
    --namespace kiali-operator \
    --create-namespace \
    --set "secretReader={cacerts,istio-ca-secret}"
    kiali-operator \
    kiali/kiali-operator
```

If you installed the operator via the [OperatorHub]({{< ref "/docs/installation/installation-guide/installing-with-operatorhub" >}}) you need to update the operator privileges as a post-installation step, as follows:

```
$ kubectl patch $(kubectl get clusterroles -o name | grep kiali-operator) --type "json" -p '[{"op":"add","path":"/rules/0","value":{"apiGroups":[""],"resources":["secrets"],"verbs":["get"],"resourceNames":["secret-name-to-be-read"]}}]'
```

Replace `secret-name-to-be-read` with the secret name you want the operator to read and restart the Kiali operator pod after running the previous command.
