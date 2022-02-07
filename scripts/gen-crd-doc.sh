#!/bin/bash

set -eu

DEFAULT_STAGING_BRANCH="staging"

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -rn|--remote-name)     REMOTE_NAME="$2";     shift;shift ;;
    -sb|--staging-branch)  STAGING_BRANCH="$2";  shift;shift ;;
    -h|--help)
      cat <<HELPMSG

$0 [option...]

Generates the CRD schema documentation and commits it to the given staging branch in the given remote git repo.

Valid options:
  -rn|--remote-name
      The name of the git remote where the staging branch is located. This is typically "origin".
      Default: <undefined>
  -sb|--staging-branch
      The name of the branch will get the new CRD schema documentation committed to it.
      Default: "${DEFAULT_STAGING_BRANCH}"
HELPMSG
      exit 1
      ;;
    *)
      echo "Unknown argument [$key]. Aborting."
      exit 1
      ;;
  esac
done

: ${STAGING_BRANCH:=${DEFAULT_STAGING_BRANCH}}

if [ -z "${REMOTE_NAME:-}" ]; then
  echo "ERROR! You must specify a --remote-name."
  exit 1
fi

echo "===== SETTINGS"
echo REMOTE_NAME=$REMOTE_NAME
echo STAGING_BRANCH=$STAGING_BRANCH
echo "===== SETTINGS"

echo "===== Fetch the remote content"
git fetch ${REMOTE_NAME}

echo "===== Create a new branch named [${STAGING_BRANCH}] (or switch to it if it already exists)"
git checkout -b ${STAGING_BRANCH} ${REMOTE_NAME}/${STAGING_BRANCH} || (git checkout ${STAGING_BRANCH} && git reset --hard ${REMOTE_NAME}/${STAGING_BRANCH})

echo "===== Generate the CRD schema documentation"
make gen-crd-doc
git commit -am "Auto-generated CRD schema documentation"

echo "===== Push the branch [${STAGING_BRANCH}] to remote [${REMOTE_NAME}]"
git push ${REMOTE_NAME} ${STAGING_BRANCH}
