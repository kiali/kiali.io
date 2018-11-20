
HUGO_VERSION ?= 0.48
# The port and ip that the Hugo server will bind to
BOUND_IP ?= 127.0.0.1
PORT ?= 1313

install:
	@echo Installing AsciiDoctor
	@gem install bundler
	@bundle install

serve:
	@echo Starting the Hugo Docker image
	@docker run --rm --name kialiio -v `pwd`:/src -p ${BOUND_IP}:${PORT}:1313 cibuilds/hugo:${HUGO_VERSION} hugo serve -v -s src/ --bind 0.0.0.0

build:
	rm -rf public
	sh scripts/build-swagger.sh
	hugo

deploy: build
	aws s3 sync public/ s3://kiali.io --acl public-read --delete
	aws configure set preview.cloudfront true
	aws cloudfront create-invalidation --distribution-id E3RFW0PBPFCVRO --paths '/*'
