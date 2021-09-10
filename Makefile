# Points to the next version that is going to be released,
# it is changed automatically by the release scripts
VERSION ?= v1.41.0

HUGO_VERSION ?= 0.53
CONTAINER_RUNTIME ?= docker

# This is not supposed to be run locally, prefer using `serve` instead.
build:
	gem install asciidoctor -v 1.5.6.1
	rm -rf public
	sh scripts/build-swagger.sh
	hugo

.PHONY: build-hugo
build-hugo:
	${CONTAINER_RUNTIME} build --build-arg HUGO_VERSION=${HUGO_VERSION} -t kiali/hugo:${HUGO_VERSION} .

.PHONY: serve
serve: build-hugo
	@mkdir -p ./resources/_gen/images && mkdir -p ./resources/_gen/assets
	@${CONTAINER_RUNTIME} run -t -i --sig-proxy=true --rm -v "$(shell pwd)":/site:z -w /site -p 1313:1313 kiali/hugo:${HUGO_VERSION} /hugo serve --baseURL "http://localhost:1313/" --bind 0.0.0.0 --disableFastRender
	@rm -rf ./resources

# This will ignore old versioned documentation for serving, to speed up the generation process
serve-latest: build-hugo
	@mkdir -p ./resources/_gen/images && mkdir -p ./resources/_gen/assets && mkdir -p ./.ignore
	# move away all "v*" directories, that is, all versions except "staging".
	@mv  ./content/documentation/v* ./.ignore
	# move back just the version that stands for latest
	@mv  "./.ignore/$(shell basename $(shell readlink -f content/documentation/latest))" ./content/documentation
	-@${CONTAINER_RUNTIME} run -t -i --sig-proxy=true --rm -v "$(shell pwd)":/site:z -w /site -p 1313:1313 kiali/hugo:${HUGO_VERSION} /hugo serve --baseURL "http://localhost:1313/" --bind 0.0.0.0 --disableFastRender
	@mv  ./.ignore/v* ./content/documentation
	@rm -rf ./resources
