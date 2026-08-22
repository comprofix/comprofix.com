#!/usr/bin/env bash
#
# Validates that every /lib/... asset path referenced in the built site's
# rendered HTML actually exists in the build output. Only meaningful in
# self-host mode (self_host = true); in cors mode no /lib/ references are
# generated, and the script passes trivially with nothing to check.
#
# Usage: scripts/validate-self-hosted-assets.sh <build-output-dir>

set -euo pipefail

BUILD_DIR="${1:-}"

if [ -z "$BUILD_DIR" ] || [ ! -d "$BUILD_DIR" ]; then
  echo "Usage: $0 <build-output-dir>" >&2
  exit 2
fi

# Extract every href=/src= value starting with /lib/, whether quoted (dev
# builds) or unquoted (minified production builds), terminated by a quote,
# whitespace, or '>'.
mapfile -t refs < <(
  grep -rhoE '(href|src)=["'"'"']?/lib/[^"'"'"' >]+' "$BUILD_DIR" --include="*.html" \
    | sed -E 's/^(href|src)=["'"'"']?//' \
    | sort -u
)

if [ "${#refs[@]}" -eq 0 ]; then
  echo "No /lib/ asset references found (self_host is likely off) - nothing to check."
  exit 0
fi

missing=0
for ref in "${refs[@]}"; do
  # Strip a leading slash to make it relative to BUILD_DIR.
  rel="${ref#/}"
  if [ -f "$BUILD_DIR/$rel" ]; then
    echo "OK      $ref"
  else
    echo "MISSING $ref"
    missing=$((missing + 1))
  fi
done

echo ""
echo "Checked ${#refs[@]} unique self-hosted asset path(s), $missing missing."

if [ "$missing" -gt 0 ]; then
  exit 1
fi
