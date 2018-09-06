
HUGO_VERSION ?= 0.48

install:
	@echo Installing Hugo version ${HUGO_VERSION}
	@mkdir -p ${GOPATH}/src/github.com/gohugoio/
	@wget -qO- https://github.com/gohugoio/hugo/archive/v${HUGO_VERSION}.tar.gz | tar xvz -C ${GOPATH}/src/github.com/gohugoio/
	@mv ${GOPATH}/src/github.com/gohugoio/hugo-${HUGO_VERSION} ${GOPATH}/src/github.com/gohugoio/hugo; cd ${GOPATH}/src/github.com/gohugoio/hugo; go build -o ${GOPATH}/bin/hugo
	@export PATH=${PATH}:${GOPATH}/bin
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


