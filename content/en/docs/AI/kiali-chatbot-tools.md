---
title: "Kiali Chatbot tools (schemas)"
description: >
  Input/output schemas for the built-in Kiali AI tools.
weight: 15
---

Kiali Chatbot uses **internal MCP-style tools** (implemented inside Kiali) to fetch live data and perform safe actions. These are **not** external MCP server tools.

The tool **input schemas** are defined in Kiali under `kiali/ai/mcp/tools/*.yaml`. The tool **outputs** are JSON structures returned by the Kiali backend and consumed by the model and/or UI.

### Tool list

- `get_action_ui`: returns UI navigation actions (buttons/links).
- `get_citations`: returns documentation links relevant to the user query.
- `get_mesh_graph`: returns mesh health/topology summaries (and supporting raw payloads).
- `get_resource_detail`: returns service/workload details or lists (same payload shapes as existing Kiali APIs).
- `get_pod_performance`: returns usage vs requests/limits summary (CPU/memory).
- `get_traces`: returns a compact trace summary (bottlenecks/errors).
- `get_logs`: returns workload/pod logs with optional filtering.
- `manage_istio_config`: list/get/create/patch/delete Istio objects (with a confirmation gate for sensitive actions).

### Schemas

#### `get_action_ui`

- **Input schema**:

```yaml
- name: "get_action_ui"
  description: "Returns the action to navigate in the Kiali UI when user request see graph or mesh graph,list/get/show resources or a detailed resource information"
  input_schema:
    type: "object"
    required: ["resourceType"]
    properties:
      namespaces:
        type: "string"
        description: "Comma-separated list of namespaces in case of list/show resources or graph, just one namespace in case of get or show resource. If empty, will use all namespaces accessible to the user."
      resourceType:
        type: "string"
        description: "Type of resource to get a view of : list resources,details of a resource, traffic/mesh graph or overview of namespaces"
        enum: ["service", "workload", "app", "istio", "graph", "overview"]
      resourceName:
        type: "string"
        description: "Optional. Name of the resource to get details for (optional string - if provided, gets details; if empty, lists all)."
      graph:
        type: "string"
        description: "Optional. If resourceType is graph, you can specify the type of graph to return: Mesh if user request mesh or traffic graph (Values: mesh|traffic). Mesh graph no required namespaces parameter, traffic graph have an optional namespaces parameter. Default graph is traffic"
        enum: ["mesh", "traffic"]
      graphType:
        type: "string"
        description: "Optional type of graph to return. Default is 'versionedApp'."
        enum: ["versionedApp", "app", "service", "workload"]
      tab:
        type: "string"
        description: "Optional. Tab to open in case of show resource details. Default is info."
        enum: ["info", "logs", "metrics", "in_metrics", "out_metrics", "traffic", "traces", "envoy"]
```

- **Output schema (JSON)**:
  - `actions[]`: array of `Action`
    - `title` (string)
    - `kind` (string; `navigation` or `file`)
    - `payload` (string; URL or file contents depending on kind)
    - `fileName` (string; only when `kind=file`)
  - `errors` (string; optional)

#### `get_citations`

- **Input schema**:

```yaml
- name: "get_citations"
  description: "Returns the links to a documentation page related with a list of keywords related with the user query. The keywords are comma-separated."
  input_schema:
    type: "object"
    required: ["keywords"]
    properties:
      keywords:
        type: "string"
        description: "Comma-separated list of keywords to search for in the documents"
      domain:
        type: "string"
        description: "Optional. Domain to search for the documents. Possible values: kiali, istio. If not provided, will search in all domains."
        enum: ["kiali", "istio", "all", ""]
```

- **Output schema (JSON)**:
  - `citations[]`: array of `Citation`
    - `link` (string)
    - `title` (string)
    - `body` (string)
  - `errors` (string; optional)

#### `get_mesh_graph`

- **Input schema**:

```yaml
- name: "get_mesh_graph"
  description: "Returns the mesh graph data for the given namespaces and graph type."
  input_schema:
    type: "object"
    properties:
      namespace:
        type: "string"
        description: "Optional single namespace to include in the graph (alternative to namespaces)"
      namespaces:
        type: "string"
        description: "Comma-separated list of namespaces to include in the graph"
      graphType:
        type: "string"
        description: "Type of graph to return. Possible values: versionedApp, app, service, workload"
        enum: ["versionedApp", "app", "service", "workload"]
      rateInterval:
        type: "string"
        description: "Optional rate interval for fetching (e.g., '10m', '5m', '1h'). Default is '10m'."
      clusterName:
        type: "string"
        description: "Optional cluster name to include in the graph. Default is the cluster name in the Kiali configuration (KubeConfig)."
```

- **Output schema (JSON)**:
  - `mesh_health_summary` (object; optional): aggregated health summary for the selected namespaces
  - `graph` (object; optional): raw graph payload (Kiali graph API)
  - `mesh_status` (object; optional): raw mesh status payload
  - `namespaces` (array; optional): raw namespaces payload
  - `errors` (object map; optional): keyed error strings (e.g. `graph`, `health`, `mesh_status`, `namespaces`)

#### `get_resource_detail`

- **Input schema**:

```yaml
- name: "get_resource_detail"
  description: "Returns the resource detail data for the given resource type, namespaces and resource name."
  input_schema:
    type: "object"
    required: ["resourceType"]
    properties:
      resourceType:
        type: "string"
        description: "Type of resource to get list/details"
        enum: ["service", "workload", "app", "istio"]
      namespaces:
        type: "string"
        description: "Comma-separated list of namespaces to get services from (e.g. 'bookinfo' or 'bookinfo,default'). If not provided, will list services from all accessible namespaces"
      resourceName:
        type: "string"
        description: "Name of the resource to get details for (optional string - if provided, gets details; if empty, lists all)."
      clusterName:
        type: "string"
        description: "Name of the cluster to get resources from. If not provided, will use the cluster name in the Kiali configuration (KubeConfig)."
```

- **Output schema (JSON)**:
  - **List mode** (`resourceName` empty): returns the same JSON payloads as Kiali list endpoints (e.g. service list / workload list) aggregated across namespaces.
  - **Detail mode** (`resourceName` set): returns the same JSON payload shapes as Kiali detail endpoints (service details / workload details), including validations/health where applicable.

#### `get_pod_performance`

- **Input schema**:

```yaml
- name: "get_pod_performance"
  description: "Returns a human-readable text summary with current Pod CPU/memory usage (from Prometheus) compared to Kubernetes requests/limits (from the Pod spec). Useful to answer questions like 'Is this workload using too much memory?'."
  input_schema:
    type: "object"
    required: ["namespace"]
    anyOf:
    - required: ["podName"]
    - required: ["workloadName"]
    properties:
      namespace:
        type: "string"
        description: "Kubernetes namespace of the Pod."
      podName:
        type: "string"
        description: "Kubernetes Pod name. If workloadName is provided, the tool will attempt to resolve a Pod from that workload first."
      workloadName:
        type: "string"
        description: "Kubernetes Workload name (e.g. Deployment/StatefulSet/etc). Tool will look up the workload and pick one of its Pods. If not found, it will fall back to treating this value as a podName."
      timeRange:
        type: "string"
        description: "Time window used to compute CPU rate (Prometheus duration like '5m', '10m', '1h', '1d'). Defaults to '10m'."
      queryTime:
        type: "string"
        description: "Optional end timestamp (RFC3339) for the query. Defaults to now."
      clusterName:
        type: "string"
        description: "Optional cluster name. Defaults to the cluster name in the Kiali configuration (KubeConfig)."
```

- **Output schema (JSON)**:
  - `cluster` (string)
  - `namespace` (string)
  - `workload_name` (string; optional)
  - `pod_name` (string)
  - `resolved_from` (string; optional; `"workload"` or `"pod"`)
  - `time_range` (string)
  - `query_time` (timestamp)
  - `cpu` / `memory` (object): `usage`, `request`, `limit` (+ ratios when available)
  - `containers[]` (optional): per-container breakdown of `cpu`/`memory`
  - `errors` (map; optional)

#### `get_traces`

- **Input schema**:

```yaml
- name: "get_traces"
  description: "Fetches a distributed trace (Jaeger/Tempo) by trace_id or searches by service_name (optionally only error traces) and summarizes bottlenecks and error spans."
  input_schema:
    type: "object"
    properties:
      trace_id:
        type: "string"
        description: "Trace ID to fetch and summarize. If provided, namespace/service_name are ignored."
      namespace:
        type: "string"
        description: "Kubernetes namespace of the service (required when trace_id is not provided)."
      service_name:
        type: "string"
        description: "Service name to search traces for (required when trace_id is not provided)."
      error_only:
        type: "boolean"
        description: "If true, only consider traces that contain errors (e.g. error=true / non-200 status). Default false."
      cluster_name:
        type: "string"
        description: "Optional cluster name. Defaults to the cluster name in the Kiali configuration."
      lookback_seconds:
        type: "integer"
        description: "How far back to search when using service_name. Default 600 (10m)."
      limit:
        type: "integer"
        description: "Max number of traces to consider when searching by service_name. Default 10."
      max_spans:
        type: "integer"
        description: "Max number of spans to return in each summary section (bottlenecks, errors, roots). Default 7."
```

- **Output schema (JSON)**:
  - `found` (boolean)
  - `trace_id` (string; optional)
  - `query` (object): echoed query args
  - `summary` (object; optional):
    - `total_duration_ms` (number)
    - `total_spans` (integer)
    - `bottlenecks[]`, `error_spans[]`, `error_chain[]`, `root_spans[]` (arrays of span briefs)
    - `warnings[]` (array of strings; optional)

#### `get_logs`

- **Input schema**:

```yaml
- name: "get_logs"
  description: "Get the logs of a Kubernetes Pod (or workload name that will be resolved to a pod) in a namespace. Output is plain text, matching kubernetes-mcp-server pods_log."
  input_schema:
    type: "object"
    required: ["namespace", "name"]
    properties:
      namespace:
        type: "string"
        description: "Namespace to get the Pod logs from"
      name:
        type: "string"
        description: "Name of the Pod to get the logs from. If it does not exist, it will be treated as a workload name and a running pod will be selected."
      workload:
        type: "string"
        description: "Optional workload name override (used when name lookup fails)."
      container:
        type: "string"
        description: "Name of the Pod container to get the logs from (Optional)"
      tail:
        type: "integer"
        description: "Number of lines to retrieve from the end of the logs (Optional, default: 50). Cannot exceed 200 lines."
      severity:
        type: "string"
        description: "Optional severity filter applied client-side. Accepts 'ERROR', 'WARN' or combinations like 'ERROR,WARN'."
      previous:
        type: "boolean"
        description: "Return previous terminated container logs (Optional)"
      cluster_name:
        type: "string"
        description: "Optional cluster name. Defaults to the cluster name in the Kiali configuration."
      format:
        type: "string"
        description: "Output formatting for chat. 'codeblock' wraps logs in ~~~ fences (recommended). 'plain' returns raw text like kubernetes-mcp-server pods_log."
        enum: ["codeblock", "plain"]
```

- **Output schema (JSON)**:
  - `query` (object): echoed query args (including resolved pod/workload)
  - `lines[]` (array of strings; optional)
  - `returned_lines` (integer; optional)
  - `matched_lines` (integer; optional)
  - `truncated_by_bytes` (boolean; optional)
  - `warnings[]` (array of strings; optional)

#### `manage_istio_config`

- **Input schema**:

```yaml
- name: "manage_istio_config"
  description: "Manages the Istio config for the given cluster, namespace, group, version, kind and object."
  input_schema:
    type: "object"
    required: ["action", "confirmed"]
    properties:
      action:
        type: "string"
        description: "Action to perform"
        enum: ["list", "get", "create", "patch", "delete"]
      confirmed:
        type: "boolean"
        description: "CRITICAL: For 'create', 'patch', or 'delete' actions. If 'true', the destructive action (create/patch/delete) is executed. If 'false' (or omitted) for create/patch, the tool will return a YAML PREVIEW of the object. You should display this YAML to the user and ask for confirmation before calling this tool again with confirmed=true."
      cluster:
        type: "string"
        description: "Cluster containing the Istio object, if not provided, will use the cluster name in the Kiali configuration (KubeConfig)"
      namespace:
        type: "string"
        description: "Namespace containing the Istio object, if not provided, will return all istio objects across all namespaces in the cluster"
      group:
        type: "string"
        description: "API group of the Istio object (e.g., 'networking.istio.io', 'gateway.networking.k8s.io'). Required for create, patch, and get actions."
      version:
        type: "string"
        description: "API version. IMPORTANT: Use 'v1' for VirtualService, DestinationRule, and Gateway. Do NOT use 'v1alpha3'.. Required for create, patch, and get actions."
      kind:
        type: "string"
        description: "Kind of the Istio object (e.g., 'VirtualService', 'DestinationRule'). Required for create, patch, and get actions."
      object:
        type: "string"
        description: "Name of the Istio object. Required for patch,get,create and delete actions."
      json_data:
        type: "string"
        description: "JSON data to apply or create the object. Required for create and patch actions."
```

- **Output schema (JSON)**:
  - For `action=list|get|create|patch|delete`: returns the corresponding Kiali Istio config payload (or error message).
  - **Confirmation gate**: for `create|patch|delete` when `confirmed=false`, the tool returns:
    - `actions[]`: a `file` action containing a preview payload (from `json_data`)
    - `result`: a message instructing the assistant to ask the user for confirmation

