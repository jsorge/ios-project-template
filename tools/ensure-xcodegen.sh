#!/usr/bin/env bash

set -e
set -o pipefail
set -u

required_version="$(cat .xcodegen-version)"
install_location=./vendor

install() {
  if [ ! -d $install_location ]; then
    mkdir $install_location;
  fi;

  rm -f ./tmp/XcodeGen ./tmp/xcodegen.tar.gz

  curl --location --fail --retry 5 \
    https://github.com/yonaskolb/XcodeGen/releases/download/"$required_version"/xcodegen.zip \
    --output $install_location/xcodegen.zip

  (
    cd $install_location
    unzip -o xcodegen.zip -d download > /dev/null
    mv download/xcodegen/bin/xcodegen XcodeGen
    rm -rf xcodegen.zip download
  )

  echo "Installed XcodeGen locally"
}

if [ ! -x $install_location/XcodeGen ]; then
  install
elif ! diff <(echo "Version: $required_version") <($install_location/XcodeGen version) > /dev/null; then
  install
fi
