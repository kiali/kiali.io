---
title: "Install Istio on West cluster"
description: "Install Istio on the remote cluster"
weight: 8
---

This installation will be different as this cluster will be a remote. In a remote cluster, it won't be an Istio control plane. Istio will install some resources that allows the primary control plane to configure the workloads in the remote cluster like injecting the sidecars and configuring the low level routing.

```
kubectl create namespace istio-system --context $CLUSTER_WEST

kubectl create secret generic cacerts -n istio-system --context $CLUSTER_WEST \
      --from-file=certs/$CLUSTER_WEST/ca-cert.pem \
      --from-file=certs/$CLUSTER_WEST/ca-key.pem \
      --from-file=certs/$CLUSTER_WEST/root-cert.pem \
      --from-file=certs/$CLUSTER_WEST/cert-chain.pem

kubectl --context=$CLUSTER_WEST annotate namespace istio-system topology.istio.io/controlPlaneClusters=$CLUSTER_EAST
kubectl --context=$CLUSTER_WEST label namespace istio-system topology.istio.io/network=network2

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
kubectl apply -f $ISTIO_DIR/samples/addons/prometheus.yaml --context $CLUSTER_WEST
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
$ISTIO_DIR/samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster $CLUSTER_WEST --network network2 | \
    istioctl --context=$CLUSTER_WEST install -y -f -

```

## Prometheus federation

An important design decision for Kiali was to decide that it will continue consuming data from one Prometheus instance per all clusters. For this reason, Prometheus needs to be federated, meaning that all the remote’s metrics should be fetched by the main Prometheus.

We will configure east's Prometheus to fetch west's metrics:

```
kubectl patch svc prometheus -n istio-system --context $CLUSTER_WEST -p "{\"spec\": {\"type\": \"LoadBalancer\"}}"

WEST_PROMETHEUS_ADDRESS=$(kubectl --context=$CLUSTER_WEST -n istio-system get svc prometheus -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

curl -L -o prometheus.yaml https://raw.githubusercontent.com/kiali/kiali/master/hack/istio/multicluster/prometheus.yaml

sed -i "s/WEST_PROMETHEUS_ADDRESS/$WEST_PROMETHEUS_ADDRESS/g" prometheus.yaml

kubectl --context=$CLUSTER_EAST apply -f prometheus.yaml -n istio-system
```