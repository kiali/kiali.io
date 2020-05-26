#!/bin/bash

set -xe

[[ -z $(git status -s) ]] || (echo "The working tree is dirty. Please make sure it is clean before running."; exit 1)

GIT="git -c advice.detachedHead=false"

current_branch=$(git rev-parse --abbrev-ref HEAD)
trap '{ ${GIT} checkout ${current_branch}; }' EXIT

echo "Making sure we have all the latest tags..."
git fetch --all --tags

temp="$(mktemp -d)"

generate() {
  tag="${1%.0}"
  root="$(pwd)/content/documentation"

  echo "Preparing documentation for version ${tag}"

  ${GIT} checkout "${1}"
  mkdir "${temp}/${tag}"

  cp -r "${root}"/edge/* "${temp}/${tag}/"

  find "${temp}/${tag}" -type f -name "*.adoc" -exec sed -i -e "s/  main:/  $(echo "${tag}" | tr "." "-"):/" "{}" \;
  sed -i "s/: (Edge|Documentation)/: ${tag}/g" "${temp}/${tag}/_index.adoc"

  ${GIT} checkout "${current_branch}"

  mkdir "${root}/${tag}"
  cp -r "${temp}/${tag}/*" "${root}/"
}

echo "Running for version ${1}..."

if git tag --list | grep "${1}" &>/dev/null; then
  generate "${1}"
else
  echo "Tag ${1} could not be found"
  exit 1
fi
