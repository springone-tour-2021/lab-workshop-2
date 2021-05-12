#!/bin/bash

# Download maven dependencies for color-app
git clone -b 1.0 https://github.com/springone-tour-2021/color-app.git app-temp
cd app-temp/blueorgreenservice && ./mvnw dependency:go-offline
cd ../blueorgreenfrontend && ./mvnw dependency:go-offline
cd ../blueorgreengateway && ./mvnw dependency:go-offline
cd ../authgateway && ./mvnw dependency:go-offline
cd ../..
rm -rf app-temp
