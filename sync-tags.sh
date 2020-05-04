#!/bin/bash

KIALI_REPO="${KIALI_REPO:-${GOPATH}/src/github.com/kiali/kiali}"
FIRST_NON_LEGACY_VERSION="v1.17.0"

compare_dates() {
  local date1=$(date -d "${1}" +%s)
  local date2=$(date -d "${2}" +%s)

  [ ${date1} -ge ${date2} ]
}

# TODO: rename
create_kiali_io_tags() {
  pushd ${KIALI_REPO} &>/dev/null

  # In order:
  # - List all versions in semver order
  # - Remove old versions that were tagged incorrectly (like "0.2.0")
  # - Remove snapshot versions
  # - Remove some named quickfix versions, (like "v0.9.1.helmfix")
  # - Remove patch versions as they are out of order
  #
  # Removing those versions from the list is safe because we are only going to
  # iterate over legacy tags. New tags are supposed to be created on version
  # release.
  local versions=$(git tag -l --sort=v:refname \
    | egrep -v "^[^v]" \
    | grep -v -- "-snapshot" \
    | egrep -v "\\.[^0-9]+$" \
    | egrep -v "\\.[^0]$")
  local start_date=$(git show -s --format="%ci" ${version} | cut -f 1 -d" ")

  for version in ${versions}; do
    local commit_date=$(git show -s --format="%ci" ${version})

    if compare_dates ${start_date} ${commit_date}; then
      popd &>/dev/null

      local latest_commit_on_tag=$(git rev-list -1 --before=$(date +%Y-%m-%d -d "${commit_date} - 1 minute") --format="%ci" master \
        | grep commit | sed -e "s/commit //" \
        | tail -n 1)

      echo "Creating tag for version ${version}"
      git tag ${version} ${latest_commit_on_tag} || echo "Version ${version} already exists"

      pushd ${KIALI_REPO} &>/dev/null
    fi
  done

  popd &>/dev/null
}

create_kiali_io_tags
