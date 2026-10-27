#!/usr/bin/env bash
# Prints "true" when the kiali/hugo image should be rebuilt (missing or Dockerfile is newer).
set -euo pipefail

dorp="${1:?container runtime (podman|docker)}"
image="${2:?image name}"

if ! "${dorp}" inspect "${image}" >/dev/null 2>&1; then
  echo true
  exit 0
fi

dockerfile_mtime="$(stat -c %Y Dockerfile 2>/dev/null || stat -f %m Dockerfile)"
created="$("${dorp}" inspect -f '{{.Created}}' "${image}" 2>/dev/null || true)"
image_mtime=0

if [[ -n "${created}" ]]; then
  if image_mtime="$(date -d "${created}" +%s 2>/dev/null)"; then
    :
  elif image_mtime="$(date -j -f "%Y-%m-%dT%H:%M:%S" "${created%%.*}" +%s 2>/dev/null)"; then
    :
  else
    image_mtime=0
  fi
fi

if [[ "${dockerfile_mtime}" -gt "${image_mtime}" ]]; then
  echo true
else
  echo false
fi
