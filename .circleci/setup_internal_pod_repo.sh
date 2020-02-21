#!/bin/sh
chmod 600 .circleci/.netrc
cp .circleci/.netrc ~/.netrc
sed -i '' "s/BINTRAY_USERNAME/${BINTRAY_USERNAME}/g" ~/.netrc
sed -i '' "s/BINTRAY_PASSWORD/${BINTRAY_PASSWORD}/g" ~/.netrc
pod repo add cocoapod-specs-internal git@github.com:twilio/cocoapod-specs-internal.git
