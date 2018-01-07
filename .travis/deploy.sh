#!/usr/bin/env bash

# By default Travis checks out commit, and maven-release-plugin wants to know branch name
git checkout -b tmp/$TRAVIS_BRANCH

cd .travis

# GPG is required for artifact signing
openssl aes-256-cbc -K $encrypted_e577282bf6cb_key -iv $encrypted_e577282bf6cb_iv -in secrets.tar.enc -out secrets.tar -d
tar xvf secrets.tar

gpg --import gpg-secret.key
gpg --import-ownertrust gpg-ownertrust && echo "imported ownertrust"

# Decrypt GitHub SSH key
chmod 600 github_deploy
eval `ssh-agent -s`
ssh-add ./github_deploy

cd ..

set -x
# -Darguments here is for maven-release-plugin
MVN_SETTINGS=$(pwd)/settings.xml
mvn -B --settings settings.xml -Darguments="--settings ${MVN_SETTINGS}" release:prepare release:perform
