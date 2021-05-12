FROM quay.io/eduk8s/jdk11-environment:210217.091829.d9293c8
RUN echo "Update to bust cache: 2021-05-04 04:30 PM" && \
    git clone -b 1.0 https://github.com/springone-tour-2021/color-app.git app && \
      cd app/blueorgreenservice && ./mvnw dependency:go-offline && \
      cd ../blueorgreenfrontend && ./mvnw dependency:go-offline && \
      cd ../blueorgreengateway && ./mvnw dependency:go-offline && \
      cd ../authgateway && ./mvnw dependency:go-offline && \
      cd ../.. && \
    rm -rf app
