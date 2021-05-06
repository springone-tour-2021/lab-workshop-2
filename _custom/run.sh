#!/bin/bash

# The image created by running this script is used in:
# <REPO_ROOT>/deploy/platform/educates/workshop-deploy.yaml

# For DockerHub:
#REGISTRY=docker.io
#PROJECT=ciberkleid
#USER=ciberkleid

# For Distribution Harbor:
REGISTRY=projects.registry.vmware.com
PROJECT=springonetour
USER=ciberkleid

# docker login $REGISTRY -u $USER

# Build, tag, and push image

docker build . -t eduk8s-s1t2021-wkshp2-env
docker tag eduk8s-s1t2021-wkshp2-env $REGISTRY/$PROJECT/eduk8s-s1t2021-wkshp2-env
docker push $REGISTRY/$PROJECT/eduk8s-s1t2021-wkshp2-env
