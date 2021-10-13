---
title: "Secure"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 6
---

## Authorization Policies

[Security](https://istio.io/latest/docs/concepts/security/) is one of the main pillars of Istio features.

The Istio [Security High Level Architecture](https://istio.io/latest/docs/concepts/security/#high-level-architecture) provides a comprehensive solution to design and implement multiple security scenarios.

In this tutorial we will show how Kiali can use telemetry information to create security policies for the workloads deployed in a given namespace.

Istio telemetry aggregates the ServiceAccount information used in the workloads communication. This information can be used to define authorization policies that deny and allow actions on future live traffic communication status.

This step will show how we can define authorization policies for the *travel-agency* namespace in the Travel Demo application, for all existing traffic in a given time period.

Once authorization policies are defined, a new workload will be rejected if it doesn't match the security rules defined.

{{% alert title="Step 1" color="success" %}}
Undeploy the *loadtester* workload from *travel-portal* namespace
{{% /alert %}}

In this example we will use the *loadtester* workload as the "intruder" in our security rules.

If we have followed the previous tutorial steps, we need to undeploy it from the system.

```
kubectl delete -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_loadtester.yaml) -n travel-portal
```

We should validate that telemetry has updated the *travel-portal* namespace and "Security" can be enabled in the Graph Display options.

![Travel Portal Graph](/images/tutorial/06-01-travel-portal-graph.png "Travel Portal Graph")

{{% alert title="Step 2" color="success" %}}
Create Authorization Policies for current traffic for *travel-agency* namespace
{{% /alert %}}

Every workload in the cluster uses a [Service Account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/).

*travels.uk*, *viaggi.it* and *voyages.fr* workloads use the default *cluster.local/ns/travel-portal/sa/default* ServiceAccount defined automatically per namespace.

This information is propagated into the Istio Telemetry and Kiali can use it to define a set of AuthorizationPolicy rules using the "Create Traffic Policies" action located in the Overview page.

![Create Traffic Policies](/images/tutorial/06-01-create-traffic-policies.png "Create Traffic Policies")

This will generate a main DENY ALL rule to protect the whole namespace, and an individual ALLOW rule per workload identified in the telemetry.

![Travel Agency Authorization Policies](/images/tutorial/06-01-travel-agency-authorization-policies.png "Travel Agency Authorization Policies")

{{% alert title="Step 3" color="success" %}}
Deploy the *loadtester* portal in the *travel-portal* namespace
{{% /alert %}}

If the *loadtester* workload uses a different ServiceAccount then, when it's deployed, it won't comply with the AuthorizationPolicy rules defined in the previous step.

{{% alert title="OpenShift" color="warning" %}}
OpenShift users may need to also add the associated loadtester serviceaccount to the necessary securitycontextcontraints.
{{% /alert %}}

```
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_loadtester.yaml) -n travel-portal
```

Now, *travels* workload will reject requests made by *loadtester* workload and that situation will be reflected in Graph:

![Loadtester Denied](/images/tutorial/06-01-loadtester-denied.png "Loadtester Denied")

This can also be verified in the details page using the Outbound Metrics tab grouped by response code (only the 403 line is present).

![Loadtester Denied Metrics](/images/tutorial/06-01-loadtester-denied-metrics.png "Loadtester Denied Metrics")

Inspecting the Logs tab confirms that *loadtester* workload is getting a HTTP 403 Forbidden response from *travels* workloads, as expected.

![Loadtester Logs](/images/tutorial/06-01-loadtester-logs.png "Loadtester Logs")

{{% alert title="Step 4" color="success" %}}
Update *travels-v1* AuthorizationPolicy to allow *loadtester* ServiceAccount
{{% /alert %}}

AuthorizationPolicy resources are defined per workload using matching selectors.

As part of the example, we can show how a ServiceAccount can be added into an existing rule to allow traffic from *loadtester* workload into the *travels-v1* workload only.

![AuthorizationPolicy Edit](/images/tutorial/ "AuthorizationPolicy Edit")

As expected, now we can see that *travels-v1* workload accepts requests from all *travel-portal* namespace workloads, but *travels-v2* and *travels-v3* continue rejecting requests from *loadtester* source.

![Travels v1 AuthorizationPolicy](/images/tutorial/06-01-travels-v1-authorizationpolicy.png "Travels v1 AuthorizationPolicy")

Using "Outbound Metrics" tab from the *loadtester* workload we can group per "Remote version" and "Response code" to get a detailed view of this AuthorizationPolicy change.

![Travels v1 AuthorizationPolicy](/images/tutorial/06-01-loadtester-authorized-metrics.png "Travels v1 AuthorizationPolicy")

{{% alert title="Step 5" color="success" %}}
Update or delete Istio Configuration
{{% /alert %}}

As part of this step you can update the AuthorizationPolicies generated for the *travel-agency* namespace, and experiment with more security rules, or you can delete the generated Istio config for the namespace.

