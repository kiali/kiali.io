---
title: "Install Travel Demo"
date: 2018-06-20T19:04:38+02:00
draft: false
weight: 2
---

## Deploy the Travel Demo

This demo application will deploy several services grouped into three namespaces.

Note that at this step we are going to deploy the application without any reference to Istio.

We will join services to the ServiceMesh in a following step.

To create and deploy the namespaces perform the following commands:

{{% alert title="OpenShift" color="warning" %}}
OpenShift users can substitute `oc` for `kubectl`. OpenShift users will need
to add the necessary NetworkAttachmentDefinition to each namespace.  Also, the necessary SecurityContextConstraints
for the service accounts defined in the namespace (minimally, default).
{{% /alert %}}

```
kubectl create namespace travel-agency
kubectl create namespace travel-portal
kubectl create namespace travel-control

kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_agency.yaml) -n travel-agency
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_portal.yaml) -n travel-portal
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travel_control.yaml) -n travel-control
```

Check that all deployments rolled out as expected:

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
## Understanding the demo application

### Travel Portal namespace

The Travel Demo application simulates two business domains organized in different namespaces.

In a first namespace called *travel-portal* there will be deployed several travel shops, where users can search for and book flights, hotels, cars or insurance.

The shop applications can behave differently based on request characteristics like channel (web or mobile) or user (new or existing).

These workloads may generate different types of traffic to imitate different real scenarios.

All the portals consume a service called _travels_ deployed in the *travel-agency* namespace.

### Travel Agency namespace

A second namespace called *travel-agency* will host a set of services created to provide quotes for travel.

A main _travels_ service will be the business entry point for the travel agency. It receives a destination city and a user as parameters and it calculates all elements that compose a travel budget: airfare, lodging, car reservation and travel insurance.

Each service can provide an independent quote and the _travels_ service must then aggregate them into a single response.

Additionally, some users, like _registered_ users, can have access to special discounts, managed as well by an external service.

Service relations between namespaces can be described in the following diagram:

<a class="image-popup-fit-height" href="/images/tutorial/02-02-travels-demo-design.png" title="Travel Demo Design">
    <img src="/images/tutorial/02-02-travels-demo-design.png" style="display:block;margin: 0 auto;" />
</a>

#### Travel Portal and Travel Agency flow

A typical flow consists of the following steps:

. A portal queries the _travels_ service for available destinations.
. _Travels_ service queries the available hotels and returns to the portal shop.
. A user selects a destination and a type of travel, which may include a _flight_ and/or a _car_, _hotel_ and _insurance_.
. _Cars_, _Hotels_ and _Flights_ may have available discounts depending on user type.

### Travel Control namespace

The *travel-control* namespace runs a *business dashboard* with two key features:

* Allow setting changes for every travel shop simulator (traffic ratio, device, user and type of travel).
* Provide a *business* view of the total requests generated from the *travel-portal* namespace to the *travel-agency* services, organized by business criteria as grouped per shop, per type of traffic and per city.

<a class="image-popup-fit-height" href="/images/tutorial/02-02-travels-dashboard.png" title="Travel Dashboard">
    <img src="/images/tutorial/02-02-travels-dashboard.png" style="display:block;margin: 0 auto;" />
</a>
