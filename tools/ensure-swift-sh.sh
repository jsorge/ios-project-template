#!/usr/bin/env bash

set -e
set -o pipefail
set -u

required_version="$(cat .swift-sh-version)"
install_location=./vendor

install() {
  if [ ! -d $install_location ]; then
    mkdir $install_location;
  fi;

  rm -f $install_location/XcodeGen $install_location/xcodegen.tar.gz

  curl --location --fail --retry 5 \
    https://github.com/mxcl/swift-sh/archive/"$required_version".zip \
    --output $install_location/swift-sh-pkg.zip

  (
    cd $install_location
    unzip -o swift-sh-pkg.zip
    unzipped_path=./swift-sh-$required_version
	swift build --package-path $unzipped_path/ -c release
    mv $unzipped_path/.build/release/swift-sh swift-sh
    rm -rf $unzipped_path
    rm swift-sh-pkg.zip
    echo "$required_version" > swift-sh-version
  )

  echo "Installed swift-sh locally"
}

if [ ! -x $install_location/swift-sh ]; then
  install
elif [[ ! $required_version == $(cat $install_location/swift-sh-version) ]]; then
  install
fi
