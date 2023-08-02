---
title: "Prerequisites"
description: "How to prepare for running the tutorial."
weight: 1
---

## Introduction

This tutorial assumes that you will have access to two Kubernetes clusters. 

Each cluster needs to be able to connect to the other cluster's API server. 

Another consideration will be the network model for the clusters, Istio uses a simplified definition of network based on general connectivity. Workload instances are on the same network if they are able to communicate directly, without a gateway. 

In general this scenario won't be a normal as each cluster will probably have its own network for workloads. For this reason, we will use a setup for different networks. For more information about this, read the Istio documentation about network models.

This tutorial has been tested using [Minikube v1.30.0](https://minikube.sigs.k8s.io/docs/start/).

In terms of Istio deployment model, we will use a [primary-remote](https://istio.io/latest/docs/ops/deployment/deployment-models/#control-plane-models) model. This is the current supported model in Kiali for Istio multicluster. Stay tuned at our [Multicluster](https://github.com/kiali/kiali/issues/5618) epic for more information about future supported models like multi-primary.

## Certificates setup

As both clusters will be communicating with each other, proper certificates needs to be configured in both of them. This is explained well in Istio's [certificates documentation](https://istio.io/latest/docs/tasks/security/cert-management/plugin-ca-cert/).

As a result of following the steps, a configmap named cacerts will be created in both clusters in the Istio control plane namespace.

## Clusters setup

We will use minikube for creating the Kubernetes clusters.

### East

We will create the "east" cluster with the following command:

```
CLUSTER_EAST="east"

minikube start -p $CLUSTER_EAST --network istio --memory 8g
```

Both cluster will need MetalLB for the future. This is because in each cluster will be a "east-west" gateway for Istio communication and these gateways need to be exposed with a external IP.

The following commands create the IP range that MetalLB will assign to our gateways:

```
MINIKUBE_IP=$(minikube ip -p $CLUSTER_EAST)
MINIKUBE_IP_NETWORK=$(echo $MINIKUBE_IP | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+/\1/')
MINIKUBE_LB_RANGE="${MINIKUBE_IP_NETWORK}.20-${MINIKUBE_IP_NETWORK}.29"
```

MetalLB will be installed using a minikube addon and configured with a configmap:

```
minikube addons enable metallb -p $CLUSTER_EAST

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

### West

In a similar fashion, we will create and configure west cluster:

```
CLUSTER_WEST="west"

minikube start -p $CLUSTER_WEST --network istio --memory 8g
```

```
MINIKUBE_IP=$(minikube ip -p $CLUSTER_WEST)
MINIKUBE_IP_NETWORK=$(echo $MINIKUBE_IP | sed -E 's/([0-9]+\.[0-9]+\.[0-9]+)\.[0-9]+/\1/')
MINIKUBE_LB_RANGE="${MINIKUBE_IP_NETWORK}.30-${MINIKUBE_IP_NETWORK}.39"
```

```
minikube addons enable metallb -p $CLUSTER_WEST
```

```
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

{{% alert title="Minikube networks" color="warning" %}}
We are configuring both minikube to share the same network "istio". This is because the API server and all the exposed external IPs needs to belong to the same network so east's Istiod process can reach the other cluster endpoints.
{{% /alert %}}

## Istio installation

As we mentioned, we will installed a primary-remote setup in which east will contain the primary (where the control plane is)
and west will be a remote.

The following commands are extracted from the Istio's [primary-remote on different networks](https://istio.io/latest/docs/setup/install/multicluster/primary-remote_multi-network/) documentation.

{{% alert title="Istio samples directory" color="warning" %}}
In the following commands, we are using some scripts from the Istio's samples directory. Make sure you are in the correct directory when running the commands.
{{% /alert %}}


### East

We will create the Istio namespace and do some labelling:

```
kubectl create namespace istio-system --context $CLUSTER_EAST

kubectl --context=$CLUSTER_EAST label namespace istio-system topology.istio.io/network=network1
```

Then we will prepare the configuration and install Istio:

```
cat <<EOF > $CLUSTER_EAST.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  values:
    global:
      meshID: mesh1
      multiCluster:
        clusterName: $CLUSTER_EAST
      network: network1
EOF

istioctl install -y --set values.pilot.env.EXTERNAL_ISTIOD=true --context=$CLUSTER_EAST -f $CLUSTER_EAST.yaml
```

We will install the Prometheus addon:

```
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/addons/prometheus.yaml  --context $CLUSTER_EAST
```

An important step in the installation is to deploy a gateway for cross cluster communication (this is because we are in the scenario for different workloads network):

```
samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster $CLUSTER_EAST --network network1 | \
    istioctl --context=$CLUSTER_EAST install -y -f -
```

We will expose the istiod service and all user services in the east-west gateway:

```
kubectl apply --context=$CLUSTER_EAST -n istio-system -f \
    samples/multicluster/expose-istiod.yaml

kubectl --context=$CLUSTER_EAST apply -n istio-system -f \
    samples/multicluster/expose-services.yaml
```

Finally, we are storing the east-west gateway ip for the later configuration of the remote cluster:

```
export DISCOVERY_ADDRESS=$(kubectl \
    --context=$CLUSTER_EAST \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

### West

As we mentioned, west cluster will be remote. For this reason, we annotate the namespace indicating that east cluster will be the control plane cluster and also that this cluster will be on a different network:

```
kubectl create namespace istio-system --context $CLUSTER_WEST

kubectl --context=$CLUSTER_WEST annotate namespace istio-system topology.istio.io/controlPlaneClusters=$CLUSTER_EAST
kubectl --context=$CLUSTER_WEST label namespace istio-system topology.istio.io/network=network2
```

We configure and install Istio:

```
cat <<EOF > $CLUSTER_WEST.yaml
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
spec:
  profile: remote
  values:
    istiodRemote:
      injectionPath: /inject/cluster/$CLUSTER_WEST/net/network2
    global:
      remotePilotAddress: ${DISCOVERY_ADDRESS}
EOF

istioctl install -y --context=$CLUSTER_WEST -f $CLUSTER_WEST.yaml
```

We will also install a Prometheus instance on the remote. We will federate both Prometheus, with the east's one being the place where all metrics will be gathered together:

```
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.18/samples/addons/prometheus.yaml --context $CLUSTER_WEST
```

An important step is to create a secret on east cluster allowing it to fetch information of the remote cluster:

```
istioctl x create-remote-secret \
    --context=$CLUSTER_WEST \
    --name=$CLUSTER_WEST | \
    kubectl apply -f - --context=$CLUSTER_EAST
```

Finally, we create the east-west gateway

```
samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster $CLUSTER_WEST --network network2 | \
    istioctl --context=$CLUSTER_WEST install -y -f -
```

## Prometheus federation

We will configure east's Prometheus to fetch for west's metrics:

```
kubectl patch svc prometheus -n istio-system --context $CLUSTER_WEST -p "{\"spec\": {\"type\": \"LoadBalancer\"}}"

WEST_PROMETHEUS_ADDRESS=$(kubectl --context=$CLUSTER_WEST -n istio-system get svc prometheus -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl -L -o prometheus.yaml https://raw.githubusercontent.com/kiali/kiali/master/hack/istio/multicluster/prometheus.yaml

sed -i "s/WEST_PROMETHEUS_ADDRESS/$WEST_PROMETHEUS_ADDRESS/g" prometheus.yaml

kubectl --context=$CLUSTER_EAST apply -f prometheus.yaml -n istio-system
```

###  Istio setup verification

A good recommendation is to verify the installation with a sample application as it is indicated and explained in the [Istio's documentation](https://istio.io/latest/docs/setup/install/multicluster/verify/). Please follow the steps to verify it and continue with the tutorial.

## Kiali installation

We will configure Kiali to access the remote cluster. This will require a secret (similar to the Istio secret) containg the credentials for Kiali to fetch information for the remote cluster:

```
curl -L -o kiali-prepare-remote-cluster.sh https://raw.githubusercontent.com/kiali/kiali/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh

chmod +x kiali-prepare-remote-cluster.sh

./kiali-prepare-remote-cluster.sh --kiali-cluster-context $CLUSTER_EAST --remote-cluster-context $CLUSTER_WEST
```

Finally, we will install Kiali using our Helm chart:

```
helm install \
  --namespace istio-system \
  --set auth.strategy="anonymous" \
  --repo https://kiali.org/helm-charts \
  kiali-server \
  kiali-server
```
