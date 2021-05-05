FROM alpine
RUN apk add --no-cache bash gawk sed grep bc coreutils
COPY workshop-files /build
COPY workshop-instructions /build/workshop
WORKDIR /build
RUN tar -czf workshop.tar.gz .

FROM nginxinc/nginx-unprivileged:1.19-alpine
ARG   IMAGE_SOURCE
LABEL org.opencontainers.image.source $IMAGE_SOURCE
WORKDIR /usr/share/nginx/html
COPY --from=0 /build /usr/share/nginx/html
COPY ./deploy/platform/educates/base/workshop-deploy.yaml /home/eduk8s/resources/workshop.yaml