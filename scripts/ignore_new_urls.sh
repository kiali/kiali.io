#!/bin/bash

# Used by html-proofer to ignore new/copied/renamed files
# https://github.com/gjtorikian/html-proofer#ignoring-new-files

main() {
  BRANCH="origin/staging"

  git fetch origin staging
  SUB='content/en/docs'
  EXCLUDE_URLS=""

  while IFS= read -r line; do
  if [[ "$line" =~ .*"$SUB".* ]]; then
    SUBSTR=$(echo $line | sed 's,content/en/docs/,,g')
    PATTERN=$(echo "${SUBSTR%.*}")
    URL=$(echo ",/.*${SUBSTR%.*}.*/" | awk '{print tolower($0)}' | sed 's, ,-,g')
    EXCLUDE_URLS="$EXCLUDE_URLS$URL"
  fi;
  done <<< "$(git diff --name-only --diff-filter=ACR $BRANCH)"

  # Skip validation from (Probably) not released version (last one)
  # Get current version from release notes
  while IFS= read -r version; do
     URL_VERSION=",/^https://v${version}.kiali.io/"
     EXCLUDE_URLS="$EXCLUDE_URLS$URL_VERSION"
  done <<< $(egrep -m2 '\#\#' content/en/news/release-notes.md | sed 's/\#\# //' | sed 's/.0//' | sed 's/\./-/')

  echo $EXCLUDE_URLS
}

main