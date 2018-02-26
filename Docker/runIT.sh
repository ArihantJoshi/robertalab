#!/bin/bash

if [[ ! $(cat /proc/1/sched | head -n 1 | grep init) ]]
then
   echo 'running in a docker container :-)'
else
   echo 'not running in a docker container - exit 1 to avoid destruction and crash :-)'
   exit 1
fi

cd /opt/robertalab
git fetch https://github.com/OpenRoberta/robertalab.git

cd /opt/robertalab/OpenRobertaParent
mvn clean install

cd /opt/robertalab
rm -rf DockerInstallation
./ora.sh --export /opt/robertalab/DockerInstallation

yes yes | ./ora.sh --createEmptydb
cp -r OpenRobertaParent/OpenRobertaServer/db-$VERSION DockerInstallation

cp Docker/Dockerfile* Docker/*.sh DockerInstallation

cd /opt/robertalab/DockerInstallation
docker build -t rbudde/openrobertalab:$VERSION -f DockerfileLab .
docker build --build-arg version=$VERSION -t rbudde/openrobertadb:$VERSION -f DockerfileDb .

docker build -t rbudde/openrobertaupgrade:$VERSION -f DockerfileUpgrade .

docker build -t rbudde/openrobertalabembedded:$VERSION -f DockerfileLabEmbedded .
docker build --build-arg version=$VERSION -t rbudde/openrobertaemptydbfortest:$VERSION -f DockerfileDbEmptyForTest .