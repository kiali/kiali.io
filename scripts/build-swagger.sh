#!/usr/bin/env bash
# Build Swagger API

curl https://raw.githubusercontent.com/kiali/kiali/master/swagger.json > swagger.json
npx redoc-cli bundle -t scripts/template.hbs swagger.json
rm swagger.json
mv redoc-static.html content/documentation/edge/developer-api/index.html
