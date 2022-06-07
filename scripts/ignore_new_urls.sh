#!/bin/bash

# Used by html-proffer to ignore new/copied/renamed files
# https://github.com/gjtorikian/html-proofer#ignoring-new-files

main() {
  MERGEBASE=$(git merge-base origin/staging HEAD | sed 's/ //g')
  #echo $MERGEBASE

  SUB='content/en/docs'
  EXCLUDE_URLS=""

  while IFS= read -r line; do
  if [[ "$line" =~ .*"$SUB".* ]]; then
              #printf "$line\n"
              SUBSTR=$(echo $line | sed 's,content/en/docs/,,g')
              #printf "$SUBSTR\n"
              #SUBSTR=$(echo $SUBSTR | sed 's,/,/\\,g')
              #printf "$SUBSTR\n"
              PATTERN=$(echo "${SUBSTR%.*}")
              #printf "$PATTERN\n"
              URL=$(echo ",/.*${SUBSTR%.*}.*/")
              URL=$(echo "$URL" | awk '{print tolower($0)}')
              #printf "$URL\n"
              EXCLUDE_URLS="$EXCLUDE_URLS$URL"
      fi;
  done <<< "$(git diff --name-only --diff-filter=ACR $MERGEBASE)"

  echo $EXCLUDE_URLS
}

main