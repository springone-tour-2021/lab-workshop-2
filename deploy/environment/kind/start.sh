#!/bin/bash

export DEFAULT_CLUSTER_NAME="workshop"
export CLUSTER_NAME="${1:-$DEFAULT_CLUSTER_NAME}"
DIR=$(dirname $0)

echo "===== Cleaning up any old clusters"
kind delete cluster --name "${CLUSTER_NAME}" > /dev/null 2>&1 || true

echo "===== Creating cluster"
kind create cluster --name "${CLUSTER_NAME}" --config $DIR/kind-config.yaml

echo "===== Loading workshop image into cluster"
kind load docker-image --name "${CLUSTER_NAME}" "${CLUSTER_NAME}"

echo "===== Installing Ingress Controller"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
sleep 10
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=-1s