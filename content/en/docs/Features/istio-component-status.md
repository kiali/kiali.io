---
title: "Istio Infrastructure Status"
linkTitle: "Istio Status"
description: "How Kiali monitors your Istio infrastructure."
---

A service mesh simplifies application services by deferring the non-business logic to the mesh. But for healthy applications the service mesh infrastructure must also be running normally.  Kiali monitors the multiple components that make up the service mesh, letting you know if there is an underlying problem.

![Istio component status](/images/documentation/features/istio-status-masthead.png "Istio component status")

A component *status* will be one of: `Not found`, `Not ready`, `Unreachable`, `Not healthy` and `Healthy`. `Not found` means that Kiali is not able to find the deployment. `Not ready` means no pods are running.  `Unreachable` means that Kiali hasn't been successfully able to communicate with the component (Prometheus, Grafana and Jaeger). `Not healthy` means that the deployment doesn't have the desired amount of replicas running. Otherwise, the component is `Healthy` and it won't be shown in the list.

Regarding the *severity* of each component, there are only two options: `core` or `add-on`. The `core` components are those shown as errors (in red) whereas the `add-ons` are displayed as warnings (in orange).

By default, Kiali checks that the `core` components "istiod", "ingress", and "egress" are installed and running in the control plane namespace, and that the `add-ons` "prometheus", "grafana" and "jaeger" are available.

## Certificate Information Indicators

In some situations, it is useful to get information about the certificates used by internal mTLS, for example:

* Know whether the default CA is used or if there is another CA configured.
* Check the certificates issuer and their validity timestamps to troubleshoot any issue with certificates.

The certificates shown depends on how Istio is configured. The following cases are possible:

* Using Istio CA certificates (default), the information shown is from a secret named *istio-ca-secret*.
* Using [Plug in CA certificates](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/), the information shown is from a secret named *cacerts*.
* Using [DNS certificates](https://istio.io/latest/docs/tasks/security/cert-management/dns-cert/), the information shown is from reading many secrets found in Istio configuration.

The following is an example of viewing the default case:

![Certificates information](/images/documentation/features/istio-status-certificate-info-indicators.png "Certificates information")

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
