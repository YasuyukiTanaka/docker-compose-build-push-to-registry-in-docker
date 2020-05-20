#!/bin/bash


serviceName=$1
pushName=$2
workingDirectory=$3

cd ${GITHUB_WORKSPACE}/${workingDirectory}
docker-compose -f ./docker-compose.yml build ${serviceName} >output.txt

if [ $? -ne 0 ];then
  echo "failed docker-compose"
  exit 1
fi
imageName=$(cat output.txt  | grep -E 'Successfully tagged ([a-z:_]+)'| sed 's/Successfully tagged //')
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

