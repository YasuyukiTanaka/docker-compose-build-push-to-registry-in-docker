#!/bin/bash


serviceName=$1
repository=$2
TAG=$3
workingDirectory=$4

cd ${GITHUB_WORKSPACE}/${workingDirectory}
docker-compose -f ./docker-compose.yml build ${serviceName} >output.txt

if [ $? -ne 0 ];then
  echo "failed docker-compose"
  exit 1
fi
imageName=$(cat output.txt  | grep -E 'Successfully tagged ([a-z:_]+)'| sed 's/Successfully tagged //')
#$(aws ecr get-login --region ap-northeast-1 --no-include-email)
#account=$(aws sts get-caller-identity --query Account --output text)
#account=998292530266
#pushName="${account}.dkr.ecr.ap-northeast-1.amazonaws.com/${pushSuffix}"
#**.dkr.ecr.ap-northeast-1.amazonaws.com/bdk_cloud/ms_cloud_path_planner/api
#dkr.ecr.ap-northeast-1.amazonaws.com/bdk_cloud/ms_cloud_path_planner/api

AUTH_DATA=$(aws ecr get-authorization-token)
TOKEN=$(echo $AUTH_DATA | jq -r ".authorizationData[0].authorizationToken" | base64 --decode | awk -F":" '{ print $2 }')
ENDPOINT=$(echo $AUTH_DATA | jq -r ".authorizationData[0].proxyEndpoint")
REGISTRY=$(echo $ENDPOINT | sed 's/https\?://')
echo "REGISTRY $REGISTRY"
docker login -u AWS -p $TOKEN $ENDPOINT


echo "imageName ${imageName}"
echo "pushName ${pushName}"
PUSH_NAME=${REGISTRY}/${repository}:${TAG}
echo "PUSH_NAME ${PUSH_NAME}"

docker tag ${imageName} ${PUSH_NAME}
if [ $? -ne 0 ];then
  echo "failed docker tag"
  exit 1
fi

docker push ${PUSH_NAME}
if [ $? -ne 0 ];then
  echo "failed docker push"
  exit 1
fi

echo "Done"

