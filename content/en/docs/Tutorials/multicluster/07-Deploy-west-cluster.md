---
title: "Deploy West cluster"
description: "Deploy the West cluster which will be the remote cluster"
weight: 7
---

Run the following commands to deploy the second cluster:

```
minikube start -p $CLUSTER_WEST --network istio --memory 8g --cpus 4
```

Similar to the east cluster, we configure MetalLB:

```
minikube addons enable metallb -p $CLUSTER_WEST

MINIKUBE_IP=$(minikube ip -p $CLUSTER_WEST)
MINIKUBE_IP_NETWORK=$(echo $MINIKUBE_IP | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+/\1/')
MINIKUBE_LB_RANGE="${MINIKUBE_IP_NETWORK}.30-${MINIKUBE_IP_NETWORK}.39"

cat <<EOF | kubectl --context $CLUSTER_WEST apply -f -
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