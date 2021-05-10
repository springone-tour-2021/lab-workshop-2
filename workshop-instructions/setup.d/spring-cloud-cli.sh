#!/bin/bash
# Install Spring Cloud CLI
# Note: Assumes Spring Boot CLI already present. See:
#     workshop-files/bin/spring
#     and
#     workshop-files/lib/spring-boot-cli.jar

VERSION=3.0.2
#curl https://codeload.github.com/spring-cloud/spring-cloud-cli/zip/refs/tags/v$VERSION -o spring-cloud-cli.zip
#unzip spring-cloud-cli.zip
#cd spring-cloud-cli-$VERSION
##./mvnw install -DskipTests
#./mvnw -T 1C install -Dmaven.test.skip -DskipTests -Dmaven.javadoc.skip=true
spring install org.springframework.cloud:spring-cloud-cli:$VERSION
#cd ..
#rm -rf spring-cloud-cli-$VERSION
#rm spring-cloud-cli.zip
