FROM quay.io/eduk8s/jdk11-environment:210217.091829.d9293c8
RUN echo "Update to bust cache: 2021-05-04 04:30 PM" && \
    git clone https://github.com/springone-tour-2021/gateway-s1p-2018.git app && \
      cd app/blueorgreenservice && ./mvnw dependency:go-offline && \
      cd ../blueorgreenfrontend && ./mvnw dependency:go-offline && \
      cd ../blueorgreengateway && ./mvnw dependency:go-offline && \
      cd ../authgateway && ./mvnw dependency:go-offline && \
      cd ../eurekaserver && ./mvnw dependency:go-offline && \
      cd ../configserver && ./mvnw dependency:go-offline && \
      cd ../.. && \
    rm -rf app
