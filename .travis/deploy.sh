#!/usr/bin/env bash

# By default Travis checks out commit, and maven-release-plugin wants to know branch name
git checkout $TRAVIS_BRANCH

# Decrypt GitHub SSH key
openssl aes-256-cbc -K $encrypted_e577282bf6cb_key -iv $encrypted_e577282bf6cb_iv -in .travis/github_deploy.enc -out .travis/github_deploy -d
chmod 600 .travis/github_deploy
# Add
eval `ssh-agent -s`
ssh-add .travis/github_deploy

mvn -B release:prepare release:perform
