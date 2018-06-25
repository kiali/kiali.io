build:
	rm -rf public
	sh scripts/build-swagger.sh
	hugo

deploy: build
	aws s3 sync public/ s3://kiali.io --acl public-read --delete
	aws configure set preview.cloudfront true
	aws cloudfront create-invalidation --distribution-id E3RFW0PBPFCVRO --paths '/*'
