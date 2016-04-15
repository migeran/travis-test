#!/bin/bash

# Branch for tagged versions
if [ -n "$TRAVIS_TAG" ]; then
	echo "Updating framework version to $TRAVIS_TAG..."
	xcrun agvtool -noscm new-marketing-version "$TRAVIS_TAG"
fi
xcrun agvtool -noscm new-version -all "$TRAVIS_BUILD_NUMBER"
