---
title: "Kiali Chatbot tools (schemas)"
description: >
  Input/output schemas for the built-in Kiali AI tools.
weight: 15
---

Kiali Chatbot uses **internal MCP-style tools** (implemented inside Kiali) to fetch live data and perform safe actions. These are **not** external MCP server tools.

Administrators can control which of these tools are exposed to the AI by using `ai.chat.tools` for global filtering and `ai.chat.providers[].tools` for provider-specific filtering. Use the exact tool names below in `enabled_tools` and `disabled_tools`.

The tool **input schemas** are defined in Kiali under `kiali/ai/mcp/tools/*.yaml`. The tool **outputs** are JSON structures returned by the Kiali backend and consumed by the model and/or UI.

### Tool list

- `get_action_ui`: returns UI navigation actions (buttons/links).
- `get_logs`: returns workload or pod logs with optional filtering.
- `get_mesh_status`: returns high-level mesh health, control plane, observability stack, and connectivity status.
- `get_mesh_traffic_graph`: returns a compact service-to-service traffic topology with metrics such as throughput, response time, and mTLS.
- `get_metrics`: returns Istio or Envoy metrics for services, workloads, or apps.
- `get_pod_performance`: returns current pod CPU and memory usage versus requests and limits.
- `get_referenced_docs`: returns relevant Istio and Kiali documentation links.
- `get_trace_details`: returns the hierarchy and span details for a specific trace.
- `list_or_get_resources`: lists resources or returns details for services, workloads, apps, and namespaces.
- `list_traces`: returns a compact list of distributed traces for a service.
- `manage_istio_config_read`: lists or gets Istio config in read-only mode.
- `manage_istio_config`: creates, patches, or deletes Istio config with a confirmation flow for sensitive actions.


