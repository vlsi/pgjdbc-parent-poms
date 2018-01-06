#!/usr/bin/env bash

# By default Travis checks out commit, and maven-release-plugin wants to know branch name
git checkout $TRAVIS_BRANCH

mvn -B release:prepare release:perform
