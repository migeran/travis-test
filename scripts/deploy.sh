# Add ssh key
eval "$(ssh-agent -s)"
chmod 600 scripts/id_rsa
ssh-add scripts/id_rsa
ssh -o StrictHostKeyChecking=no git@github.com

# Hardfail on errors
set -e

echo "Cloning target repo..."
git clone --depth=1 ssh://github.com/kovacsi/testrepo.git build-repo
cd build-repo

echo "Updating files..."
rm -rf TestSDK.framework
cp -R ../build/Release-iphoneos/TestSDK.framework ./
lipo ../build/Release-iphoneos/TestSDK.framework/TestSDK ../build/Release-iphonesimulator/TestSDK.framework/TestSDK -create -output TestSDK.framework/TestSDK
git add --all TestSDK.framework

echo "Configuring git"
git config user.name "Travis CI"
git config user.email "travis-ci@mattakis.com"

# Branch for tagged versions
export DIST_BRANCH_NAME="master"
if [ -n "$TRAVIS_TAG" ]; then
	echo "Branching for $TRAVIS_TAG..."
	git checkout -b "$TRAVIS_TAG"
	export DIST_BRANCH_NAME="$TRAVIS_TAG"

	export PODSPEC_FILE="travis-test.podspec"

	echo "Creating podspec..."
	echo "  Podspec version/git branch: $TRAVIS_TAG"

	echo -n "" > $PODSPEC_FILE
	echo "Pod::Spec.new do |spec|" >> $PODSPEC_FILE
	echo "  spec.name                 = 'travis-test'" >> $PODSPEC_FILE
	echo "  spec.version              = '$TRAVIS_TAG'" >> $PODSPEC_FILE
	echo "  spec.homepage             = 'https://github.com/kovacsi/testrepo.git'" >> $PODSPEC_FILE
	echo "  spec.license              = { :type => 'EPL', :file => 'LICENSE.txt' }" >> $PODSPEC_FILE
	echo "  spec.author               = { 'Migeran' => 'support@migeran.com' }" >> $PODSPEC_FILE
	echo "  spec.summary              = 'Simple cocoapods test'" >> $PODSPEC_FILE
	echo "  spec.platform             = :ios, '8.4'" >> $PODSPEC_FILE
	echo "  spec.source               = { :git => 'https://github.com/kovacsi/testrepo.git', :branch => '$TRAVIS_TAG' }" >> $PODSPEC_FILE
	echo "  spec.vendored_frameworks  = 'TestSDK.framework'" >> $PODSPEC_FILE
	echo "  spec.requires_arc         = true" >> $PODSPEC_FILE
	echo "end" >> $PODSPEC_FILE
	git add "$PODSPEC_FILE"
fi

echo "Commiting..."
git commit -m "$TRAVIS_COMMIT"

echo "Pushing..."
git push origin "$DIST_BRANCH_NAME"

# Exit if non-tagged
if [ -n "$TRAVIS_TAG" ]; then
	echo "Pushing to CocoaPods..."
	set +e

	which rvm &> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "rvm is not installed!" 1>&2
		exit 1
	fi

	which pod &> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "pod is not installed!" 1>&2
		exit 1
	fi

	set -e
	source ~/.rvm/scripts/rvm
	rvm use default

	pod trunk push
	if [ "$?" -ne 0 ]; then
		echo "pod trunk push failed!" 1>&2
		exit 1
	fi
fi
