---
title: "AI"
description: "Questions about AI."
---

### What is Kiali Chatbot and what is its status?

Kiali Chatbot is Kiali's built-in AI assistant in the Kiali UI. It helps users ask questions about their service mesh and get responses grounded in live Kiali data (for example, graph, metrics, traces, logs, and resource details).

The chatbot was first released in Kiali 2.22 and is currently in **Dev preview**. See [Kiali Chatbot]({{< relref "/docs/ai/kiali-chatbot" >}}) for details.

### Does Kiali Chatbot require an external MCP server?

No. Kiali Chatbot does not require an external MCP server. It uses internal MCP-style tools implemented in Kiali itself.

If you want to use Kiali from an external AI assistant (for example, an IDE assistant), see [Kiali MCP]({{< relref "/docs/ai/kiali-mcp" >}}), which is exposed through upstream MCP servers such as the Kubernetes MCP server and OpenShift MCP server.

### Which AI providers and models are supported?

Kiali Chatbot supports these providers:

- OpenAI (`type: openai`)
- Google (`type: google`)
- Anthropic (`type: anthropic`)
- Lightspeed (`type: lightspeed`)

Providers and models are configured in `chat_ai` and selected in the chatbot UI. API keys can be configured inline or, preferably, by secret reference (`secret:<secret-name>:<key-in-secret>`). See [Kiali Chatbot]({{< relref "/docs/ai/kiali-chatbot" >}}) for configuration examples.

### What tools can the Kiali Chatbot use?

Kiali Chatbot can use internal tools for:

- UI navigation (`get_action_ui`)
- Documentation citations (`get_referenced_docs`)
- Mesh status and traffic graph
- Resource list/detail lookups
- Metrics, traces, and logs
- Pod performance analysis
- Istio config read and managed operations

For the full tool list and schemas, see [Kiali Chatbot tools (schemas)]({{< relref "/docs/ai/kiali-chatbot-tools" >}}).

### Can the chatbot modify Istio configuration directly?

The chatbot supports Istio config operations through tool-based flows. In the current UI workflow, configuration changes are prepared first for user review and confirmation before application.

For operational details and supported actions, see [Kiali Chatbot tools (schemas)]({{< relref "/docs/ai/kiali-chatbot-tools" >}}).

### What information is sent to the LLM when Kiali Chatbot is enabled?

At a high level, Kiali sends:

1. The user message.
2. Chat context from the UI request (for example, page description/state/URL when provided).
3. The conversation history kept for that chat session (if AI store is enabled).
4. The system instruction and tool definitions so the model can call Kiali tools.
5. Tool results needed to answer the question (for example, mesh/resource/metrics/logs/traces data returned by the selected tools).

The defined tools are the same as the ones in the Kubernetes MCP server ([containers/kubernetes-mcp-server](https://github.com/containers/kubernetes-mcp-server)), plus two additional ones used for UI-specific behavior:

- **Navigation**: For example, "Show me the services in my bookinfo namespace" (Kiali navigates to the service list view).
- **Documentation**: Kiali provides links to the `istio.io` and `kiali.io` documentation.

### Are chat conversations stored by Kiali?

Kiali has an AI store used to preserve conversation context across requests. It is enabled by default and supports cache limits and optional conversation reduction behavior.

You can configure this under `chat_ai.store_config` in the Kiali configuration.

### Why does the chatbot response appear progressively?

Kiali Chatbot uses streaming events, so responses are rendered incrementally instead of waiting for one final payload. This allows the UI to show token-by-token text generation and tool execution updates in real time.

### What happens if Prometheus or tracing is disabled?

Some AI tools depend on these backends:

- Metrics-related tools require Prometheus.
- Trace-related tools require tracing (Jaeger/Tempo).

If these services are disabled, related tool calls are not available and the chatbot returns an informative error for those requests.

### Why do I sometimes get partial answers or missing data?

AI answers depend on what Kiali can access from your cluster and backends. If RBAC permissions are limited, namespaces/resources are restricted, or backends are unavailable, the chatbot can return partial or unavailable results.

### Are all tool results shown in the same way in chat?

Not always. Some tools return data payloads that are shown in tool result cards and modal details. Others are UI-helper tools (navigation and documentation) that trigger UI actions or references rather than showing large raw payloads in the chat body.

### Can I disable conversation storage?

Yes. You can disable AI conversation storage by setting `chat_ai.store_config.enabled: false`.

### How is long chat history handled?

Long conversations can be reduced according to `chat_ai.store_config` settings. Depending on configuration, Kiali can either truncate older messages or summarize prior history to keep the conversation context manageable.

### Can I use Kiali AI capabilities outside the Kiali UI?

Yes. You can use Kiali through MCP-capable assistants by running an MCP server with the Kiali toolset enabled. See [Kiali MCP]({{< relref "/docs/ai/kiali-mcp" >}}) for prerequisites and setup.
