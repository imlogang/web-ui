#!/usr/bin/env bash
# Boots the built image and checks that nginx serves each route.
# Usage: test/smoke.sh <image>
set -euo pipefail

IMAGE="${1:?usage: smoke.sh <image>}"
PORT="${PORT:-8080}"
NAME="web-ui-smoke-$$"

docker run --rm "$IMAGE" nginx -t

docker run -d --rm --name "$NAME" -p "$PORT:80" "$IMAGE" >/dev/null
trap 'docker rm -f "$NAME" >/dev/null 2>&1 || true' EXIT

for _ in $(seq 1 20); do
  curl -fs -o /dev/null "http://localhost:$PORT/" && break
  sleep 0.5
done

fail=0
check() {
  local path="$1" want_type="$2" want_text="$3"
  local body headers
  headers=$(mktemp)
  if ! body=$(curl -fsS -D "$headers" "http://localhost:$PORT$path"); then
    echo "FAIL $path: request failed"; fail=1; return
  fi
  if ! grep -qi "^content-type: $want_type" "$headers"; then
    echo "FAIL $path: expected content-type $want_type"; cat "$headers"; fail=1; return
  fi
  if ! grep -q "$want_text" <<<"$body"; then
    echo "FAIL $path: body missing '$want_text'"; fail=1; return
  fi
  echo "ok   $path"
}

check /           text/html "Welcome to My Page"
check /resume     text/html "Logan Godsey - Resume"
check /blog       text/html "Logan Godsey's Blog"
check /style.css  text/css  "{"

exit $fail
