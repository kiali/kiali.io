#!/bin/bash

color() {
  local color="\e[3${1}m"
  local reset="\e[0m"

  shift

  if [[ "${COLOR}" == "never" ]]; then
    echo -en "${@}"
  else
    echo -en "${color}${@}${reset}"
  fi
}

log_prefix() {
  echo -n "::"
}

die() {
  error ${@}
  exit 1
}

error() {
  echo "$(color 1 "$(log_prefix) ERROR:") ${@}"
}

warn() {
  echo "$(color 3 "$(log_prefix) WARN:") ${@}"
}

info() {
  echo "$(color 2 "$(log_prefix)") ${@}"
}

[[ -z $(git status -s) ]] || die "The working tree is dirty. Please make sure it is clean before running."

set -e

GIT="git -c advice.detachedHead=false"

current_branch=$(git rev-parse --abbrev-ref HEAD)
trap "{ ${GIT} checkout ${current_branch}; }" EXIT

tempdir=$(mktemp -d)
trap "{ rm -rf ${tempdir}; }" EXIT

destination="content/documentation/archive"
cp "${destination}/_index.adoc" "${tempdir}"
rm -rf "${destination}/v*"

info "Making sure we have all the latest tags..."
git fetch --all --tags

generate() {
  tag="${1%.0}"

  info "Preparing documentation for version ${tag}"
  ${GIT} checkout ${1}
  mkdir ${tempdir}/${tag}
  cp -r content/documentation/* "${tempdir}/${tag}/"
  rm -rf "${tempdir}/${tag}/archive"

  find ${tempdir}/${tag} -type f -name "*.adoc" -exec sed -i -e "s/  main:/  $(echo ${tag} | tr "." "-"):/" "{}" \;
  sed -i "s/Documentation/${tag}/g" "${tempdir}/${tag}/_index.adoc"

  ${GIT} checkout ${current_branch}
}

if [ "${1}" = "all" ]; then
  info "Running for versions: $(git tag --list | paste -sd "," -)"
  for tag in $(git tag --list); do
    generate ${tag}
  done
else
  info "Running for version ${1}..."

  if git tag --list | grep "${1}" &>/dev/null; then
    generate ${1}
  else
    die "Tag ${1} could not be found"
  fi
fi

cp -rf ${tempdir}/* ${destination}

chmod 755 ${destination}
find ${destination} -type d -exec chmod 755 "{}" \;
find ${destination} -type f -exec chmod 644 "{}" \;
