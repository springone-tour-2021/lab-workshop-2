##!/bin/bash
#
## Pull images for Dockerfile build
#docker pull adoptopenjdk:11-jdk-hotspot
#docker pull adoptopenjdk:11-jre-hotspot
#
## Pull images for pack build
docker pull paketobuildpacks/builder:base
docker pull paketobuildpacks/run:base-cnb
