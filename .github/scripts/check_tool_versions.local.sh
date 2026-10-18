# shellcheck shell=bash
# SPDX-License-Identifier: MIT
# This repo's half of ./check_tool_versions.sh, which sources it before any
# section runs (its header has the contract). Not run on its own.
#
# The action SHAs and the lint tools in ../actions/setup-tool/tools.txt are
# checked; no image is pinned and no manifest is locked. Formula/say-hi.rb
# follows say-hi's releases, which drift.yml checks.

# shellcheck disable=SC2034 # read by check_tool_versions.sh
CI_IMAGE_GLOBS=''
