---
title: "Install Travels on West cluster"
description: "Install new services of the Travels application in the remote cluster."
weight: 10
---

We are going to deploy two new services just to distribute traffic on the new cluster. These services are travels v2 and v3:

```
kubectl create ns travel-agency --context $CLUSTER_WEST

kubectl label namespace travel-agency istio-injection=enabled --context $CLUSTER_WEST

kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travels-v2.yaml) -n travel-agency --context $CLUSTER_WEST
kubectl apply -f <(curl -L https://raw.githubusercontent.com/kiali/demos/master/travels/travels-v3.yaml) -n travel-agency --context $CLUSTER_WEST

cat <<EOF | kubectl -n travel-agency --context $CLUSTER_WEST apply -f -
apiVersion: v1
kind: Service
metadata:
  name: travels
  labels:
    app: travels
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: travels
---
apiVersion: v1
kind: Service
metadata:
  name: insurances
  labels:
    app: insurances
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: insurances
---
apiVersion: v1
kind: Service
metadata:
  name: hotels
  labels:
    app: hotels
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: hotels
---
apiVersion: v1
kind: Service
metadata:
  name: flights
  labels:
    app: flights
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: flights
---
apiVersion: v1
kind: Service
metadata:
  name: discounts
  labels:
    app: discounts
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: discounts
---
apiVersion: v1
kind: Service
metadata:
  name: cars
  labels:
    app: cars
spec:
  ports:
    - name: http
      port: 8000
  selector:
    app: cars
EOF
```

After the installation, we can see that traffic is flowing to the remote cluster too:

![Travels MC](/images/mc-tutorial/04.png "Travels MC")

This is happening automatically, Istio balances the traffic to both services. The key thing to notice here is that there is a concept called namespace sameness in Istio that is very important when planning our multicluster setup.

In both clusters, we can see that we have the same namespaces. They are called the same in both. Also, we can see that the services in both clusters need to exist and be called the same. 

When we created the west’s namespaces, they are called the same, and also notice that even if we do not have instances of insurances or cars, we created the services. This is because travel services from the cluster will try to communicate with these services, not caring at all if the applications are in the west or east cluster. Istio will handle the routing in the back. 

From this moment, we can start playing with Kiali to introduce some scenarios previously seen in the Travels tutorial.
