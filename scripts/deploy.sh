set -e

# Add ssh key
chmod 600 scripts/id_rsa
ssh-add -K scripts/id_rsa

# Clone target repo
git clone ssh://github.com/kovacsi/testrepo.git build-repo
cd build-repo

# Update files
rm -rf TestSDK.framework
cp -R ../build/Release-iphoneos/TestSDK.framework ./
lipo ../build/Release-iphoneos/TestSDK.framework/TestSDK ../build/Release-iphonesimulator/TestSDK.framework/TestSDK -create -output TestSDK.framework/TestSDK
git add --all TestSDK.framework

# Commit
git config user.name "Travis CI"
git config user.email "travis-ci@mattakis.com"
git commit -m "$(cd ../ &&  git rev-parse HEAD)"
git push origin master

# Clean up
cd ..
ssh-add -K -d scripts/id_rsa
rm -rf build-repo
