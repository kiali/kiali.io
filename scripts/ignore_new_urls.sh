#!/bin/bash

# Extra html-proofer URL ignores for validate-site (not kiali.io/docs — those are checked
# via --swap-urls against the local Hugo build). Skips unreleased version doc hosts.

main() {
  EXCLUDE_URLS=""

  # Skip validation against (probably) not-yet-released version sites (last two minors).
  while IFS= read -r version; do
     URL_VERSION=",/^https://v${version}.kiali.io/"
     EXCLUDE_URLS="$EXCLUDE_URLS$URL_VERSION"
  done <<< $(grep -E -m2 '^##' content/en/news/release-notes.md | sed 's/## //' | sed 's/.0//' | sed 's/\./-/')

  echo $EXCLUDE_URLS
}

main
