---
title: "Install Travel Demo"
description: "Installing and understanding the tutorial demo."
weight: 2
---

## Deploy the Travel Demo

This demo application deploys several services grouped into three namespaces:

* *travel-control* — business dashboard to configure traffic and view statistics
* *travel-portal* — shop simulators that generate traffic
* *travel-agency* — quote and pricing services

At this step, deploy the application **without** joining it to the service mesh. Sidecar injection is added in [First Steps]({{< relref "./03-first-steps" >}}).

Do **not** label the namespaces with `istio-injection=enabled` yet.

### Kind

From the [Kiali source repository](https://github.com/kiali/kiali), the travel demo install script creates the namespaces and deploys the manifests without enabling auto-injection:

```
./hack/istio/install-travel-agency-demo.sh -c kubectl -ai false
```

Alternatively, run the commands manually:

```
kubectl create namespace travel-agency
kubectl create namespace travel-portal
kubectl create namespace travel-control

kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml) -n travel-agency
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml) -n travel-portal
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_control.yaml) -n travel-control
```

{{% alert color="info" %}}
If you have a local clone of the [demos repository](https://github.com/kiali/demos), you can apply the YAML files from `travels/` instead of downloading them.
{{% /alert %}}

### OpenShift

The install script also handles OpenShift-specific setup (NetworkAttachmentDefinitions and SecurityContextConstraints):

```
./hack/istio/install-travel-agency-demo.sh -c oc -ai false
```

Alternatively, substitute `oc` for `kubectl` in the manual commands above and add the necessary NetworkAttachmentDefinition to each namespace, along with SecurityContextConstraints for the service accounts in those namespaces (minimally, `default`).

### Verify the deployment

#### Confirm workloads are running

Check that all deployments rolled out. Pods should show `1/1` ready — there are no sidecars yet:

```
$ kubectl get deployments -n travel-control
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
control   1/1     1            1           85s

$ kubectl get deployments -n travel-portal
NAME      READY   UP-TO-DATE   AVAILABLE   AGE
travels   1/1     1            1           91s
viaggi    1/1     1            1           91s
voyages   1/1     1            1           91s

$ kubectl get deployments -n travel-agency
NAME            READY   UP-TO-DATE   AVAILABLE   AGE
cars-v1         1/1     1            1           96s
discounts-v1    1/1     1            1           96s
flights-v1      1/1     1            1           96s
hotels-v1       1/1     1            1           96s
insurances-v1   1/1     1            1           96s
mysqldb-v1      1/1     1            1           96s
travels-v1      1/1     1            1           96s
```

The portal workloads generate traffic to the travel agency services automatically.

#### Confirm in Kiali

Open Kiali and select **Overview**. This page summarizes what is in the service mesh — control planes, data planes, applications, and services that participate in the mesh.

Because the Travel Demo was deployed **without** sidecars, it is not part of the mesh yet. The **Overview** page should look much the same as before the demo was installed. You should still see the Istio control plane, and mesh counts such as data plane namespaces should remain at **0**.

To see the demo namespaces, open the **Namespaces** page. The three Travel Demo namespaces should be listed:

* `travel-control`
* `travel-portal`
* `travel-agency`

In the **Type** column, each namespace shows a **`-`** badge. Hover over the badge to see the tooltip **Not part of the mesh**:

![Travel demo namespaces not in mesh](/images/tutorial/02-01-namespaces-not-in-mesh.png "Travel demo namespaces not in mesh")

Sidecar injection is covered in the next chapter, which is when these namespaces begin to appear as part of the mesh.

## Understanding the demo application

The Travel Demo simulates a travel booking scenario across three namespaces. Traffic flows in one direction:

**travel-control** &rarr; **travel-portal** &rarr; **travel-agency**

The *control* dashboard configures how each portal shop behaves. The portal shops generate requests. The agency services respond with travel quotes.

![Travel Demo Design](/images/tutorial/02-02-travels-demo-design.png "Travel Demo Design")

### How traffic flows

A typical request path looks like this:

1. Settings on the *control* dashboard determine how each portal shop sends traffic (device, user type, travel type, and volume).
2. A portal shop in *travel-portal* queries the _travels_ service in *travel-agency* for available destinations.
3. The _travels_ service queries _hotels_ and returns destination options to the portal.
4. When a destination and travel type are selected, _travels_ aggregates quotes from _flights_, _cars_, _hotels_, _insurances_, and _discounts_.
5. _Cars_, _hotels_, and _flights_ may apply discounts depending on user type.

### Travel Control namespace

The *travel-control* namespace hosts a *business dashboard* with two roles:

* Configure every travel shop simulator — traffic ratio, device, user, and type of travel.
* View a business summary of requests from *travel-portal* to *travel-agency*, grouped by shop, traffic type, and city.

![Travel Dashboard](/images/tutorial/02-02-travels-dashboard.png "Travel Dashboard")

{{% alert color="info" %}}
The dashboard screenshot above will be updated during tutorial refresh.
{{% /alert %}}

#### Preview the Travels dashboard (optional)

The *control* service is not exposed outside the cluster yet — that happens in [First Steps]({{< relref "./03-first-steps" >}}). To preview the dashboard now:

```
kubectl port-forward svc/control 8080:8080 -n travel-control
```

Open http://localhost:8080/ in your browser.

### Travel Portal namespace

The *travel-portal* namespace runs several travel shop simulators (for example *travels*, *viaggi*, and *voyages*). Each shop represents a different portal with its own traffic characteristics.

Shops differ by channel (web or mobile), user type (new or registered), and travel type. Together they produce varied traffic patterns so you can explore realistic mesh scenarios in Kiali.

All portal shops call the _travels_ service in the *travel-agency* namespace.

### Travel Agency namespace

The *travel-agency* namespace provides backend quote services. The _travels_ service is the main entry point: it receives a destination city and user, then aggregates a full travel budget from the supporting services:

* _hotels_ — lodging quotes
* _flights_ — airfare quotes
* _cars_ — car rental quotes
* _insurances_ — travel insurance quotes
* _discounts_ — special pricing for registered users
* _mysqldb_ — persistent storage for the demo

Each service calculates its portion independently; _travels_ combines them into a single response.
