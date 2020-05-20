#!/bin/bash


serviceName=$1
pushSuffix=$2
workingDirectory=$3

cd ${GITHUB_WORKSPACE}/${workingDirectory}
docker-compose -f ./docker-compose.yml build ${serviceName} >output.txt

if [ $? -ne 0 ];then
  echo "failed docker-compose"
  exit 1
fi
imageName=$(cat output.txt  | grep -E 'Successfully tagged ([a-z:_]+)'| sed 's/Successfully tagged //')
$(aws ecr get-login --region ap-northeast-1 --no-include-email)
#account=$(aws sts get-caller-identity --query Account --output text)
account=998292530266
pushName=push_target_api="${account}.dkr.ecr.ap-northeast-1.amazonaws.com/${pushSuffix}"
#**.dkr.ecr.ap-northeast-1.amazonaws.com/bdk_cloud/ms_cloud_path_planner/api
#dkr.ecr.ap-northeast-1.amazonaws.com/bdk_cloud/ms_cloud_path_planner/api
docker tag ${imageName} ${pushName}
if [ $? -ne 0 ];then
  echo "failed docker tag"
  exit 1
fi
docker push ${pushName}
if [ $? -ne 0 ];then
  echo "failed docker push"
  exit 1
fi

echo "Done"

