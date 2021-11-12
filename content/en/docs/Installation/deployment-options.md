---
title: "Deployment Options"
description: >
  Simple configuration options related to the Kiali deployment, like the
  installation namespace, logger settings, resource limits and scheduling options
  for the Kiali pod.
weight: 30
---

There are other, more complex deployment settings, described in dedicated pages:
* [Authentication]({{< relref "../Configuration/authentication" >}})
* [Customization of the Ingress resource]({{< relref
  "installation-guide/accessing-kiali#ingress-access" >}})
* [Customization of the service type (LoadBalancer or
  NodePort)]({{< relref "installation-guide/accessing-kiali#accessing-kiali-through-a-loadbalancer-or-a-nodeport" >}})
* [Namespace management (configuring namespaces accessible and visible to
  Kiali)]({{< relref "../Configuration/namespace-management" >}})

{{% alert color="success" %}} All examples on this page are focused
on the Kiali CR (when installing via the Kiali operator). Remember
that Helm charts mirror all these configurations.
{{% /alert %}}

## Kiali and Istio installation namespaces

By default, the Kiali operator installs Kiali in the same namespace where the Kiali CR is created. However, it is possible to specify a different namespace for installation:

```yaml
spec:
  deployment:
    namespace: "custom-kiali-nameespace"
```

It is assumed that Kiali is installed to the same namespace as Istio. Kiali
reads some Istio resources and may not work properly if those resources are not
found. Thus, if you are installing Kiali and Istio on different namespaces, you
must specify what is the Istio namespace:

```yaml
spec:
  istio_namespace: "istio-system"
```

## Log level and format

By default, Kiali will print up to `INFO`-level messages in simple text format.
You can change the log level, output format, and time format as in the
following example:

```yaml
spec:
  deployment:
    logger:
      # Supported values are "trace", "debug", "info", "warn", "error" and "fatal"
      log_level: error  
      # Supported values are "text" and "json".
      log_format: json  
      time_field_format: "2006-01-02T15:04:05Z07:00"
```

The syntax for the `time_field_format` is the same as the [`Time.Format`
function of the Go language](https://pkg.go.dev/time#pkg-constants). 

The `json` format is useful if you are parsing logs of your applications for
further processing.

## Kiali instance name

If you plan to install more than one Kiali instance on the same cluster, you
may need to configure an instance name to avoid conflicts on created resources:

```yaml
spec:
  deployment:
    instance_name: "secondary"
```

The `instance_name` will be used as a prefix for all created Kiali resources.
The exception is the `kiali-signing-key` secret which will always have the same name
and will be shared on all deployments of the same namespace, unless you specify
a custom secret name.

{{% alert color="warning" %}}
Since the `instance_name` will be used as a name prefix in resources, it must
follow [Kubernetes naming
constraints](https://kubernetes.io/docs/concepts/overview/working-with-objects/names/).
{{% /alert %}}

{{% alert color="warning" %}}
Since Kubernetes resources cannot be renamed, you cannot change the
`instance_name` of an existing Kiali installation. The workaround is to
uninstall Kiali and re-install with the desired `instance_name`.
{{% /alert %}}

## Resource requests and limits

You can set the amount of resources available to Kiali using the
`spec.deployment.resources` attribute, like in the following example:

```yaml
spec:
  deployment:
    resources:
      requests:
        memory: "128Mi"
        cpu: "100m"
      limits:
        memory: "1Gi"
        cpu: "500m"
```

Please, read the [Managing Resources for Containers section in the Kubernetes
documentation](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
for more details about possible configurations.

## Custom labels and annotations on the Kiali pod and service

Although some labels and annotations are set on the Kiali pod and on its
service (depending on configurations), you can add additional ones. For the
pod, use the `spec.deployment.pod_labels` and `spec.deployment.pod_annotations`
attributes. For the service, you can only add annotations using the
`spec.deployment.service_annotations` attribute. For example:

```yaml
spec:
  deployment:
    pod_annotations:
      a8r.io/repository: "https://github.com/kiali/kiali"
    pod_labels:
      sidecar.istio.io/inject: "true"
    service_annotations:
      a8r.io/documentation: "https://kiali.io/docs/installation/deployment-configuration"
```

## Kiali page title (browser title bar)

If you have several Kiali installations and you are using them at the same
time, there are good chances that you will want to identify each Kiali by
simply looking at the browser's title bar. You can set a custom text in the
title bar with the following configuration:

```yaml
spec:
  installation_tag: "Kiali West"
```

The `installation_tag` is any human readable text of your desire.

## Kubernetes scheduler settings 

### Replicas and automatic scaling

By default, only one replica of Kiali is deployed. If needed, you can change the
replica count like in the following example:

```yaml
spec:
  deployment:
    replicas: 2
```

If you prefer automatic scaling, creation of an `HorizontalPodAutoscaler`
resource is supported. For example, the following configuration automatically
scales Kiali based on CPU utilization:

```yaml
spec:
  deployment:
    hpa:
      api_version: "autoscaling/v1"
      spec:
        minReplicas: 1
        maxReplicas: 2
        targetCPUUtilizationPercentage: 80
```

{{% alert color="warning" %}}
You must omit the `scaleTargetRef` field of the HPA spec, because this field
will be populated by the Kiali operator (or by Helm) depending on other
configuration.
{{% /alert %}}

Read the [Kubernetes Horizontal Pod Autoscaler
documentation](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
to learn more about the HPA.

### Allocating the Kiali pod to specific nodes of the cluster

You can constrain the Kiali pod to run on a specific set of nodes by using
some of the standard Kubernetes scheduler configurations.

The simplest option is to use [the
`nodeSelector`](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector)
configuration which you can configure like in the following example:

```yaml
spec:
  deployment:
    node_selector:
      worker-type: infra
```

You can also use the [affinity/anti-affinity native Kubernetes
feature](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity)
if you prefer its more expressive syntax, or if you need more complex matching
rules. The following is an example for configuring node affinity:

```yaml
spec:
  deployment:
    affinity:
      node:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
          - matchExpressions:
            - key: worker-type
              operator: In
              values:
              - infra
```

Similarly, you can also configure pod affinity and pod anti-affinity using the
`spec.deployment.affinity.pod` and `spec.deployment.affinity.pod_anti`
attributes.

Finally, if you want to run Kiali in a node with taints, the following is an
example to configure tolerations:

```yaml
spec:
  deployment:
    tolerations: # Allow to run Kiali in a tainted master node
    - key: "node-role.kubernetes.io/master"
      operator: "Exists"
      effect: "NoSchedule"
```

Read the following Kubernetes documentation to learn more about these configurations:
- [Assigning Pods to Nodes](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/)
- [Taints and Tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)

### Priority class of the Kiali pod

If you are using priority classes in your cluster, you can specify the
priority class that will be set on the Kiali pod. For example:

```yaml
spec:
  deployment:
    priority_class_name: high-priority
```

For more information about priority classes, read [Pod Priority and Preemption
in the Kubernetes
documentation](https://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/).

## Adding host aliases to the Kiali pod

If you need to provide some static hostname resolution in the Kiali pod, you
can use [HostAliases to add entries to the `/etc/hosts`
file](https://kubernetes.io/docs/tasks/network/customize-hosts-file-for-pods/)
of the Kiali pod, like in the following example:

```yaml
spec:
  deployment:
   host_aliases:
   - ip: 192.168.1.100
     hostnames:
     - "foo.local"
     - "bar.local"
```

