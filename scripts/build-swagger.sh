#!/usr/bin/env bash
# Build Swagger API
java -jar ./scripts/swagger2markup-cli-1.3.3.jar convert  -i https://raw.githubusercontent.com/kiali/kiali/master/swagger.json  -d ./output/content/api -c ./scripts/config.properties

# Delete first link (useless and breaks Hugo since it is an HTML anchor and not proper Markdown)
for f in output/content/api/*; do
    echo "Processing $f"
    sed '/## /,$!d' $f > content/api/`basename $f`
done

# Remove MD files, it seems there is a bug in swagger2markup-cli-1.3.3
rm -rf content/api/*.md