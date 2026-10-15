---
title: "Budgets"
description: >
  Limit ChatAI cost and tokens per user with weekly or monthly budgets.
weight: 13
---

You can cap ChatAI usage per user with `ai.consumption.budgets`. Each budget sets a reset interval, optional cost and token limits, and optional provider/model allowlists. Cost limits use the same catalog described in [Token prices]({{< relref "kiali-chatbot-prices" >}}).

**To use consumption tracking, token prices, and budgets, `ai.metrics` must be enabled (`ai.metrics: true`).** If metrics are disabled, budgets are not enforced and remaining-budget data is not shown.

If `budgets` is empty (the default), there are no budget restrictions.

For the field list, see `ai.consumption` in the [Kiali CR spec](/docs/configuration/kialis.kiali.io/#.spec.ai).

### Budget fields

Each item under `ai.consumption.budgets` is applied to one or more users:

| Field | Description |
|-------|-------------|
| `usernames` | Users this budget applies to. Required and must not be empty. Use `*` as a catch-all for everyone else. |
| `interval` | When the budget resets: `weekly` or `monthly`. |
| `max_cost` | Maximum estimated cost in the interval, in the catalog currency (typically USD). |
| `max_tokens` | Maximum tokens in the interval, in **millions** of tokens (for example `10` means 10 million tokens). |
| `allowed_providers` | Provider types this budget allows: `openai`, `anthropic`, `google`, `lightspeed`. Empty means all configured providers. |
| `allowed_models` | Model names or IDs this budget allows. Supports `*` wildcards (for example `claude-sonnet-*`). Empty means all models of the allowed providers. |

`allowed_providers` and `allowed_models` must refer to providers and models already defined in `ai.chat.providers`.

### How a budget is chosen

On each chat request, Kiali picks **one** budget for the current user:

1. An exact username match (the `anonymous-shared` user is treated as `anonymous`).
2. Otherwise a `*` catch-all budget, if one exists.
3. Otherwise no budget (the request is not limited).

An exact match always wins over `*`. Put specific users in their own entries, then optionally add a `*` entry for everyone else.

### What is enforced

When metrics are enabled and a budget applies, Kiali:

1. Rejects the request if the selected provider type is not in `allowed_providers`.
2. Rejects the request if the selected model is not in `allowed_models`.
3. Rejects the request if used cost in the current interval is at or above `max_cost`, or used tokens are at or above `max_tokens` million tokens.

The chatbot and consumption dashboard can show remaining cost and tokens for the current user.

### Example

```yaml
ai:
  enabled: true
  metrics: true                 # required for usage, cost, and budgets
  consumption:
    budgets:
      - usernames: ["alice", "bob"]
        interval: monthly
        max_cost: 50
        max_tokens: 10          # 10 million tokens
        allowed_providers: ["openai", "anthropic"]
        allowed_models: ["gpt-4o", "claude-sonnet-*"]
      - usernames: ["*"]
        interval: weekly
        max_cost: 5
```

In this example:

- Alice and Bob share a monthly budget of 50 (USD, unless you changed the catalog currency) and 10 million tokens, and may only use the listed OpenAI and Anthropic models.
- Every other user shares a weekly budget of 5 in cost, with no token cap and no provider/model restriction.

Operator (Kiali CR) uses the same keys under `spec.ai`. Helm (`kiali-server`) uses them under `ai.consumption.budgets`.
