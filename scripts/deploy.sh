# Hardfail on errors
set -e

if [ -n "$TRAVIS_TAG" ]; then

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
	echo "  spec.source               = { :git => 'https://github.com/migeran/travis-test.git', :tag => '$TRAVIS_TAG' }" >> $PODSPEC_FILE
	echo "  spec.source_files         = 'TestSDK/**/*.{h,m}'" >> $PODSPEC_FILE
    echo "  spec.public_header_files  = 'TestSDK/TestSDK.h'" >> $PODSPEC_FILE
	echo "  spec.requires_arc         = true" >> $PODSPEC_FILE
	echo "end" >> $PODSPEC_FILE

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
	rvm use default 2>&1

	echo "  Pushing to trunk..."
	set +e
	pod trunk push 2>&1
	if [ "$?" -ne 0 ]; then
		echo "pod trunk push failed!"
		exit 1
	fi
fi
