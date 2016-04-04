set -e
set -x

# Add ssh key
eval "$(ssh-agent -s)"
chmod 600 scripts/id_rsa

# Update git config
echo "Host travis-deploy" >> ~/.ssh/config
echo "    HostName github.com" >> ~/.ssh/config
echo "    User git" >> ~/.ssh/config
echo "    IdentityFile $(pwd)/scripts/id_rsa" >> ~/.ssh/config
echo "    IdentitiesOnly yes" >> ~/.ssh/config

# Clone target repo
git clone --depth=1 ssh://travis-deploy/kovacsi/testrepo.git build-repo
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
rm -rf build-repo
