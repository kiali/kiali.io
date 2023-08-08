---
title: "Install Kiali"
description: "Install Kiali on the primary cluster"
weight: 5
---

Run the following command to install Kiali using the Kiali operator:

```
helm install \ 
    --set cr.create=true \ 
    --set cr.namespace=istio-system \ 
    --set cr.spec.auth.strategy=anonymous \ 
    --namespace kiali-operator \ 
    --create-namespace \ 
    kiali-server \ 
    kiali/kiali-server
```