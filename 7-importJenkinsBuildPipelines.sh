YLW='\033[1;33m'
NC='\033[0m'

GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')

HTTP_RESPONSE=`curl -s -o /dev/null -I -w "%{http_code}" https://github.com/$GITHUB_ORGANIZATION`
if [ $HTTP_RESPONSE -ne 200 ]
then
    echo "GitHub organization doesn't exist - https://github.com/$GITHUB_ORGANIZATION - HTTP status code $HTTP_RESPONSE"
    exit 1
fi

JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
INGRESS_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o=json | jq -r .status.loadBalancer.ingress[].ip)
JENKINS_URL="http://jenkins.keptn.$INGRESS_IP.xip.io/"

# clean up generated file.  dont delete the README!
rm -f pipelines/gen/*.xml
rm -f pipelines/gen/*.bak

# copy the job templates to gen folder
cp pipelines/deploy*.xml pipelines/gen/
cp pipelines/load*.xml pipelines/gen/
cp pipelines/build*.xml pipelines/gen/
JOBLIST="build-order-service build-catalog-service build-customer-service build-front-end"

echo "----------------------------------------------------"
echo "Creating Pipleine Jobs in Jenkins"
echo "Source of Jenkinsfiles : http://github.com/$GITHUB_ORGANIZATION"
echo "Jenkins Server         : $JENKINS_URL"
echo "Job list to process    : $JOBLIST"
echo "----------------------------------------------------"

# loop through a list of jobs and create them.  if already exists, delete it first
OSTYPE=$(uname -s)
for JOB_NAME in $JOBLIST; do
  # update each copy of the job template file in gen folder with GIT org name
  # NOTE: Mac requires the name of backup file as an argument, Linux does not
  if [ $OSTYPE = "Darwin" ]; then
    sed -i .bak s/ORG_PLACEHOLDER/$GITHUB_ORGANIZATION/g pipelines/gen/$JOB_NAME.xml
  else
    sed -i s/ORG_PLACEHOLDER/$GITHUB_ORGANIZATION/g pipelines/gen/$JOB_NAME.xml
  fi

  # determine if need to delete job first
  status_code=$(curl --write-out %{http_code} --silent --output /dev/null $JENKINS_URL/job/$JOB_NAME/config.xml -u $JENKINS_USER:$JENKINS_PASSWORD)
  if [[ "$status_code" -eq 200 ]] ; then
    echo Removing existing job $JOB_NAME ...
    curl -s -XPOST $JENKINS_URL/job/$JOB_NAME/doDelete -u $JENKINS_USER:$JENKINS_PASSWORD -H "Content-Type:text/xml"
  fi

  # add the job
  echo Creating job $JOB_NAME ...
  curl -s -XPOST $JENKINS_URL/createItem?name=$JOB_NAME --user $JENKINS_USER:$JENKINS_PASSWORD --data-binary @pipelines/gen/$JOB_NAME.xml -H "Content-Type:text/xml"
done

# show jenkins
./showJenkins.sh