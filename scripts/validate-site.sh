#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

cd themes/docsy && npm install && cd ../..
npm prune
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# Build with a local baseURL so htmlproofer checks this branch's output instead of
# fetching the live staging site (which may not yet include pages from the PR).
PROOFER_PORT=8765
LOCAL_BASE_URL="http://127.0.0.1:${PROOFER_PORT}/"
hugo --baseURL "${LOCAL_BASE_URL}"

npx --yes http-server ./public -p "${PROOFER_PORT}" -a 127.0.0.1 -s &
SERVER_PID=$!
trap 'kill "${SERVER_PID}" 2>/dev/null || true' EXIT
sleep 2

URL_IGNORE="#"
URL_IGNORE+=",/^https:\\/\\/github.com\\/kiali\\/kiali\\/pull\\/\\d+/"
URL_IGNORE+=",/^https:\\/\\/github.com\\/kiali\\/kiali\\/issues\\/\\d+/"
URL_IGNORE+=",/^https:\\/\\/github.com\\/kiali\\/kiali\\/issues\\/new/"
URL_IGNORE+=",/^https:\\/\\/github.com\\/kiali\\/kiali\\/tree\\/v\\d+\\.\\d+(\\.\\d+)?\\//"
URL_IGNORE+=",/^https:\\/\\/github.com\\/kiali\\/kiali\\/blob\\/v\\d+\\.\\d+(\\.\\d+)?\\//"
URL_IGNORE+=",/^https:\\/\\/github.com\\/kiali\\/kiali\\.io\\/edit\\//"
URL_IGNORE+=",/^https:\\/\\/github.com\\/kiali\\/kiali\\.io\\/new\\//"
URL_IGNORE+=",/^https:\\/\\/github.com\\/kiali\\/kiali\\.io\\/commit\\//"
URL_IGNORE+=",/^https:\\/\\/github.com\\/kiali\\/kiali\\.io\\/issues\\/new/"
URL_IGNORE+=",/.*web.libera.chat.*/"
URL_IGNORE+=",/^http:\\/\\/tracing\\.istio-system.*/"
URL_IGNORE+=",/.*tracing-service.*/"
URL_IGNORE+=",/.*\\.svc\\.cluster\\.local.*/"

NEW_URLS=$(scripts/ignore_new_urls.sh 2>/dev/null || true)
URL_IGNORE+="${NEW_URLS}"

htmlproofer \
  --typhoeus '{"connecttimeout":120, "timeout":120, "headers":{"User-Agent":"Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"}}' \
  --hydra='{"max_concurrency":2}' \
  --allow-hash-href \
  --allow-missing-href \
  --ignore-empty-alt \
  --ignore-missing-alt \
  --no-check-external-hash \
  --no-check-internal-hash \
  --no-enforce-https \
  --ignore_status_codes "0,301,302,403,429,503,999" \
  --ignore-urls "${URL_IGNORE}" \
  ./public
