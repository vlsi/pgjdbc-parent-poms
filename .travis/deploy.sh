#!/usr/bin/env bash

# Fail script on error
set -e

cd .travis
mkdir secrets

# GPG is required for artifact signing
openssl aes-256-cbc -k "$SUPER_SECRET_KEY" -in secrets.tar.enc -out secrets/secrets.tar -d

cd secrets
tar xvf secrets.tar

gpg --import gpg-secret.key
gpg --import-ownertrust gpg-ownertrust

# Decrypt GitHub SSH key
chmod 600 github_deploy
eval $(ssh-agent -s)
ssh-add ./github_deploy

cd ..
rm -rf ./secrets

cd ..

git config --global user.name "pgjdbc CI"
git config --global user.email "pgsql-jdbc@postgresql.org"

# By default Travis checks out commit, and maven-release-plugin wants to know branch name
# On top of that, maven-release-plugin publishes branch, and it would terminate Travis job (current one!),
# so we checkout a non-existing branch, so it won't get published
# Note: at the end, we need to update "master" branch accordingly" (see $ORIGINAL_BRANCH)
TMP_BRANCH=tmp/$TRAVIS_BRANCH
git checkout -b "$TMP_BRANCH"

# Remove tmp branch if exists
git push git@github.com:$TRAVIS_REPO_SLUG.git ":$TMP_BRANCH" || true
# Remove release tag if exists just in case
git push git@github.com:$TRAVIS_REPO_SLUG.git :$RELEASE_TAG || true

set -x
# -Darguments here is for maven-release-plugin
MVN_SETTINGS=$(pwd)/.travis/settings.xml
mvn -B --settings .travis/settings.xml -Darguments="--settings '${MVN_SETTINGS}'" release:prepare release:perform

# Point "master" branch to "next development snapshot commit"
ORIGINAL_BRANCH=${TRAVIS_BRANCH#release/}
git push git@github.com:$TRAVIS_REPO_SLUG.git "HEAD:$ORIGINAL_BRANCH"
# Removal of the temporary branch is a separate command, so it left behind for the analysis in case "push to master" fails
git push git@github.com:$TRAVIS_REPO_SLUG.git ":$TMP_BRANCH"
