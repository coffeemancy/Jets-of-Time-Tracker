#!/usr/bin/env bash

# Script for generating flag images for tracker using ImageMagick.
#
# This script generates all the flag images in the images/flags directory
# using ImageMagick using text/font/sizes defined in this file, or
# overridden by env vars, based on "on" and "off" flag template images.
#
# Usage:
#
#   ./tools/generate-flag-images.sh

# Environment Variables
DRY_RUN="${DRY_RUN:-}"
FONT="${FONT:-DejaVu-Sans-Condensed-Bold}"
FLAG_OUTDIR="${OUTDIR:-images/flags}"
TEMPLATE_FLAG_OFF="${FLAG_OFF:-images/flags/template_Flag_off.png}"
TEMPLATE_FLAG_ON="${FLAG_ON:-images/flags/template_Flag_on.png}"

# Flag Definitions
# "Flag Text" "File name portion" pointsize
FLAGS=(
  "Bekkler Spot" "BekklerSpot" 12
  "Bucket List" "BucketList" 14
  "Bucket Go Mode Only" "BucketDisableOtherGo" 12
  "Chronosanity" "Chronosanity" 16
  "Cyrus Grave Spot" "CyrusGraveSpot" 12
  "Early Pendant" "EarlyPendant" 16
  "Epoch Fail" "EpochFail" 16
  "Johnny Race" "JohnnyRace" 16
  "Locked Chars" "CharLock" 16
  "Ozzie\'s Fort Spot" "OzzieFortSpot" 12
  "Race Log Spot" "RaceLogSpot" 12
  "Restore Tools" "RestoreTools" 16
  "Rocksanity" "Rocksanity" 16
  "Split Arris Dome" "SplitArrisDome" 12
  "Sun Keep Spot" "SunKeepSpot" 14
  "Unlocked Skyways" "UnlockedSkyways" 14
  "Show Extra Items" "ToggleExtraItems" 12
  "Hide Flags" "ToggleHideFlags" 12
)

function set_imagemagick_command {
  # check that imagemagick is installed
  if ! builtin command -v magick >/dev/null; then
    echo "This script requires imagemagick to be installed!"
    exit 1
  fi
  MAGICK="magick convert -font $FONT -fill white -gravity center"
  export MAGICK

  # check that template images exist
  if [[ ! -e "${TEMPLATE_FLAG_ON}" ]] || [[ ! -e  "${TEMPLATE_FLAG_OFF}" ]]; then
    echo "Template images do not exist: ${TEMPLATE_FLAG_ON}, ${TEMPLATE_FLAG_OFF}"
    exit 1
  fi

  # check output directory exists
  if [[ ! -d "${FLAG_OUTDIR}" ]]; then
    echo "Output directory does not exist: ${FLAG_OUTDIR}"
    exit 1
  fi
}

function create_flag_images {
  _text="$1"
  _on_out="$2"
  _off_out="$3"

  if [[ -n "$DRY_RUN" ]]; then
    echo "* Would create flag images for \"$text\" -> $on_out, $off_out"
  else
    echo "* Creating flag images for \"$_text\" -> $_on_out, $_off_out"
    $MAGICK -pointsize "$pointsize" -draw "text 0,0 '$_text'" "${TEMPLATE_FLAG_ON}" "$_on_out"
    $MAGICK -pointsize "$pointsize" -draw "text 0,0 '$_text'" "${TEMPLATE_FLAG_OFF}" "$_off_out"
  fi
}

function generate_all_flag_images {
  force=$1
  yes=$2

  echo "Generating flag images"
  echo "---------------------------------------------------------------"
  echo "  font:              ${FONT}"
  echo "  output directory:  ${FLAG_OUTDIR}"
  echo "  flag off template: ${TEMPLATE_FLAG_OFF}"
  echo "  flag on template:  ${TEMPLATE_FLAG_ON}"
  echo

  set -e
  for (( i=0; i<${#FLAGS[*]}; i=i+3 )); do
    text="${FLAGS[$i]}"
    on_out="${FLAG_OUTDIR}/Flag_${FLAGS[$i+1]}_on.png"
    off_out="${FLAG_OUTDIR}/Flag_${FLAGS[$i+1]}_off.png"
    pointsize="${FLAGS[$i+2]}"

    if [[ -e "$on_out" ]] || [[ -e "$off_out" ]]; then
      if (( force == 1 )); then
        if (( yes == 1 )); then
          create_flag_images "$text" "$on_out" "$off_out"
        else
          read -p "Overwrite files for \"$text\"? [y/N] " -n 1 -r
          echo
          if [[ $REPLY =~ ^[Yy]$ ]]; then
            create_flag_images "$text" "$on_out" "$off_out"
          fi
        fi
      else
        echo "* Skipping existing flag images ($on_out, $off_out)"
      fi
    else
      create_flag_images "$text" "$on_out" "$off_out"
    fi
  done
  set +e
}

function usage {
  echo "./generate-flag-images.sh [OPTIONS]"
  echo "Generates flag images for tracker using ImageMagick."
  echo
  echo "-d      dry-run; don't write files"
  echo "-f      overwrite existing files (prompts)"
  echo "-h      print usage"
  echo "-y      don't prompt; overwrite files"
}

force=0
yes=0
while getopts 'dfhy' flag; do
  case "${flag}" in
    d)
      DRY_RUN=1
      ;;
    f)
      force=1
      ;;
    y)
      yes=1
      ;;
    *)
      usage
      exit 0
    esac
done
export DRY_RUN

set_imagemagick_command
generate_all_flag_images $force $yes
