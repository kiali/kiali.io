
# Kiali.io

[![title="Netlify Status"](https://api.netlify.com/api/v1/badges/05b3eed1-6ea2-41a1-8b64-c76bda241be6/deploy-status)](https://app.netlify.com/sites/kiali/deploys)

This repository contains the source code for the [http://kiali.io](http://kiali.io) website.

The website is written using markdown, the [Docsy](https://www.docsy.dev/) theme, and generated using [Hugo](https://gohugo.io). It is hosted on Github and deployed using netlify.


## Requirements

To run the website locally, you will need:

* [Podman](https://podman.io) or [Docker](https://docker.io)
* [GNU Make](https://www.gnu.org/software/make/)

Generally `podman` is easier to setup.


## Configuring and Running

Hugo has a command to run a small, self-contained web server locally, so you can test the website without having to upload/deploy it anywhere. The server supports live-reload, so changes to the content will reflect into the browser as they happen.

To run the server, you need to run the following on a terminal:

```
make serve
```

> :warning: 
> If you are using Docker, you need to set `DORP` when starting the server; e.g:
> ```
> make -e DORP=docker make serve
> ```

If everything is working as expected, you should see something like this:

```
                   |  EN
+------------------+------+
  Pages            | 1353
  Paginator pages  |    0
  Non-page files   |    0
  Static files     |  119
  Processed images |    0
  Aliases          |  155
  Sitemaps         |    1
  Cleaned          |    0

Total in 15304 ms
Watching for changes in /site/{content,data,layouts,static,themes}
Watching for config changes in /site/config.toml
Environment: "development"
Serving pages from memory
Web Server is available at http://localhost:1313/ (bind address 0.0.0.0)
Press Ctrl+C to stop
```

The server should be available on [http://localhost:1313](http://localhost:1313). Some files might not be supported for live reload. If, for some reason, you are not seeing your changes appearing you may need to restart the server.

## Upgrading Hugo version

The current version of Hugo used to build the site is defined in [netlify.toml](./netlify.toml) and in the [Makefile](./Makefile). Make sure the versions defined in both places are the same or, at minimum, compatible.

When upgrading to a new version of Hugo, change the versions in both files mentioned above and then rebuild your dev container image by passing in `-e FORCE_BUILD=true` when running make (e.g. `make -e FORCE_BUILD=true serve`).

## Documentation Versioning

The documentation is versioned using a branch strategy.  The `master` branch holds all new content.  On each Kiali release `master` will be captured in a versioned branch.  This typically happens every three weeks.

## Production Deployment

Deployment is done automatically when a pull request is merged, and preview deployments are also done for each PR, so you can verify that your changes will work in production before actually deploying.

## Directory Structure

The directory structure is typical for projects using the [Docsy](https://www.docsy.dev/) theme.  A couple of notes:

* The site only supports English and as such, all content is under `content/en`.
* The site minimizes customization but custom CSS is found in `assets/scss`.
* The site keeps consolidates static content under `static`.
  * e.g. images are under `static\images`


## License and Code of Conduct

The kiali.io website, like the other kiali-related projects are licensed under the [Apache License 2.0](https://www.apache.org/licenses/LICENSE-2.0). It also follows the [Kiali Community Code of Conduct](https://github.com/kiali/kiali/blob/master/CODE_OF_CONDUCT.md).
