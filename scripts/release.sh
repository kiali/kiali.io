#!/bin/bash

set -eu

if [ -z "${1:-}" ]; then
  echo "ERROR! Pass in a version string"
  exit 1
fi

CURRENT_VERSION="${1}"
REMOTE_NAME="${REMOTE_NAME:-origin}"
CURRENT_BRANCH="${CURRENT_BRANCH:-current}"
STAGING_BRANCH="${STAGING_BRANCH:-staging}"

echo "===== Fetch the remote content"
git fetch ${REMOTE_NAME}

echo "===== Create a new version branch named [${CURRENT_VERSION}] based on branch [${CURRENT_BRANCH}]"
git checkout -b ${CURRENT_VERSION} ${REMOTE_NAME}/${CURRENT_BRANCH}

echo "===== Setting the base URL for the branch [${CURRENT_VERSION}]"
sed -i "s/baseURL = .*/baseURL = \"https:\/\/${CURRENT_VERSION}.kiali.io\"/" config.toml
git commit -am "Set base URL for branch: ${CURRENT_VERSION}"

echo "===== Push the new version branch [${CURRENT_VERSION}] to remote [${REMOTE_NAME}]"
git push ${REMOTE_NAME} ${CURRENT_VERSION}

echo "===== Create a new branch named [${CURRENT_BRANCH}] (or switch to it if it already exists)"
git checkout -b ${CURRENT_BRANCH} ${REMOTE_NAME}/${CURRENT_BRANCH} || git checkout ${CURRENT_BRANCH}

echo "===== Reset branch [${CURRENT_BRANCH}] to the content of branch [${STAGING_BRANCH}] from remote [${REMOTE_NAME}]"
git reset --hard ${REMOTE_NAME}/${STAGING_BRANCH}

echo "===== Setting the base URL for the branch [${CURRENT_BRANCH}]"
sed -i "s/baseURL = .*/baseURL = \"https:\/\/kiali.io\"/" config.toml
git commit -am "Set base URL for branch: ${CURRENT_BRANCH}"

echo "===== Push the branch [${CURRENT_BRANCH}] to remote [${REMOTE_NAME}]"
git push --force ${REMOTE_NAME} ${CURRENT_BRANCH}
