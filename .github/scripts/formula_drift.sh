#!/usr/bin/env bash
# Compares the say-hi version Formula/say-hi.rb packages, read from its `url`,
# with say-hi's latest release, and prints `tap=`, `latest=`, and `drift=`
# lines - appended to $GITHUB_OUTPUT as well when that is set (drift.yml).
# Exits non-zero only when it cannot answer (no url line to read, an API
# error), never for drift itself: drift.yml decides what drift turns into.
#
# Usage: .github/scripts/formula_drift.sh [formula]  (default Formula/say-hi.rb)
# Env:   SAY_HI_REPO  owner/name to compare against (default ivylikethevine/say-hi)
#        GH_TOKEN     for `gh api`; say-hi is public, so any token will do
set -euo pipefail

formula="${1:-Formula/say-hi.rb}"
repo="${SAY_HI_REPO:-ivylikethevine/say-hi}"

# the stable url, never `head`: .../releases/download/v<version>/<tarball>
tap="$(sed -n -E 's|^  url "[^"]*/releases/download/v([^/"]+)/[^"]*"$|\1|p' "$formula")"
if [ -z "$tap" ] || [ "$(printf '%s\n' "$tap" | wc -l)" -ne 1 ]; then
  echo "::error file=$formula,title=formula drift::expected one release-tarball url in $formula, found: ${tap:-none}"
  exit 1
fi

# /releases/latest already skips drafts and prereleases, the same releases
# say-hi's release workflow opens no formula PR for
latest="$(gh api "repos/$repo/releases/latest" --jq .tag_name)"
latest="${latest#v}"
if [ -z "$latest" ]; then
  echo "::error title=formula drift::no tag_name in $repo's latest release"
  exit 1
fi

drift=false
[ "$tap" = "$latest" ] || drift=true

out="$(printf 'tap=%s\nlatest=%s\ndrift=%s\n' "$tap" "$latest" "$drift")"
echo "$out"
if [ -n "${GITHUB_OUTPUT:-}" ]; then
  echo "$out" >>"$GITHUB_OUTPUT"
fi
