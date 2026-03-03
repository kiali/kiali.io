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


