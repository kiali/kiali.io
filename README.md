# Kiali.io

[![title="Netlify Status"](https://api.netlify.com/api/v1/badges/05b3eed1-6ea2-41a1-8b64-c76bda241be6/deploy-status)](https://app.netlify.com/sites/kiali/deploys)

This repository contains the source code for the [http://kiali.io](http://kiali.io) website.

The website is written using markdown, the [Docsy](https://www.docsy.dev/) theme, and generated using [Hugo](https://gohugo.io). It is hosted on Github and deployed using netlify.

## Table of Contents

- [Requirements](#requirements)
- [Configuring and Running](#configuring-and-running)
- [Upgrading Hugo Version](#upgrading-hugo-version)
- [Documentation Versioning](#documentation-versioning)
- [Production Deployment](#production-deployment)
- [Directory Structure](#directory-structure)
- [License and Code of Conduct](#license-and-code-of-conduct)

## Requirements

To run the website locally, you will need:

- [Podman](https://podman.io) or [Docker](https://docker.io)
- [GNU Make](https://www.gnu.org/software/make/)

Generally `podman` is easier to setup. The dev container image includes Go (for Hugo Modules), Node/npm, and htmlproofer; Hugo **extended** and Dart Sass (`sass-embedded`) come from npm (`package.json`), same as [Docsy’s recommended setup](https://www.docsy.dev/docs/get-started/docsy-as-module/installation-prerequisites/). Docsy is pulled as a Hugo module (`go.mod`); theme npm assets are merged into `packages/hugoautogen/` via `hugo mod npm pack`.

On the host (without the container), install dependencies with `npm run install:safe`, then run `npm run approve:hugo` once to allow the `hugo-extended` install script.

## Configuring and Running

Hugo has a command to run a small, self-contained web server locally, so you can test the website without having to upload/deploy it anywhere. The server supports live-reload, so changes to the content will reflect into the browser as they happen.

To run the server, you need to run the following on a terminal:

```
make serve
```

> :warning:
> If you are using Docker, you need to set `DORP` when starting the server; e.g:
>
> ```
> make -e DORP=docker serve
> ```
>
> On ARM-based Macs, you'll need to run following command first:
>
> ```
> export DOCKER_DEFAULT_PLATFORM=linux/amd64
> ```

If everything is working as expected, you should see something like this (if not see [Upgrading Hugo Version](#upgrading-hugo-version)):

```
                   | EN
-------------------+------
  Pages            | 151
  Paginator pages  |   0
  Non-page files   |   1
  Static files     | 323
  Processed images |   2
  Aliases          |   4
  Sitemaps         |   1
  Cleaned          |   0

Built in 1313 ms
Environment: "development"
Serving pages from memory
Web Server is available at http://localhost:1313/ (bind address 0.0.0.0)
Press Ctrl+C to stop
```

The server should be available on [http://localhost:1313](http://localhost:1313). Some files might not be supported for live reload. If, for some reason, you are not seeing your changes appearing you may need to restart the server.

## Upgrading Hugo version

The Hugo **extended** version is pinned in [package.json](./package.json) (`devDependencies.hugo-extended`). Update that version and `allowScripts` if needed, run `npm run approve:hugo`, then `npm run update:docsy:pack` and commit `package-lock.json`. Netlify does not use a `HUGO_VERSION` environment variable; it uses the npm package.

## Documentation Versioning

The documentation is versioned using a branch strategy. The `staging` branch holds all new content. On each Kiali release `staging` will be captured in the `current` branch and the former `current` branch will be captured in a versioned branch. This typically happens every three weeks. Changes to
`staging` will be applied to all future releases. Backport or update the `current`, or any other versioned branch, as needed.

## Production Deployment

Deployment is done automatically when a pull request is merged, and preview deployments are also done for each PR, so you can verify that your changes will work in production before actually deploying.

## Directory Structure

The directory structure is typical for projects using the [Docsy](https://www.docsy.dev/) theme. A couple of notes:

- Docsy is not vendored under `themes/`; it is declared in `go.mod` and fetched by Hugo.
- The site only supports English and as such, all content is under `content/en`.
- The site minimizes customization but custom CSS is found in `assets/scss`.
- The site keeps consolidates static content under `static`.
  - e.g. images are under `static\images`

## License and Code of Conduct

The kiali.io website, like the other kiali-related projects are licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0). It also follows the [Kiali Community Code of Conduct](https://github.com/kiali/kiali/blob/master/CODE_OF_CONDUCT.md).
