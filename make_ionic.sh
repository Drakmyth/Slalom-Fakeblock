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
MAPS_VERSION="latest"
PARSE_ONLY=false
usage() { 
  printf "Usage: $0 \n\t-i input_api.json\tDefault=$API_FILE\n" 1>&2
  printf "\t-m maps_api_version\tDefault=$MAPS_VERSION\n" 1>&2
  printf "\t-p Parse key only\tDefault=$PARSE_ONLY\n" 1>&2
  exit 1
}

detect_os() {
  case $(uname) in
    'Darwin')
      PM="brew"
      ;;
    'Linux')
      if $(isinstalled "apt-get"); then
        PM="apt-get"
      elif $(isinstalled "yum"); then
        PM="yum"
      fi
      ;;
    *)
      echo "Error: Failed to detect OS!"
      exit 1
  esac
  echo $PM
}

install_depend() {
  package=$1
  printf "Detecting OS Package Manager: "
  packman="$(detect_os)"
  if $(isinstalled $packman); then
    echo "$packman"
  else
    echo "FAIL"
    echo "Error: $packman not installed"
    exit 1
  fi
  CMD="$packman install $package"
  eval $CMD
  if ! $(isinstalled $package); then
    echo "Failled to install $package via $packman"
    exit 1
  fi
}

install_ionic() {
  i_key=$1
  maps_v=$MAPS_VERSION

  depends='npm'
  #printf "Testing dependency: $depends "
  if ! $(isinstalled $depends); then
    echo "Not Found, installing depends: $depends"
    install_depend $depends
    if ! $(isinstalled $depends); then
      echo "FAIL"
      echo "Error: Dependency not met: $depends"
      exit 1
    fi
  fi
  
  echo "Installing ionic:"
  CMD="npm install --save @ionic-native/core @ionic-native/google-maps@${maps_v}"
  eval $CMD
  echo "Initiating plugin:"
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
    CMD="jq -r '.[].${p_key}' ${p_file}"
  else
    echo "FAIL"
    echo "Error: Dependency not met: $depends"
    exit 1
  fi

  eval $CMD
}

### Parse CLI Options  ###
while getopts ":hi:p" o; do
  case "${o}" in
    h)
      usage 
      ;;
    i)
      API_FILE=${OPTARG}
      ;;
    p)
      PARSE_ONLY=true
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

if $PARSE_ONLY; then
  echo $api_key
  exit 0
fi

# Confirm receipt of api_file
if [[ -z $api_key ]]; then
  echo "Error Parsing API Credentials: $API_FILE"
  usage
fi

install_ionic "$api_key"
