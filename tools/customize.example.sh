#!/usr/bin/env bash

set -euo pipefail

# This script is intended to be used to provide user-specific customizations
# to pack files before they are zipped up by tools/release.sh.
#
# If this script was copied to "customize.sh", a custom pack could be built
# via:
#
#     ./tools/release.sh -c customize.sh -o ctjot-custom.zip
#
# It is run within the $TEMP_DIR directory, immediately before the final
# "Building release zip" phase of tools/release.sh. It has access to all the
# pack files in the "zip" directory inside of $TEMP_DIR.
#
# The following environment variables are guarnteed to be available:
#
# TEMP_DIR : location of temporary build files (where this script is running)
# GIT_ROOT : the location of git files for this repo (outside of TEMP_DIR)


function regen_images {
  # Regenerates images using tools/generate-flag-images.sh with custom settings
  echo " -> Regenerating flag images"
  FONT="Cantarell-Extra-Bold"
  OUTDIR="${TEMP_DIR}/zip/images/flags"
  export FONT FLAG_OFF FLAG_ON OUTDIR
  "${GIT_ROOT}/tools/generate-flag-images.sh" -fy >/dev/null
}

# update manifest.json for custom version
if command -v jq; then
  contents="$(jq '.name |= "Jets of Time Tracker (Customized)"' zip/manifest.json)"
  echo "$contents" > "zip/manifest.json"
fi

if command -v magick; then
  regen_images
fi
