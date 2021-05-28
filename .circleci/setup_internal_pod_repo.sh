#!/bin/sh
chmod 600 .circleci/.netrc
cp .circleci/.netrc ~/.netrc
sed -i '' "s/ARTIFACTORY_USERNAME/${ARTIFACTORY_USERNAME}/g" ~/.netrc
sed -i '' "s/ARTIFACTORY_API_KEY/${ARTIFACTORY_API_KEY}/g" ~/.netrc
pod repo add cocoapod-specs-internal git@github.com:twilio/cocoapod-specs-internal.git
