#!/bin/bash

# Branch for tagged versions
if [ -n "$TRAVIS_TAG" ]; then
	echo "Updating framework version to $TRAVIS_TAG..."
	agvtool -noscm new-version -all "$TRAVIS_TAG"
fi
