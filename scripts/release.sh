#!/bin/bash

set -eu

DEFAULT_CURRENT_BRANCH="current"
DEFAULT_STAGING_BRANCH="staging"

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -cb|--current-branch)  CURRENT_BRANCH="$2";  shift;shift ;;
    -cv|--current-version) CURRENT_VERSION="$2"; shift;shift ;;
    -rn|--remote-name)     REMOTE_NAME="$2";     shift;shift ;;
    -sb|--staging-branch)  STAGING_BRANCH="$2";  shift;shift ;;
    -h|--help)
      cat <<HELPMSG

$0 [option...]

Releases the new documentation by creating a new version branch based on the current branch, and
making the current branch then based on the staging branch.

Valid options:
  -cb|--current-branch
      The name of the branch containing the current documentation. This branch will be the basis for
      the versioned documentation (see --current-version).
      Default: "${DEFAULT_CURRENT_BRANCH}"
  -cv|--current-version
      A new version branch will be created with the name of this version string.
      Note that it is expected that this be in the form of "vX.Y.Z" but only the "vX.Y" portion
      will be used by this script. However, if the "Z" number is anything other than "0" this script will abort.
      In other words, this script will not release patch-level documentation.
      This new version branch will be a copy of the "current" branch.
      Default: <undefined>
  -rn|--remote-name
      The name of the git remote where the branches are located. This is typically "origin".
      Default: <undefined>
  -sb|--staging-branch
      The name of the branch containing the content that will become the current version of the documentation.
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

: ${CURRENT_BRANCH:=${DEFAULT_CURRENT_BRANCH}}
: ${STAGING_BRANCH:=${DEFAULT_STAGING_BRANCH}}

if [ -z "${CURRENT_VERSION:-}" ]; then
  echo "ERROR! You must specify a --current-version."
  exit 1
fi

if [ -z "${REMOTE_NAME:-}" ]; then
  echo "ERROR! You must specify a --remote-name."
  exit 1
fi

# Require vX.Y.Z with Z == 0.
if ! [[ ${CURRENT_VERSION} =~ ^v[0-9]+\.[0-9]+\.0$ ]]; then
  echo "ERROR! You must specify --current-version in the form of vX.Y.Z where X and Y are numbers and Z is 0: ${CURRENT_VERSION}"
  exit 1
fi

# Only use the vX.Y portion of the version string (strip the patch number).
# Because the version is used as part of the base image, the version for the base image URL should have dots converted to dashes
CURRENT_VERSION=$(echo ${CURRENT_VERSION} | sed -E 's/(v[0-9]+\.[0-9]+)\.[0-9]+/\1/')
CURRENT_VERSION_WITH_DASHES="${CURRENT_VERSION//./-}"

# Prepare the new params.versions to be added to the config.toml within the staging branch
NEXT_PARAMS_VERSIONS_PLACEHOLDER="## NEXT PARAMS.VERSIONS PLACEHOLDER"
NEW_PARAMS_VERSIONS=$(cat <<EOM
${NEXT_PARAMS_VERSIONS_PLACEHOLDER}

[[ params.versions ]]
  version = "${CURRENT_VERSION}"
  url = "https://${CURRENT_VERSION_WITH_DASHES}.kiali.io"
EOM
)

echo "===== SETTINGS"
echo CURRENT_BRANCH=$CURRENT_BRANCH
echo CURRENT_VERSION=$CURRENT_VERSION
echo CURRENT_VERSION_WITH_DASHES=$CURRENT_VERSION_WITH_DASHES
echo REMOTE_NAME=$REMOTE_NAME
echo STAGING_BRANCH=$STAGING_BRANCH
printf "NEW_PARAMS_VERSIONS:\n${NEW_PARAMS_VERSIONS}\n"
echo "===== SETTINGS"

echo "===== Fetch the remote content"
git fetch ${REMOTE_NAME}

echo "===== Create a new version branch named [${CURRENT_VERSION}] based on branch [${CURRENT_BRANCH}]"
git checkout -b ${CURRENT_VERSION} ${REMOTE_NAME}/${CURRENT_BRANCH}

echo "===== Set baseURL in config.toml for the branch [${CURRENT_VERSION}]"
sed -i "s/baseURL = .*/baseURL = \"https:\/\/${CURRENT_VERSION_WITH_DASHES}.kiali.io\"/" config.toml
git commit -am "Set base URL for branch: ${CURRENT_VERSION}"

echo "===== Push the new version branch [${CURRENT_VERSION}] to remote [${REMOTE_NAME}]"
git push ${REMOTE_NAME} ${CURRENT_VERSION}

echo "===== Create a new branch named [${STAGING_BRANCH}] (or switch to it if it already exists)"
git checkout -b ${STAGING_BRANCH} ${REMOTE_NAME}/${STAGING_BRANCH} || git checkout ${STAGING_BRANCH}

echo "===== Add new params.versions in config.toml for version [${CURRENT_VERSION}] in the branch [${STAGING_BRANCH}]"
NEW_PARAMS_VERSIONS="${NEW_PARAMS_VERSIONS//\//\\/}"
NEW_PARAMS_VERSIONS="${NEW_PARAMS_VERSIONS//$'\n'/\\n}"
sed -i "s/${NEXT_PARAMS_VERSIONS_PLACEHOLDER}/${NEW_PARAMS_VERSIONS}/" config.toml
git commit -am "Add params.versions: ${CURRENT_VERSION}"

echo "===== Push the branch [${STAGING_BRANCH}] to remote [${REMOTE_NAME}]"
git push ${REMOTE_NAME} ${STAGING_BRANCH}

echo "===== Create a new branch named [${CURRENT_BRANCH}] (or switch to it if it already exists)"
git checkout -b ${CURRENT_BRANCH} ${REMOTE_NAME}/${CURRENT_BRANCH} || git checkout ${CURRENT_BRANCH}

echo "===== Reset branch [${CURRENT_BRANCH}] to the content of branch [${STAGING_BRANCH}] from remote [${REMOTE_NAME}]"
git reset --hard ${REMOTE_NAME}/${STAGING_BRANCH}

echo "===== Set baseURL in config.toml for the branch [${CURRENT_BRANCH}]"
sed -i "s/baseURL = .*/baseURL = \"https:\/\/kiali.io\"/" config.toml
git commit -am "Set base URL for branch: ${CURRENT_BRANCH}"

echo "===== Push the branch [${CURRENT_BRANCH}] to remote [${REMOTE_NAME}]"
git push --force ${REMOTE_NAME} ${CURRENT_BRANCH}
