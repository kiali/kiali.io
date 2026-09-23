# AI Agent Development Guide for kiali.io

This guide provides conventions and workflows for AI agents and contributors working on the [kiali.io](https://kiali.io) documentation site. It complements the [README](./README.md) and the published [Contribution Guidelines](https://kiali.io/docs/contribution-guidelines/how-to-contribute/).

## Table of Contents

- [Repository Overview](#repository-overview)
- [Branch Strategy](#branch-strategy)
- [Local Development](#local-development)
- [Content Layout](#content-layout)
- [Feature Page Screenshots](#feature-page-screenshots)
- [CRD Reference Documentation](#crd-reference-documentation)
- [Pull Requests](#pull-requests)

## Repository Overview

kiali.io is a [Hugo](https://gohugo.io) site using the [Docsy](https://www.docsy.dev/) theme. All English content lives under `content/en/`. Static assets (images, downloadable files) live under `static/`.

| Path | Purpose |
|------|---------|
| `content/en/docs/` | Main documentation pages |
| `content/en/news/` | Release notes and news |
| `static/images/documentation/` | Documentation screenshots and diagrams |
| `Makefile` | Local Hugo server and CRD doc generation |
| `config.toml` | Hugo site configuration |

## Branch Strategy

- **`staging`** — default branch for new documentation; merged PRs here appear on the staging site.
- **`current`** — snapshot taken on each Kiali release; receives backports when needed.
- **Version branches** (e.g. `v2.32`) — frozen docs for older Kiali releases.

Target **`staging`** for new work unless backporting to `current` or a version branch.

## Local Development

```bash
# Run Hugo locally (Podman default; use DORP=docker if needed)
make serve

# Validate the site (CI)
make validate-site

# Regenerate CRD reference pages (see below)
make gen-crd-doc
```

Preview at [http://localhost:1313](http://localhost:1313). Hugo version is pinned in `Makefile` and `netlify.toml`; keep them in sync when upgrading.

## Content Layout

- Use Hugo front matter (`title`, `description`, optional `weight`) on every page.
- Cross-link docs with `{{< relref "./other-page" >}}` or `{{< relref "/docs/Features/appearance" >}}`.
- Do not add `draft = true` to pages intended for Netlify PR previews.
- Match the tone and structure of surrounding pages in the same section.

## Feature Page Screenshots

Store screenshots for **Features** pages in a subfolder named after the markdown file (without `.md`).

### Convention

| Feature page | Image directory | Markdown image path |
|--------------|-----------------|---------------------|
| `content/en/docs/Features/appearance.md` | `static/images/documentation/features/appearance/` | `/images/documentation/features/appearance/...` |
| `content/en/docs/Features/internationalization.md` | `static/images/documentation/features/internationalization/` | `/images/documentation/features/internationalization/...` |
| `content/en/docs/Features/ambient.md` | `static/images/documentation/features/ambient/` | `/images/documentation/features/ambient/...` |

### Rules

1. **New or updated feature pages** — put all new screenshots in `static/images/documentation/features/<page-name>/`.
2. **Editing a legacy feature page** — when you touch a page that still uses flat files in `features/`, move its images into `<page-name>/` in the same PR and update markdown paths.
3. **Naming** — use descriptive kebab-case filenames (e.g. `appearance-light.png`, `preferences-user-dropdown.png`). A page prefix in the filename is optional when the folder already identifies the feature.
4. **Shared images** — if one screenshot is used by multiple pages, prefer a `static/images/documentation/features/shared/` folder (create when needed) or keep a single canonical copy in the primary page's folder and link from other pages.
5. **Other doc sections** — follow existing section layout (e.g. `static/images/documentation/ossmc/` for OSSMC docs, `static/images/documentation/contribution/` for contribution guides).

Example markdown reference:

```markdown
![Light color scheme](/images/documentation/features/appearance/appearance-light.png "Light color scheme")
```

## CRD Reference Documentation

The Kiali and OSSMConsole CRD reference pages are **generated**, not hand-edited:

- `content/en/docs/Configuration/kialis.kiali.io.md`
- `content/en/docs/Configuration/ossmconsoles.kiali.io.md`

After CRD schema changes merge in [kiali/kiali-operator](https://github.com/kiali/kiali-operator), regenerate locally:

```bash
make gen-crd-doc
```

Commit the generated diff in the same PR that depends on the operator change, or in a follow-up PR once the operator CRD is on `master`.

Requires Podman or Docker (see `DORP` in the Makefile).

## Pull Requests

1. Branch from `staging`.
2. Open a PR against `kiali/kiali.io` **`staging`**.
3. Use the Netlify deploy preview (**Details** on the PR) to verify pages and images.
4. For doc-only changes, a concise summary and a short test plan (pages to review) are enough.

Human-oriented contribution steps: [How to Contribute](content/en/docs/Contribution-guidelines/how-to-contribute.md).
