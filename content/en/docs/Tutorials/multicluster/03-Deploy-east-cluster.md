---
title: "Deploy East cluster"
description: "Deploy the East cluster which will be the primary cluster"
weight: 3
---

Run the following commands to deploy the first cluster:

```
minikube start -p $CLUSTER_EAST --network istio --memory 8g --cpus 4
```

For both clusters, we need to configure MetalLB, which is a load balancer. This is because we need to assign an external IP to the required ingress gateways to enable cross cluster communication between Istio and the applications installed.

```
minikube addons enable metallb -p $CLUSTER_EAST
```

We set up some environment variables with IP ranges that MetalLB will then assign to the services:

```
MINIKUBE_IP=$(minikube ip -p $CLUSTER_EAST)
MINIKUBE_IP_NETWORK=$(echo $MINIKUBE_IP | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+/\1/')
MINIKUBE_LB_RANGE="${MINIKUBE_IP_NETWORK}.20-${MINIKUBE_IP_NETWORK}.29"

cat <<EOF | kubectl --context $CLUSTER_EAST apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses: [${MINIKUBE_LB_RANGE}]
EOF
```

We should have the first cluster deployed and ready to use.
