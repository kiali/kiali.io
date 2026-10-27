SHELL := /bin/bash

CRD_DOCS_GENERATOR_IMAGE ?= quay.io/kiali/crd-docs-generator:0.11.4
DORP ?= podman
KIALI_HUGO_IMAGE ?= kiali/hugo:latest
DOCSY_BUILD=npm run install:safe && npm run _prepare:modules

.prepare-force-build:
	@$(eval FORCE_BUILD ?= $(shell bash scripts/hugo-image-stale.sh $(DORP) ${KIALI_HUGO_IMAGE}))

.PHONY: .gen-crd-doc-kiali
.gen-crd-doc-kiali:
	mkdir -p ./tmp-crd-docs
	curl -L https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/config/kiali/apigen-config.yaml -o ./tmp-crd-docs/apigen-config.yaml
	curl -L https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/config/kiali/apigen-crd.template -o ./tmp-crd-docs/apigen-crd.template
	${DORP} run -v ./content/en/docs/Configuration:/opt/crd-docs-generator/output:z -v ./tmp-crd-docs:/opt/crd-docs-generator/config:z ${CRD_DOCS_GENERATOR_IMAGE} --config /opt/crd-docs-generator/config/apigen-config.yaml
	rm -rf ./tmp-crd-docs

.PHONY: .gen-crd-doc-ossmconsole
.gen-crd-doc-ossmconsole:
	mkdir -p ./tmp-crd-docs
	curl -L https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/config/ossmconsole/apigen-config.yaml -o ./tmp-crd-docs/apigen-config.yaml
	curl -L https://raw.githubusercontent.com/kiali/kiali-operator/master/crd-docs/config/ossmconsole/apigen-crd.template -o ./tmp-crd-docs/apigen-crd.template
	${DORP} run -v ./content/en/docs/Configuration:/opt/crd-docs-generator/output:z -v ./tmp-crd-docs:/opt/crd-docs-generator/config:z ${CRD_DOCS_GENERATOR_IMAGE} --config /opt/crd-docs-generator/config/apigen-config.yaml
	rm -rf ./tmp-crd-docs

## Generates the CRD documentation. This requires cluster-admin access to a k8s cluster.
.PHONY: gen-crd-doc
gen-crd-doc: .gen-crd-doc-kiali .gen-crd-doc-ossmconsole

## Regenerates the Kiali MCP tool catalog in content/en/docs/AI/kiali-mcp.md
## from the Kubernetes MCP Server tool schema.
.PHONY: gen-kiali-mcp-doc
gen-kiali-mcp-doc:
	python3 scripts/gen-kiali-mcp-tools.py

## Deletes the directories that are auto-generated
.PHONY: clean
clean:
	rm -rf ./node_modules ./public ./resources ./tmp-crd-docs ./themes

## build-hugo: Builds the hugo image if necessary. You can force a rebuild by setting the environment variable "FORCE_BUILD=true".
.PHONY: build-hugo
build-hugo: .prepare-force-build
	@if [ "${FORCE_BUILD}" == "true" ]; then ${DORP} build -t ${KIALI_HUGO_IMAGE} . ; else echo "Will not rebuild the image [${KIALI_HUGO_IMAGE}]."; fi

## serve: If necessary, builds the image and then runs a hugo server on your local machine at localhost:1313
.PHONY: serve
serve: build-hugo
	@${DORP} run -t -i --sig-proxy=true --rm -v "$(shell pwd)":/site:z -w /site -p 1313:1313 ${KIALI_HUGO_IMAGE} /bin/bash -c "${DOCSY_BUILD} && npm run serve"

.PHONY: generate_metrics_json
generate_metrics_json:
	python scripts/api_gh/pull_api_data.py

## validate-site: Builds the site and validates the pages. This is used for CI
.PHONY: validate-site
validate-site: build-hugo
	${DORP} run -t -i --rm -v "$(shell pwd)":/site:z -w /site ${KIALI_HUGO_IMAGE} /site/scripts/validate-site.sh
