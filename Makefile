
install: checkDep
	@echo Installing AsciiDoctor
	@gem install bundler
	@bundle install

checkDep:
	@echo Checking Dependencies
	@command -v hugo > /dev/null && hugo version || (echo "Error hugo is not detected. Hugo needs to be installed and the 'hugo' binary available on the path"; exit 1)
	@command -v gem > /dev/null && printf "Gem " && gem -v || (echo "Error gem is not detected. The Ruby 'gem' command needs to be on the path"; exit 1)

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


