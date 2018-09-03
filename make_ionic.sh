#!/bin/bash
# This script attempts to install/activate Ionic 3 environment in this repo: 
# 
# https://github.com/ionic-team/ionic-native-google-maps:
#
# """
# @ionic-native/google-maps plugin is a wrapper plugin for cordova-plugin-googlemaps for Ionic framework.
#
# Ionic Native wraps plugin callbacks in a Promise or Observable, providing a common interface for all plugins
# and making it easy to use plugins with Angular change detection. 
# """

API_FILE="keys.do_not_commit.json"
API_KEY="google_maps_api"
MAPS_VERSION="4.9.1"

usage() { echo "Usage: $0 [-i <input api.json for parsing>]" 1>&2; exit 1; }

install_ionic() {

  CMD="npm install @ionic-native/core @ionic-native/google-maps@${maps_v}"
  CMD="ionic cordova plugin add cordova-plugin-googlemaps --variable API_KEY_FOR_ANDROID=\"${api_key}\" --variable API_KEY_FOR_IOS=\"${api_key}\""

}

isfile() {
  echo $1
  if [[ -f $1 ]]; then
    return 0 
  else
    return 1
  fi
}

isinstalled() {
  echo "Checking installed command: $1"
  if [ -x "$(command -v $1)" ]; then
    return 0
  else
    return 1
  fi
}

parse_key_file() {
  p_file=$1
  p_key=$2

  depends='jq'
  echo "Checking dependency: $depends" 
  if isinstalled $depends; then
    CMD="jq -r '.[].${p_key}' ${p_file}"
    echo "Running parse cmd: $CMD"
    eval $CMD
  else
    echo "Error: Dependency not met: $depends"
  fi
}

### Parse CLI Options  ###
while getopts ":hi:" o; do
  case "${o}" in
    h)
      usage 
      ;;
    i)
      API_FILE=${OPTARG}
      ;;
    *)
      usage
    ;;
  esac
done
shift $((OPTIND-1))

# Confirm api_file exists
if isfile $API_FILE; then
  echo "Parsing API Credentials: $API_FILE"
  api_key="$(parse_key_file $API_FILE $API_KEY)"
  # Confirm receipt of api_file
  if [[ -z $api_key ]]; then
    echo "Error Parsing API Credentials: $API_FILE"
    usage
  fi
else
  echo "Error: Infile not found: $API_FILE"
  usage
fi

echo $api_key
