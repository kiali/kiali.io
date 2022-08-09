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

  echo $EXCLUDE_URLS
}

main