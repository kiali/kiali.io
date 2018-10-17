
HUGO_VERSION ?= 0.48

install:
	@echo Installing Hugo version ${HUGO_VERSION}
	@HUGO_VERSION=${HUGO_VERSION} sh scripts/get-hugo.sh
	@export PATH="${PATH}:${GOPATH}/bin"
	@echo Installing AsciiDoctor
	@gem install bundler
	@bundle install

serve:
	@hugo serve

build:
	rm -rf public
	sh scripts/build-swagger.sh
	hugo

deploy: build
	aws s3 sync public/ s3://kiali.io --acl public-read --delete
	aws configure set preview.cloudfront true
	aws cloudfront create-invalidation --distribution-id E3RFW0PBPFCVRO --paths '/*'
