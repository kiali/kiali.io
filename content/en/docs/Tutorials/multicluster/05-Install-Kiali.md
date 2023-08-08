---
title: "Install Kiali"
description: "Install Kiali on the primary cluster"
weight: 5
---

Run the following command to install Kiali using the Kiali operator:

```
kubectl config use-context $CLUSTER_EAST

helm upgrade --install --namespace istio-system --set kubernetes_config.cache_enabled=false --set auth.strategy=anonymous --set deployment.logger.log_level=debug --set deployment.ingress.enabled=true --repo https://kiali.org/helm-charts kiali-server kiali-server 
```