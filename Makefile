# Make sure this Hugo version is compatible with the one defined in netlify.toml
HUGO_VERSION ?= 0.75.0
DORP ?= podman
KIALI_HUGO_IMAGE ?= kiali/hugo:latest

.prepare-force-build:
ifeq ($(DORP),docker)
	@$(eval FORCE_BUILD ?= $(shell docker inspect ${KIALI_HUGO_IMAGE} > /dev/null 2>&1 || echo "true"))
else
	@$(eval FORCE_BUILD ?= $(shell podman inspect ${KIALI_HUGO_IMAGE} > /dev/null 2>&1 || echo "true"))
endif

## build-hugo: Builds the hugo image if necessary. You can force a rebuild by setting the environment variable "FORCE_BUILD=true".
.PHONY: build-hugo
build-hugo: .prepare-force-build
	@if [ "${FORCE_BUILD}" == "true" ]; then ${DORP} build --build-arg HUGO_VERSION=${HUGO_VERSION} -t ${KIALI_HUGO_IMAGE} . ; else echo "Will not rebuild the image [${KIALI_HUGO_IMAGE}]."; fi

## serve: If necessary, builds the image and then runs a hugo server on your local machine at localhost:1313
.PHONY: serve
serve: build-hugo
	@${DORP} run -t -i --sig-proxy=true --rm -v "$(shell pwd)":/site:z -w /site -p 1313:1313 ${KIALI_HUGO_IMAGE} hugo serve --baseURL "http://localhost:1313/" --bind 0.0.0.0 --disableFastRender
