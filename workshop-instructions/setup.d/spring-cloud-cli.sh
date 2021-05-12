#!/bin/bash
# Install Spring Cloud CLI
# Note: Assumes Spring Boot CLI already present. See:
#     workshop-files/bin/spring
#     and
#     workshop-files/lib/spring-boot-cli.jar

VERSION=3.0.2
spring install org.springframework.cloud:spring-cloud-cli:$VERSION
