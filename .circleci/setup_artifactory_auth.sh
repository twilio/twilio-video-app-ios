#!/bin/sh
chmod 600 .circleci/.netrc
cp .circleci/.netrc ~/.netrc
sed -i '' "s/ARTIFACTORY_USERNAME/${ARTIFACTORY_USERNAME}/g" ~/.netrc
sed -i '' "s/ARTIFACTORY_API_KEY/${ARTIFACTORY_API_KEY}/g" ~/.netrc

# This is needed when an SDK release is not public yet, to download private releases.
