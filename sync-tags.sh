#!/bin/bash

# This script does the migration process necessary for documentation
# versioning. It is to be removed after that initiative is done.

# Be careful running it as it creates tags on the current repo you're on.
# Run with "-f" to disable dry run mode.

KIALI_REPO="${KIALI_REPO:-${GOPATH}/src/github.com/kiali/kiali}"
FIRST_LEGACY_VERSION="v1.0.0"
LAST_LEGACY_VERSION="v1.17.0"

die() {
  echo "ERROR: ${1}"
}

# TODO: rename
create_kiali_io_tags() {
  pushd "${KIALI_REPO}" &>/dev/null || die "pushd failed."

  # - List all versions in semver order
  # - Remove old versions that were tagged incorrectly (like "0.2.0")
  # - Remove snapshot versions
  # - Remove some named quickfix versions, (like "v0.9.1.helmfix")
  # - Remove patch versions as they are out of order
  #
  # Removing those versions from the list is safe because we are only going to
  # iterate over legacy tags. New tags are supposed to be created on version
  # release.
  versions=$(git tag -l --sort=v:refname | grep -E "v[0-9]+\\.[0-9]+\\.0$")
  start_date=$(git show -s --format="%at" ${FIRST_LEGACY_VERSION})
  end_date=$(git show -s --format="%at" ${LAST_LEGACY_VERSION})

  for version in ${versions}; do
    commit_date=$(git show -s --format="%at" "${version}")

    [ "${commit_date}" -lt "${start_date}" ] && continue
    [ "${commit_date}" -gt "${end_date}" ]  && continue

    popd &>/dev/null || die "popd failed"

    # Important: here we only fetch merge commits, so we don't point at incomplete work.
    latest_commit_on_tag=$(git rev-list -1 --merges --before="$(date +%s -d "@$(echo "${commit_date} - 1" | bc)")" --format="%at" master \
      | grep commit | sed -e "s/commit //" \
      | tail -n 1)

    echo "Creating tag for version ${version}..."

    if [ "${1}" = "-f" ]; then
      git tag "${version}" "${latest_commit_on_tag}" || echo "Version ${version} already exists"
    else
      echo "DRY_RUN: git tag ${version} ${latest_commit_on_tag}"
    fi

    pushd "${KIALI_REPO}" &>/dev/null || die "pushd failed."
  done

  popd &>/dev/null || die "popd failed."
}

create_kiali_io_tags "${1}"
