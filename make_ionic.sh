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

usage() { printf "Usage: $0 \n\t-i input_api.json\tDefault=$API_FILE\n\t-m maps_api_version\tDefault=$MAPS_VERSION\n" 1>&2; exit 1; }

install_ionic() {
  i_key=$1
  maps_v=$MAPS_VERSION

  depends='npm'
  #printf "Testing dependency: $depends "
  if ! $(isinstalled $depends); then
    echo "FAIL"
    echo "Error: Dependency not met: $depends"
    exit 1
  fi

  CMD="npm install @ionic-native/core @ionic-native/google-maps@${maps_v}"
  eval $CMD
  CMD="ionic cordova plugin add cordova-plugin-googlemaps --variable API_KEY_FOR_ANDROID=\"$i_key\" --variable API_KEY_FOR_IOS=\"$i_key\""
  eval $CMD
}

isfile() {
  if [[ -f $1 ]]; then
    return 0 
  else
    return 1
  fi
}

isinstalled() {
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
  #printf "Testing dependency: $depends "
  if $(isinstalled $depends); then
    #echo "OK"
    CMD="jq -r '.[].${p_key}' ${p_file}"
  else
    echo "FAIL"
    echo "Error: Dependency not met: $depends"
    exit 1
  fi

  eval $CMD
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
if ! $(isfile $API_FILE); then
  echo "Error: Infile not found: $API_FILE\n"
  usage
fi

echo "Parsing API Credentials: $API_FILE"
api_key="$(parse_key_file $API_FILE $API_KEY)"

# Confirm receipt of api_file
if [[ -z $api_key ]]; then
  echo "Error Parsing API Credentials: $API_FILE"
  usage
fi

echo "API Key: $api_key"
install_ionic "$api_key"
