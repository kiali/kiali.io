---
title: "Kiali and Tempo setup"
description: "Steps to install Kiali and Grafana Tempo"
weight: 2
---

### Steps to install Kiali and Grafana Tempo

We will start minikube: 

```
minikube start
```

It is a requirement to have cert-manager installed: 

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.yaml
```

Install the operator. It is important to download a version >=3.0. In previous versions, the zipkin collector was not exposed, there was no way to change it as it was not defined in the CRD.

```
kubectl apply -f https://github.com/grafana/tempo-operator/releases/download/v0.3.0/tempo-operator.yaml
```

We will create the tempo namespace: 
```
kubectl create namespace tempo
```

We will deploy minio: 
```
kubectl apply --namespace tempo -f https://raw.githubusercontent.com/grafana/tempo-operator/main/minio.yaml
```

We will create a secret to access minio:
```
kubectl create secret generic -n tempo tempostack-dev-minio \
--from-literal=bucket="tempo-data" \
--from-literal=endpoint="http://minio:9000" \
--from-literal=access_key_id="minio" \
--from-literal=access_key_secret="minio123"
```

Install Grafana tempo with the operator. We will use the secret created in the previous step:
```
kubectl apply -n tempo -f - <<EOF
apiVersion: tempo.grafana.com/v1alpha1
kind: TempoStack
metadata:
name: smm
spec:
storageSize: 1Gi
storage:
secret:
type: s3
name: tempostack-dev-minio
resources:
total:
limits:
memory: 2Gi
cpu: 2000m
template:
queryFrontend:
jaegerQuery:
enabled: true
ingress:
type: ingress
EOF
```

(Optional) We can test if minio is working with a batch job to send some traces, in this case, to th open telemetry collector: 
```
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
name: tracegen
spec:
template:
spec:
containers:
- name: tracegen
image: ghcr.io/open-telemetry/opentelemetry-collector-contrib/tracegen:latest
command:
- "./tracegen"
args:
- -otlp-endpoint=tempo-smm-distributor.tempo.svc.cluster.local:4317
- -otlp-insecure
- -duration=30s
- -workers=1
restartPolicy: Never
backoffLimit: 4
EOF
```

And access the minio console: 
```
kubectl port-forward --namespace istio-system service/minio 9001:9001
```

![MinIO console](/images/tutorial/tempo/minio.png "MinIO console")

We will install Istio now, using the kiali hack scripts:

```
istio/install-istio-via-istioctl.sh -c kubectl
```

# Edit Istio cm (And restart pod)
```
KUBE_EDITOR=nano k edit cm istio -n istio-system

      tracing:
        zipkin:
          address: tempo-smm-distributor.tempo:9411
```
Install kiali:
```
kubectl apply -f _output/istio-1.18.2/samples/addons/kiali.yaml
```

Install bookinfo with traffic generator
```
istio/install-bookinfo-demo.sh -c kubectl -tg
```

Update Kiali with the following:

```
tracing:
  enabled: true
  in_cluster_url: http://localhost:16685
  url: http://localhost:16686
```

And access Kiali: 

![Kiali Tempo Traces](/images/tutorial/tempo/kiali-tempo-traces.png "Kiali Tempo traces")