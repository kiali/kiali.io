---
title: "Configure Kiali for multicluster"
description: "In this section we will add some configuration for Kiali to start observing the remote cluster."
weight: 9
---

We will configure Kiali to access the remote cluster. This will require a secret (similar to the Istio secret) containing the credentials for Kiali to fetch information for the remote cluster:

```
curl -L -o kiali-prepare-remote-cluster.sh https://raw.githubusercontent.com/kiali/kiali/master/hack/istio/multicluster/kiali-prepare-remote-cluster.sh

chmod +x kiali-prepare-remote-cluster.sh

./kiali-prepare-remote-cluster.sh --kiali-cluster-context $CLUSTER_EAST --remote-cluster-context $CLUSTER_WEST
```

Finally, upgrade the installation for Kiali to pick up the secret:

```
helm upgrade \ 
    --set cr.create=true \ 
    --set cr.namespace=istio-system \ 
    --set cr.spec.auth.strategy=anonymous \ 
    --namespace kiali-operator \ 
    --create-namespace \ 
    kiali-server \ 
    kiali/kiali-server
```

As result, we can quickly see that a new namespace appear in the Overview, the istio-system namespace from west cluster:

![Kiali MC](/images/mc-tutorial/03.png "Kiali MC")
