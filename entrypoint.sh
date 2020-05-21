#!/bin/bash


SERVICE_NAME=$1
COMPOSE_YAML=$2
REPOSITORY=$3
TAG=$4
WORK_DIRECTORY=$5

cd ${GITHUB_WORKSPACE}/${WORK_DIRECTORY}
docker-compose -f ${COMPOSE_YAML} build ${SERVICE_NAME} >output.txt

if [ $? -ne 0 ];then
  echo "failed docker-compose"
  exit 1
fi
IMAGE_NAME=$(cat output.txt  | grep -E 'Successfully tagged ([a-z:_]+)'| sed 's/Successfully tagged //')
rm output.txt

AUTH_DATA=$(aws ecr get-authorization-token)
TOKEN=$(echo $AUTH_DATA | jq -r ".authorizationData[0].authorizationToken" | base64 --decode | awk -F":" '{ print $2 }')
ENDPOINT=$(echo $AUTH_DATA | jq -r ".authorizationData[0].proxyEndpoint")
REGISTRY=$(echo $ENDPOINT | sed 's/https\?:\/\///')
echo "REGISTRY $REGISTRY"
docker login -u AWS -p $TOKEN $ENDPOINT


echo "IMAGE_NAME ${IMAGE_NAME}"
PUSH_NAME=${REGISTRY}/${REPOSITORY}:${TAG}
echo "PUSH_NAME ${PUSH_NAME}"

docker tag ${IMAGE_NAME} ${PUSH_NAME}
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

