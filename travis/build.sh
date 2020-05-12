#!/usr/bin/env nix-shell
#!nix-shell ../shell.nix -i bash

set -euo pipefail

# A local installation of maven prefers to run the global installation, if available.
sudo rm -f /etc/mavenrc

TRAVIS_BRANCH=
TRAVIS_PULL_REQUEST=

# We redirect maven test output to file, because Travis CI limits stdout log size to 4MB.

mvn --settings ./travis/maven-settings.xml -U install -DskipTests > /dev/null

case $TRAVIS_BRANCH in
    test|prod)
        targetEnv=$TRAVIS_BRANCH
    ;;
    *)
        targetEnv=dev
esac

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
    mvn --settings ./travis/maven-settings.xml deploy -pl '!gws-system-test' -DredirectTestOutputToFile
    mvn --settings ./travis/maven-settings.xml deploy -pl gws-system-test -DskipTests
    mvn --settings ./travis/maven-settings.xml site -DskipTests -pl gws-core
    cp ./gws-webapp/target/geodesy-web-services.war ./gws-system-test/target/gws-system-test.jar ./aws/codedeploy-WebServices/
    aws configure set aws_access_key_id "${TRAVIS_AWS_ACCESS_KEY_ID}" --profile geodesy
    aws configure set aws_secret_access_key "${TRAVIS_AWS_SECRET_KEY_ID}" --profile geodesy
    aws configure set region ap-southeast-2 --profile geodesy
    aws configure set output json --profile geodesy

    # Default TMPDIR is in /run, which is in memory, so we change it to disk to
    # avoid running out of space. `aws codedeploy push` writes the codedeploy
    # zip bundle to $TMPDIR.

    # TODO: Temporarily disable automatic deployments.
    export TMPDIR=/tmp

    ./aws/codedeploy-WebServices/deploy.sh $targetEnv
    ./aws/codedeploy-GeoServer/deploy.sh $targetEnv
    ./aws/deploy.sh $targetEnv

    if [[ $targetEnv = "prod" ]]; then
        mvn --settings ./travis/maven-settings.xml site-deploy -DskipTests -pl gws-core
    fi
else
    mvn --settings ./travis/maven-settings.xml verify -pl '!gws-system-test' -DredirectTestOutputToFile
    ./aws/deploy.sh $targetEnv --dry-run
fi
