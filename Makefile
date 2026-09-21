SHELL := /bin/bash

# Make sure this Hugo version is compatible with the one defined in netlify.toml
HUGO_VERSION ?= 0.121.1
DORP ?= podman
KIALI_HUGO_IMAGE ?= kiali/hugo:latest
DOCSY_BUILD=cd themes/docsy && npm install && cd ../..

.prepare-force-build:
ifeq ($(DORP),docker)
	@$(eval FORCE_BUILD ?= $(shell docker inspect ${KIALI_HUGO_IMAGE} > /dev/null 2>&1 || echo "true"))
else
	@$(eval FORCE_BUILD ?= $(shell podman inspect ${KIALI_HUGO_IMAGE} > /dev/null 2>&1 || echo "true"))
endif

.PHONY: .gen-crd-doc-kiali
.gen-crd-doc-kiali:
	mkdir -p ./tmp-crd-docs
	curl -L https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/config/kiali/apigen-config.yaml -o ./tmp-crd-docs/apigen-config.yaml
	curl -L https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/config/kiali/apigen-crd.template -o ./tmp-crd-docs/apigen-crd.template
	${DORP} run -v ./content/en/docs/Configuration:/opt/crd-docs-generator/output:z -v ./tmp-crd-docs:/opt/crd-docs-generator/config:z quay.io/giantswarm/crd-docs-generator:0.9.0 --config /opt/crd-docs-generator/config/apigen-config.yaml
	rm -rf ./tmp-crd-docs

.PHONY: .gen-crd-doc-ossmconsole
.gen-crd-doc-ossmconsole:
	mkdir -p ./tmp-crd-docs
	curl -L https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/config/ossmconsole/apigen-config.yaml -o ./tmp-crd-docs/apigen-config.yaml
	curl -L https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/config/ossmconsole/apigen-crd.template -o ./tmp-crd-docs/apigen-crd.template
	${DORP} run -v ./content/en/docs/Configuration:/opt/crd-docs-generator/output:z -v ./tmp-crd-docs:/opt/crd-docs-generator/config:z quay.io/giantswarm/crd-docs-generator:0.9.0 --config /opt/crd-docs-generator/config/apigen-config.yaml
	rm -rf ./tmp-crd-docs

## Generates the CRD documentation. This requires cluster-admin access to a k8s cluster.
.PHONY: gen-crd-doc
gen-crd-doc: .gen-crd-doc-kiali .gen-crd-doc-ossmconsole

## Deletes the directories that are auto-generated
.PHONY: clean
clean:
	rm -rf ./node_modules ./public ./resources ./tmp-crd-docs

## build-hugo: Builds the hugo image if necessary. You can force a rebuild by setting the environment variable "FORCE_BUILD=true".
.PHONY: build-hugo
build-hugo: .prepare-force-build
	@if [ "${FORCE_BUILD}" == "true" ]; then ${DORP} build --build-arg HUGO_VERSION=${HUGO_VERSION} -t ${KIALI_HUGO_IMAGE} . ; else echo "Will not rebuild the image [${KIALI_HUGO_IMAGE}]."; fi

## serve: If necessary, builds the image and then runs a hugo server on your local machine at localhost:1313
.PHONY: serve
serve: build-hugo
	@${DORP} run -t -i --sig-proxy=true --rm -v "$(shell pwd)":/site:z -w /site -p 1313:1313 ${KIALI_HUGO_IMAGE} /bin/bash -c "${DOCSY_BUILD} && hugo serve --baseURL "http://localhost:1313/" --bind 0.0.0.0 --disableFastRender"

.PHONY: generate_metrics_json
generate_metrics_json:
	python scripts/api_gh/pull_api_data.py

## validate-site: Builds the site and validates the pages. This is used for CI
.PHONY: validate-site
validate-site: build-hugo
	${DORP} run -t -i --rm -v "$(shell pwd)":/site:z -w /site ${KIALI_HUGO_IMAGE} /site/scripts/validate-site.sh
