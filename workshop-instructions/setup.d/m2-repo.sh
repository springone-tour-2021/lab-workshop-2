##!/bin/bash
#
#start_dir=$(PWD)
#temp_dir=temp-m2-repo
#
#mkdir -p $temp_dir
#cd $temp_dir
#
## Download libraries for Color Application apps
#git clone https://github.com/springone-tour-2021/color-app.git app
#git checkout tags/1.0
#
## Download maven dependencies
#cd app/blueorgreenservice && ./mvnw dependency:go-offline
#cd ../blueorgreenfrontend && ./mvnw dependency:go-offline
#cd ../blueorgreengateway && ./mvnw dependency:go-offline
#cd ../authgateway && ./mvnw dependency:go-offline
#cd ../eurekaserver && ./mvnw dependency:go-offline
#cd ../configserver && ./mvnw dependency:go-offline
#
## Cleanup
#cd $start_dir
#rm -rf $temp_dir
