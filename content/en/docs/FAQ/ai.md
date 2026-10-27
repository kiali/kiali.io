---
title: "AI"
description: "Questions about AI."
---

### What is Kiali Chatbot and what is its status?

Kiali Chatbot is Kiali's built-in AI assistant in the Kiali UI. It helps users ask questions about their service mesh and get responses grounded in live Kiali data (for example, graph, metrics, traces, logs, and resource details).

The chatbot was first released in Kiali 2.22 and is currently in **Dev preview**. See [Kiali Chatbot]({{< relref "../AI/chatbot/kiali-chatbot" >}}) for details.

### Does Kiali Chatbot require an external MCP server?

No. Kiali Chatbot does not require an external MCP server. It uses internal MCP-style tools implemented in Kiali itself.

If you want to use Kiali from an external AI assistant (for example, an IDE assistant), see [Kiali MCP]({{< relref "../AI/kiali-mcp" >}}), which is exposed through upstream MCP servers such as the Kubernetes MCP server and OpenShift MCP server.

### Which AI providers and models are supported?

Kiali Chatbot supports these providers:

- OpenAI (`type: openai`)
- Google (`type: google`)
- Anthropic (`type: anthropic`)
- Lightspeed (`type: lightspeed`)

Providers and models are configured in `ai.chat` and selected in the chatbot UI. API keys can be configured inline or, preferably, by secret reference (`secret:<secret-name>:<key-in-secret>`). See [Kiali Chatbot]({{< relref "../AI/chatbot/kiali-chatbot" >}}) for configuration examples.

### What tools can the Kiali Chatbot use?

Kiali Chatbot can use internal tools for:

- UI navigation (`get_action_ui`)
- Documentation citations (`get_referenced_docs`)
- Mesh status and traffic graph
- Resource list/detail lookups
- Metrics, traces, and logs
- Pod performance analysis
- Istio config read and managed operations

For the full tool list and schemas, see [Kiali Chatbot tools (schemas)]({{< relref "../AI/chatbot/kiali-chatbot-tools" >}}).

### Can the chatbot modify Istio configuration directly?

The chatbot supports Istio config operations through tool-based flows. In the current UI workflow, configuration changes are prepared first for user review and confirmation before application.

For operational details and supported actions, see [Kiali Chatbot tools (schemas)]({{< relref "../AI/chatbot/kiali-chatbot-tools" >}}).

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

You can configure this under `ai.chat.store_config` in the Kiali configuration.

### Why does the chatbot response appear progressively?

Kiali Chatbot uses streaming events, so responses are rendered incrementally instead of waiting for one final payload. This allows the UI to show token-by-token text generation and tool execution updates in real time.

### What happens if Prometheus or tracing is disabled?

Some AI **tools** depend on these backends:

- Metrics-related tools require Prometheus.
- Trace-related tools require tracing (Jaeger/Tempo).

If these services are disabled, related tool calls are not available and the chatbot returns an informative error for those requests.

This is not the same as `ai.metrics`, which records ChatAI token usage for consumption, prices, and budgets. See [Why don't I see AI consumption or cost estimates?](#why-dont-i-see-ai-consumption-or-cost-estimates).

### Why do I sometimes get partial answers or missing data?

AI answers depend on what Kiali can access from your cluster and backends. If RBAC permissions are limited, namespaces/resources are restricted, or backends are unavailable, the chatbot can return partial or unavailable results.

### Are all tool results shown in the same way in chat?

Not always. Some tools return data payloads that are shown in tool result cards and modal details. Others are UI-helper tools (navigation and documentation) that trigger UI actions or references rather than showing large raw payloads in the chat body.

### Can I disable conversation storage?

Yes. You can disable AI conversation storage by setting `ai.chat.store_config.enabled: false`.

### How is long chat history handled?

Long conversations can be reduced according to `ai.chat.store_config` settings. Depending on configuration, Kiali can either truncate older messages or summarize prior history to keep the conversation context manageable.

### Why don't I see AI consumption or cost estimates? {#why-dont-i-see-ai-consumption-or-cost-estimates}

**`ai.metrics` must be enabled** (`ai.metrics: true`). That setting records ChatAI token usage. It is independent of Prometheus.

If metrics are disabled, Kiali does not record usage, does not estimate cost, does not enforce [budgets]({{< relref "../AI/chatbot/kiali-chatbot-budgets" >}}), and does not show the consumption dashboard. After you enable it, use the chatbot so there is traffic to display.

See [Token prices]({{< relref "../AI/chatbot/kiali-chatbot-prices" >}}).

### Do I have to configure token prices?

No. If you leave `ai.consumption.prices_config_map` empty, Kiali uses the built-in catalog ([config/ai_default_prices.yaml](https://github.com/kiali/kiali/blob/master/config/ai_default_prices.yaml)). Create a ConfigMap only when you want your own rates (contract pricing, a missing model, or LightSpeed). See [Token prices]({{< relref "../AI/chatbot/kiali-chatbot-prices" >}}).

### Why do I see token counts but no cost?

Kiali shows cost only when the catalog has a row whose `provider` and `model_id` match the model that was used. Tokens still appear when there is no match. Add that model to a custom `prices.yaml` catalog, or cost stays omitted. See [Token prices]({{< relref "../AI/chatbot/kiali-chatbot-prices" >}}).

### I updated the prices ConfigMap. Why didn't the costs change?

Kiali reads prices when it loads configuration, not continuously. Restart the Kiali pod after you change the ConfigMap. Also confirm the ConfigMap is in Kiali's namespace, the data key is `prices.yaml`, and `ai.consumption.prices_config_map` is that ConfigMap's name.

### Why is the chatbot rejecting my request?

A [budget]({{< relref "../AI/chatbot/kiali-chatbot-budgets" >}}) may apply to your user. Kiali rejects the request when:

- The selected provider is not in `allowed_providers`
- The selected model is not in `allowed_models`
- Used cost or tokens for the current `weekly` or `monthly` interval have reached `max_cost` or `max_tokens`

Empty `budgets` means no restrictions. **`ai.metrics` must be enabled** for budgets to be enforced.

### What does `max_tokens` mean in a budget?

It is **millions** of tokens, not a raw count. `max_tokens: 10` means 10 million tokens in the budget interval.

### Who can see the AI consumption dashboard?

`ai.consumption.allowed_users_dashboard` lists usernames that may open it. If the list is empty (the default), all authenticated users can. That list is independent of `ai.chat.allowed_users`, which controls who can use the chatbot.

You can chat without being allowed to see the dashboard, and you can see the dashboard without a chatbot budget applying to you. See [Token prices]({{< relref "../AI/chatbot/kiali-chatbot-prices" >}}) and [Budgets]({{< relref "../AI/chatbot/kiali-chatbot-budgets" >}}).

### Can I use Kiali AI capabilities outside the Kiali UI?

Yes. You can use Kiali through MCP-capable assistants by running an MCP server with the Kiali toolset enabled. See [Kiali MCP]({{< relref "../AI/kiali-mcp" >}}) for prerequisites and setup.
