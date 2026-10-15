#!/usr/bin/env python3
"""Refresh the Kiali MCP tool catalog embedded in the kiali.io MCP page.

The catalog is generated from the Kubernetes MCP Server tool schema so the
published names, descriptions, and parameters stay aligned with upstream.
"""

import argparse
import json
import sys
import urllib.request
from pathlib import Path

TOOLS_URL = (
    "https://raw.githubusercontent.com/containers/kubernetes-mcp-server/"
    "refs/heads/main/pkg/mcp/testdata/toolsets-kiali-tools.json"
)
PAGE = Path("content/en/docs/AI/kiali-mcp.md")
START = "<!-- KIALI-MCP-TOOLS:START -->"
END = "<!-- KIALI-MCP-TOOLS:END -->"


def fetch_tools(source):
    if source.startswith("http://") or source.startswith("https://"):
        with urllib.request.urlopen(source, timeout=30) as response:
            payload = response.read().decode("utf-8")
    else:
        payload = Path(source).read_text(encoding="utf-8")
    tools = json.loads(payload)
    if not isinstance(tools, list) or not tools:
        raise SystemExit(f"expected a non-empty tool list from {source}")
    return sorted(tools, key=lambda tool: tool.get("name", ""))


def cell(value):
    text = " ".join(str(value).split())
    return text.replace("|", "\\|")


def format_default(value):
    if value is None:
        return ""
    if isinstance(value, bool):
        return "`true`" if value else "`false`"
    return f"`{value}`"


def format_type(prop):
    kind = prop.get("type", "any")
    enum = prop.get("enum")
    if enum:
        values = ", ".join(f"`{item}`" for item in enum)
        return f"{kind} ({values})"
    return kind


def access_label(tool):
    annotations = tool.get("annotations") or {}
    if annotations.get("readOnlyHint"):
        return "Read-only"
    if annotations.get("destructiveHint"):
        return "Writes config"
    return "Can modify resources"


def render_parameters(tool):
    schema = tool.get("inputSchema") or {}
    properties = schema.get("properties") or {}
    if not properties:
        return "This tool takes no parameters.\n"
    required = set(schema.get("required") or [])
    names = sorted(properties, key=lambda name: (name not in required, name))
    lines = [
        "| Parameter | Type | Required | Default | Description |",
        "| --- | --- | --- | --- | --- |",
    ]
    for name in names:
        prop = properties[name]
        description = prop.get("description", "")
        if "minimum" in prop and "minimum" not in description.lower():
            description = f"{description} Minimum: {prop['minimum']}.".strip()
        lines.append(
            "| `{name}` | {kind} | {req} | {default} | {desc} |".format(
                name=name,
                kind=cell(format_type(prop)),
                req="yes" if name in required else "no",
                default=format_default(prop.get("default")),
                desc=cell(description),
            )
        )
    return "\n".join(lines) + "\n"


def render_catalog(tools):
    parts = [
        f"Generated from the [Kubernetes MCP Server Kiali tool schema]({TOOLS_URL}). Refresh this list with `make gen-kiali-mcp-doc`.",
        "",
        "| Tool | Access | Purpose |",
        "| --- | --- | --- |",
    ]
    for tool in tools:
        name = tool["name"]
        title = cell(tool.get("title") or name)
        parts.append(f"| [`{name}`](#{name}) | {access_label(tool)} | {title} |")
    parts.append("")
    for tool in tools:
        name = tool["name"]
        title = tool.get("title") or name
        description = " ".join((tool.get("description") or "").split())
        parts.extend(
            [
                f"#### `{name}`",
                "",
                f"**{title}.** {access_label(tool)}.",
                "",
                description,
                "",
                render_parameters(tool),
            ]
        )
    return "\n".join(parts).rstrip() + "\n"


def splice(page_text, catalog):
    start = page_text.find(START)
    end = page_text.find(END)
    if start < 0 or end < 0 or end < start:
        raise SystemExit(f"{PAGE} is missing {START} / {END} markers")
    end += len(END)
    replacement = f"{START}\n{catalog}{END}"
    return page_text[:start] + replacement + page_text[end:]


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", default=TOOLS_URL, help="JSON URL or local file")
    parser.add_argument("--page", type=Path, default=PAGE)
    args = parser.parse_args()

    tools = fetch_tools(args.source)
    updated = splice(args.page.read_text(encoding="utf-8"), render_catalog(tools))
    args.page.write_text(updated, encoding="utf-8")
    print(f"Wrote {len(tools)} tools into {args.page}")


if __name__ == "__main__":
    sys.exit(main())
