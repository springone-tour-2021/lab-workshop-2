#!/bin/bash

start_dir=$(PWD)
temp_dir=temp-m2-repo

mkdir -p $temp_dir
cd $temp_dir

# Download libraries for Color Application apps
git clone https://github.com/springone-tour-2021/gateway-s1p-2018.git color-app
cd color-app
# Generate a Eureka server app
curl https://start.spring.io/starter.tgz \
            -d dependencies=cloud-eureka-server \
            -d name=eureka \
            -d artifactId=eureka \
            -d baseDir=eureka | tar -xzvf -

# Download maven dependencies concurrently
cd blueorgreenservice && ./mvnw dependency:go-offline &
cd blueorgreenfrontend && ./mvnw dependency:go-offline &
cd blueorgreengateway && ./mvnw dependency:go-offline &
cd authgateway && ./mvnw dependency:go-offline &
cd eureka && ./mvnw dependency:go-offline &

# Wait for all commands to finish
wait

# Cleanup
cd $start_dir
rm -rf $temp_dir
