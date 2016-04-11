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
	git checkout -b "dist-$TRAVIS_TAG"
	export DIST_BRANCH_NAME="dist-$TRAVIS_TAG"

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
	echo "  spec.source               = { :git => 'https://github.com/kovacsi/testrepo.git', :tag => '$TRAVIS_TAG' }" >> $PODSPEC_FILE
	echo "  spec.vendored_frameworks  = 'TestSDK.framework'" >> $PODSPEC_FILE
	echo "  spec.requires_arc         = true" >> $PODSPEC_FILE
	echo "end" >> $PODSPEC_FILE
	git add "$PODSPEC_FILE"
fi

echo "Commiting..."
git commit -m "$TRAVIS_COMMIT"

echo "Pushing..."
git push origin "$DIST_BRANCH_NAME"

if [ -n "$TRAVIS_TAG" ]; then
	echo "Tagging..."
	git tag "$TRAVIS_TAG"
	git push origin tag "$TRAVIS_TAG"
fi

# Exit if non-tagged
if [ -n "$TRAVIS_TAG" ]; then
	echo "Pushing to CocoaPods..."
	set +e

	echo "  Looking for rvm..."
	which rvm &> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "rvm is not installed!"
		exit 1
	fi

	echo "  Looking for pod..."
	which pod &> /dev/null
	if [ "$?" -ne 0 ]; then
		echo "pod is not installed!"
		exit 1
	fi

	echo "  Sourcing rvm scripts..."
	set -e
	source ~/.rvm/scripts/rvm 2>&1
	rvm use default 2>&1

	echo "  Pushing to trunk..."
	set +e
	pod trunk push 2>&1
	if [ "$?" -ne 0 ]; then
		echo "pod trunk push failed!"
		exit 1
	fi
fi
