---
title: "Kiali Chatbot"
description: >
  Query Kiali and your service mesh using an AI assistant.
weight: 10
---

Kiali Chatbot is Kiali’s built-in AI assistant in the Kiali UI. It lets you ask questions about your service mesh and get answers backed by live data from Kiali and its configured backends (Prometheus, tracing, Kubernetes, etc.).

It does **not** require an external MCP server. Kiali includes its own set of MCP-style tools internally, so the AI can call them without depending on a separate MCP deployment.

![Kiali Chatbot](/images/documentation/ai/kiali-chatbot.png)

### Status

The Kiali chatbot was first released in Kiali version 2.22 and it is in **Dev preview**.

### How does it work

At a high level:

- The Kiali UI sends your chat request (prompt + context + selected model) to the Kiali backend.
- Kiali selects the configured provider/model from `chat_ai`.
- The provider calls the LLM with a set of **internal MCP tools** (defined in Kiali under `kiali/ai/mcp`).
- The LLM may request tool calls (e.g. mesh graph, traces, resource details, workload logs, Istio config operations).
- Kiali executes those tool calls against Kiali/Kubernetes/Prometheus/tracing backends and returns the final answer, including optional UI navigation actions and documentation citations.
- The response is delivered as **streaming events** (for example: `start`, `token`, `tool_call`, `tool_result`, `end`, `error`) so the UI can progressively render tokens and tool activity in real time.

For configuration keys (enable/disable, tool filters, providers/models, store), see the `chat_ai` section in the [Kiali CR spec](/docs/configuration/kialis.kiali.io/#.spec.chat_ai).

![Kiali Chatbot architecture](/images/documentation/ai/kiali-chatbot-architecture.png)

### Tool schemas (inputs/outputs)

Kiali Chatbot uses internal tools with defined input schemas and structured outputs. 

### Configuring the Kiali Chatbot

The Kiali Chatbot is disabled by default. To enable it, set `chat_ai.enabled: true`.
When enabled, you will see the chatbot icon in the Kiali UI:

![Kiali Chatbot icon](/images/documentation/ai/chatbot-icon.png)

You must also configure at least one provider and model (including an API key), and pick a default provider/model.

### Switching model providers

Kiali Chatbot providers and models are configured in `chat_ai`:

- Providers: OpenAI (`type: openai`), Google (`type: google`), Anthropic (`type: anthropic`), and LightSpeed (`type: lightspeed`).
- Models are selected by name (per-provider) and can be enabled/disabled.
- API keys can be set inline (not recommended) or via `secret:<secret-name>:<key-in-secret>`.
- Tool exposure can be filtered globally with `chat_ai.tools` and further restricted per provider with `chat_ai.providers[].tools`.

Example configuration (showing three providers: OpenAI, Google, and Anthropic):

```yaml
chat_ai:
  enabled: true
  default_provider: "openai"
  tools:
    disabled_tools:
      - "manage_istio_config"
  providers:
    - name: "openai"
      enabled: true
      description: "OpenAI provider"
      type: "openai"
      config: "default"
      default_model: "gpt"
      tools:
        enabled_tools:
          - "get_logs"
          - "get_mesh_status"
          - "list_traces"
      models:
        - name: "gpt"
          enabled: true
          model: "<openai-model-name>"
          key: "secret:my-key-secret:openai-api-key"
    - name: "google"
      enabled: true
      description: "Google provider"
      type: "google"
      config: "gemini"
      default_model: "gemini"
      models:
        - name: "gemini"
          enabled: true
          model: "gemini-2.5-pro"
          description: "Model provided by Google with OpenAI API Support"
          endpoint: "https://generativelanguage.googleapis.com/v1beta/openai"
          key: "secret:my-key-secret:google-api-key"
    - name: "anthropic"
      enabled: true
      description: "Anthropic provider"
      type: "anthropic"
      config: "default"
      default_model: "claude-haiku"
      key: "secret:my-key-secret:claude-api-key"
      models:
        - name: claude-sonnet
          model: "claude-sonnet-4-5"
          enabled: true
          endpoint: "https://api.anthropic.com/"
        - name: claude-haiku
          model: "claude-haiku-4-5"
          enabled: true
```

`enabled_tools` acts as an allowlist: when set, only the listed tool names are exposed. `disabled_tools` acts as a denylist and is applied afterwards. You can define these filters globally under `chat_ai.tools` and/or per provider under `chat_ai.providers[].tools`. Provider-level filters can only further restrict the already-allowed global toolset.

To see the available built-in tool names you can use in these lists, see [Kiali Chatbot tools]({{< relref "kiali-chatbot-tools" >}}).

LightSpeed provider example:

```yaml
chat_ai:
  providers:
    - name: "LightSpeed"
      description: "Openshift LightSpeed"
      type: "lightspeed"
      endpoint: "<LightSpeed endpoint>"
      enabled: true
```

### TLS verification

By default, Kiali verifies the TLS certificate of AI provider endpoints. Kiali uses its CA bundle (`kiali-cabundle` ConfigMap) and the platform TLS policy when connecting to providers.

If the provider uses a self-signed certificate that is not in Kiali's CA bundle, you can disable TLS verification per provider:

```yaml
chat_ai:
  providers:
    - name: "LightSpeed"
      type: "lightspeed"
      endpoint: "https://lightspeed-app-server.openshift-lightspeed.svc:8443"
      enabled: true
      insecure_skip_verify: true
```

{{< alert color="warning" >}}
Setting `insecure_skip_verify: true` disables certificate validation for that provider. Use this only for development or testing. In production, add the provider's CA certificate to the `kiali-cabundle` ConfigMap instead.
{{< /alert >}}

You can also select the configured models and providers in the chatbot window:

![Kiali Chatbot models](/images/documentation/ai/kiali-chatbot-models.png)

When the assistant uses a tool, Kiali shows a tool-result card directly in the chat so you can see which tool was executed:

![Kiali Chatbot tool result card](/images/documentation/ai/kiali-chatbot-tool.png)

You can click the square tool-result card to open the full tool output in a modal window:

![Kiali Chatbot tool result modal](/images/documentation/ai/kiali-chatbot-tool-modal.png)

In this modal view you can inspect the complete tool response in detail (for example returned resources, metrics, or logs) before continuing the conversation.

### Streaming events in the chat

Kiali Chatbot UI updates are powered by server-sent streaming events from the backend. This is why responses appear incrementally (token by token), and why tool usage is shown as it happens.

In practice:

- `token` events render incremental assistant text.
- `tool_call` and `tool_result` events render the tool card and its status/output.
- `end` finalizes the answer, including optional UI actions and documentation references.
- `error` reports failures without waiting for a full response timeout.

### What you can ask

Examples of tasks that work well:

- Mesh/namespace topology and summaries (graph, status)
- Basic observability questions (metrics, traces)
- Troubleshooting workflows (get logs for a workload, identify failing namespaces)

### Example prompts

- “Show me the mesh graph for namespace `bookinfo`.”
- “Which workloads in `istio-system` look unhealthy and why?”
- “Get traces for service `productpage` in `bookinfo` for the last 30m.”

### Next step

If you want to use an AI assistant outside the Kiali UI (for example, in an IDE), see [Kiali MCP]({{< relref "kiali-mcp" >}}).

