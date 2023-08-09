---
title: "Install Istio on East cluster"
description: "Install Istio on the primary cluster"
weight: 4
---

The east cluster is the primary one, consequently is where the istiod process will be installed alongside other applications like Kiali. 

Run the following commands to install Istio:

```
kubectl create namespace istio-system --context $CLUSTER_EAST

kubectl create secret generic cacerts -n istio-system --context $CLUSTER_EAST \
      --from-file=certs/$CLUSTER_EAST/ca-cert.pem \
      --from-file=certs/$CLUSTER_EAST/ca-key.pem \
      --from-file=certs/$CLUSTER_EAST/root-cert.pem \
      --from-file=certs/$CLUSTER_EAST/cert-chain.pem

kubectl --context=$CLUSTER_EAST label namespace istio-system topology.istio.io/network=network1

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

After the installation, we need to create what we called an “east-west” gateway. It’s an ingress gateway just for the cross cluster configuration as we are opting to use the installation for different networks (this will be the case in the majority of the production scenarios). 

```
$ISTIO_DIR/samples/multicluster/gen-eastwest-gateway.sh \
    --mesh mesh1 --cluster $CLUSTER_EAST --network network1 | \
    istioctl --context=$CLUSTER_EAST install -y -f -
```

Then, we need to expose the istiod service as well as the applications for the cross cluster communication:

```
kubectl apply --context=$CLUSTER_EAST -n istio-system -f \
    $ISTIO_DIR/samples/multicluster/expose-istiod.yaml

kubectl --context=$CLUSTER_EAST apply -n istio-system -f \
    $ISTIO_DIR/samples/multicluster/expose-services.yaml

export DISCOVERY_ADDRESS=$(kubectl \
    --context=$CLUSTER_EAST \
    -n istio-system get svc istio-eastwestgateway \
    -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
```

Finally, we need to install Prometheus, which is important and required for Kiali to operate:

```
kubectl --context $CLUSTER_EAST -n istio-system apply -f $ISTIO_DIR/samples/addons/prometheus.yaml
```