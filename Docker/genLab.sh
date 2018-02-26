#!/bin/bash

if [[ ! $(cat /proc/1/sched | head -n 1 | grep init) ]]
then
   echo 'running in a docker container :-)'
else
   echo 'not running in a docker container - exit 1 to avoid destruction and crash :-)'
   exit 1
fi
VERSION="$1"
if [ -z "$VERSION" ]
then
    echo 'the version parameter of form x.y.z is missing - exit 12'
    exit 12
else
    echo "generating the version $VERSION"
fi

cd /opt
git fetch https://github.com/OpenRoberta/robertalab.git

cd /opt/robertalab/OpenRobertaParent
mvn clean install
chmod +x RobotArdu/resources/linux/arduino-builder RobotArdu/resources/linux/tools-builder/ctags/5.8*/ctags


cd /opt/robertalab
rm -rf DockerInstallation
./ora.sh --export /opt/robertalab/DockerInstallation

yes yes | ./ora.sh --createEmptydb
cp -r OpenRobertaParent/OpenRobertaServer/db-$VERSION DockerInstallation

cp Docker/Dockerfile* Docker/*.sh DockerInstallation

cd /opt/robertalab/DockerInstallation
docker build -t rbudde/openroberta_lab:$VERSION -f DockerfileLab .
docker build --build-arg version=$VERSION -t rbudde/openroberta_db:$VERSION -f DockerfileDb .

docker build -t rbudde/openroberta_upgrade:$VERSION -f DockerfileUpgrade .

docker build -t rbudde/openroberta_embedded:$VERSION -f DockerfileLabEmbedded .
docker build --build-arg version=$VERSION -t rbudde/openroberta_emptydbfortest:$VERSION -f DockerfileDbEmptyForTest .