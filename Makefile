SHELL := /bin/bash

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

## Deletes the directories that are auto-generated
.PHONY: clean
clean:
	rm -rf ./node_modules ./public ./resources

## build-hugo: Builds the hugo image if necessary. You can force a rebuild by setting the environment variable "FORCE_BUILD=true".
.PHONY: build-hugo
build-hugo: .prepare-force-build
	@if [ "${FORCE_BUILD}" == "true" ]; then ${DORP} build --build-arg HUGO_VERSION=${HUGO_VERSION} -t ${KIALI_HUGO_IMAGE} . ; else echo "Will not rebuild the image [${KIALI_HUGO_IMAGE}]."; fi

## serve: If necessary, builds the image and then runs a hugo server on your local machine at localhost:1313
.PHONY: serve
serve: build-hugo
	@${DORP} run -t -i --sig-proxy=true --rm -v "$(shell pwd)":/site:z -w /site -p 1313:1313 ${KIALI_HUGO_IMAGE} hugo serve --baseURL "http://localhost:1313/" --bind 0.0.0.0 --disableFastRender

# Ignore hash anchors (#) that go nowhere.
# Ignore some links to Kiali repositories. These are ignored because there are lots of links
# to Kiali repositories and, because of that, the checker reaches the max GitHub request limit and
# we get throttled which results in errors because of 429 HTTP error codes.
# So, we ignore some URLs that are probably safe to ignore:
# 1. URLs to specific pulls; i.e. of the form https://github.com/kiali/kiali/pull/1234
# 2. URLs to specific issues; i.e. of the form https://github.com/kiali/kiali/issues/1234
# 3. URLs to a folder in repository in a branch; i.e. of the form https://github.com/kiali/kiali/tree/v1.24/whatever
#   - We only ignore links to branches, because it's so-so stable. Master branch
#     is unsafe because files are moved, renamed, etc.
# 4. URLs to a folder in repository in a branch; i.e. of the form https://github.com/kiali/kiali/blob/v1.24/whatever
#   - Same reasoning as previous point.
# 5. URLs to kiali.io and kiali to edit doc files or create new doc files or create new issues
# 6. URLs to kiali.io commits
URL_IGNORE=\#$\
          ,/^https:\/\/github.com\/kiali\/kiali\/pull\/\d+/$\
          ,/^https:\/\/github.com\/kiali\/kiali\/issues\/\d+/$\
          ,/^https:\/\/github.com\/kiali\/kiali\/issues\/new/$\
          ,/^https:\/\/github.com\/kiali\/kiali\/tree\/v\d+\.\d+(\.\d+)?\//$\
          ,/^https:\/\/github.com\/kiali\/kiali\/blob\/v\d+\.\d+(\.\d+)?\//$\
          ,/^https:\/\/github.com\/kiali\/kiali\.io\/edit\//$\
          ,/^https:\/\/github.com\/kiali\/kiali\.io\/new\//$\
          ,/^https:\/\/github.com\/kiali\/kiali\.io\/commit\//$\
          ,/^https:\/\/github.com\/kiali\/kiali\.io\/issues\/new/$\
          ,/.*web.libera.chat.*/
## validate-site: Builds the site and validates the pages. This is used for CI
.PHONY: validate-site
validate-site: build-hugo
	${DORP} run -t -i --rm -v "$(shell pwd)":/site:z -w /site ${KIALI_HUGO_IMAGE} /bin/bash -c "npm prune && hugo && htmlproofer --assume-extension --check-external-hash --empty_alt_ignore --url-ignore \"${URL_IGNORE}\" ./public"

