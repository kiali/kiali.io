---
title: "Token prices"
description: >
  Configure per-model token prices used to estimate ChatAI consumption cost.
weight: 12
---

Kiali can estimate the monetary cost of ChatAI usage from a **per-model token price catalog**. Those estimates appear on the AI consumption dashboard and can be used with optional per-user [budgets]({{< relref "kiali-chatbot-budgets" >}}).

**To use consumption tracking, token prices, and the AI consumption dashboard, `ai.metrics` must be enabled (`ai.metrics: true`).** If metrics are disabled, Kiali does not record token usage, does not estimate cost, and does not show consumption data.

Cost estimates, dashboard access, and the price catalog are configured under `ai.consumption`. For the configuration keys, see `ai.metrics` and `ai.consumption` in the [Kiali CR spec](/docs/configuration/kialis.kiali.io/#.spec.ai).

### Default catalog

You do **not** have to configure token prices. If `ai.consumption.prices_config_map` is omitted or left empty (`""`), Kiali automatically uses the built-in catalog shipped in the Kiali binary:

[config/ai_default_prices.yaml](https://github.com/kiali/kiali/blob/master/config/ai_default_prices.yaml)

That file lists USD prices per million tokens for Anthropic, OpenAI, and Google models (and optional cache read/write rates where the provider publishes them). The operator and Helm chart do **not** mount an extra volume in this default case.

Enable metrics (required) and leave pricing unset:

```yaml
ai:
  enabled: true
  metrics: true
  consumption:
    prices_config_map: ""   # default: built-in catalog
```

### How cost is calculated

Kiali matches each usage record to a catalog row by `provider` and `model_id`, then estimates:

```text
input cost  = (prompt tokens / 1,000,000)     × input_cost_per_million
output cost = (completion tokens / 1,000,000) × output_cost_per_million
total       = input cost + output cost
```

If no catalog row matches the provider and model, tokens are still shown and cost is omitted.

### Custom prices (`prices_config_map`)

To replace the built-in catalog (for example with your contract rates, a model not listed yet, or LightSpeed prices), create a ConfigMap in the **Kiali deployment namespace** and set `ai.consumption.prices_config_map` to its name.

The ConfigMap is **user-managed**. The operator never creates or writes it. The catalog in the ConfigMap **replaces** the built-in list; it is not merged.

1. Create a ConfigMap whose data key is `prices.yaml`, using the same schema as [ai_default_prices.yaml](https://github.com/kiali/kiali/blob/master/config/ai_default_prices.yaml):

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: kiali-ai-prices
  namespace: istio-system   # Kiali's namespace
data:
  prices.yaml: |
    models:
      - provider: openai          # openai | anthropic | google | lightspeed
        model_id: gpt-4o          # must match the model ID recorded in usage
        currency: USD
        prices:
          input_cost_per_million: 2.50
          output_cost_per_million: 10.00
          cache_write_cost_per_million: 0      # optional
          cache_read_cost_per_million: 1.25    # optional
```

2. Point Kiali at that ConfigMap.

Operator (Kiali CR):

```yaml
spec:
  ai:
    enabled: true
    metrics: true
    consumption:
      prices_config_map: kiali-ai-prices
```

Helm (`kiali-server` values):

```yaml
ai:
  enabled: true
  metrics: true
  consumption:
    prices_config_map: kiali-ai-prices
```

When `prices_config_map` is a non-empty name, the operator (and the `kiali-server` Helm chart) mounts that ConfigMap at `/kiali-ai-pricing` (`optional: true`, `readOnly: true`). Kiali reads `/kiali-ai-pricing/prices.yaml`.

If the file is missing or invalid, Kiali logs an error and **falls back** to the built-in [ai_default_prices.yaml](https://github.com/kiali/kiali/blob/master/config/ai_default_prices.yaml) catalog.

Restart the Kiali pod after you change ConfigMap contents. Prices are loaded when configuration is read, not watched for live updates.

### Catalog schema

Each entry under `models:`:

| Field | Description |
|-------|-------------|
| `provider` | Provider type: `openai`, `anthropic`, `google`, or `lightspeed`. |
| `model_id` | Provider model ID. Must match the model recorded in ChatAI usage. |
| `currency` | Pricing currency (typically `USD`). |
| `prices.input_cost_per_million` | Cost per million prompt tokens. |
| `prices.output_cost_per_million` | Cost per million completion tokens. |
| `prices.cache_write_cost_per_million` | Optional. Prompt-cache write rate, when the provider publishes one. |
| `prices.cache_read_cost_per_million` | Optional. Cached-input rate, when the provider publishes one. |

Copy rows from the [built-in catalog](https://github.com/kiali/kiali/blob/master/config/ai_default_prices.yaml) and adjust the amounts you want Kiali to use.

### Dashboard access

`ai.consumption.allowed_users_dashboard` lists usernames that may open the consumption dashboard. If the list is empty (the default), all authenticated users have access. This is independent of `ai.chat.allowed_users`, which controls who can use the [Chatbot]({{< relref "kiali-chatbot" >}}).

```yaml
ai:
  enabled: true
  metrics: true
  consumption:
    allowed_users_dashboard:
      - "alice"
      - "bob"
```

### Next step

To limit cost or tokens per user, see [Budgets]({{< relref "kiali-chatbot-budgets" >}}).
