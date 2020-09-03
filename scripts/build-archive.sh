#!/bin/bash

set -xe

tag="${1%.0}"
root="$(pwd)/content/documentation"

echo "Preparing documentation for version ${tag}"

cp -r "${root}"/staging "${root}"/${tag}

find "${root}/${tag}" -type f -name "*.adoc" -exec sed -i -e "s/  main:/  $(echo "${tag}" | tr "." "-"):/" "{}" \;
find "${root}/${tag}" -type f -name "*.adoc" -exec sed -i -e "s;/staging/;/${tag}/;g" "{}" \;
sed -i -r "s/: \"(Staging|Documentation)\"/: ${tag}/g" "${root}/${tag}/_index.adoc"

rm "${root}/latest"
cd "${root}"

ln -s ${tag} latest

