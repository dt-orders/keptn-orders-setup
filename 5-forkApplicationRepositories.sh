#!/bin/bash

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/5-forkApplicationRepositories.log)
exec 2>&1

command -v hub &> /dev/null
if [ $? -ne 0 ]
then
    echo "Please install the 'hub' command: https://hub.github.com/"
    exit 1
fi

SOURCE_GIT_ORG=keptn-orders
GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
HTTP_RESPONSE=`curl -s -o /dev/null -I -w "%{http_code}" https://github.com/$GITHUB_ORGANIZATION`

if [ $HTTP_RESPONSE -ne 200 ]
then
    echo "GitHub organization doesn't exist - https://github.com/$GITHUB_ORGANIZATION - HTTP status code $HTTP_RESPONSE"
    exit 1
fi

# this is list of repos to fork
declare -a repositories=("catalog-service" "customer-service" "front-end" "order-service")

clear
echo "===================================================="
echo "About to fork github repositories"
echo ""
echo "Source : https://github.com/$SOURCE_GIT_ORG"
echo "Target : https://github.com/$GITHUB_ORGANIZATION"
echo "Repos  : ${repositories[@]}"
echo ""
echo "*** NOTE: This will first delete the forked repos "
echo "          in the the target github organization ***"
echo "===================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

rm -rf repositories/
mkdir repositories
cd repositories

# first delete the repos if they are there
for repo in "${repositories[@]}"
do
    echo "Deleting $GITHUB_ORGANIZATION/$repo"
    curl -s -X DELETE -H "Authorization: token $GITHUB_PERSONAL_ACCESS_TOKEN" "https://api.github.com/repos/$GITHUB_ORGANIZATION/$repo"
done

for repo in "${repositories[@]}"
do
    echo -e "Cloning https://github.com/$SOURCE_GIT_ORG/$repo"
    git clone -q "https://github.com/$SOURCE_GIT_ORG/$repo"
    cd $repo
    echo -e "Forking $repo to $GITHUB_ORGANIZATION"
    hub fork --org=$GITHUB_ORGANIZATION
    cd ..
    echo -e "Done."
done

rm -rf repositories
mkdir repositories
cd repositories

for repo in "${repositories[@]}"
do
    TARGET_REPO="http://github.com/$GITHUB_ORGANIZATION/$repo"
    echo -e "Cloning $TARGET_REPO"
    git clone -q $TARGET_REPO
    echo -e "Done."
done