#!/bin/bash

export DEFAULT_CLUSTER_NAME="workshop"
export CLUSTER_NAME="${1:-$DEFAULT_CLUSTER_NAME}"
DIR=$(dirname $0)

kind delete cluster --name "${CLUSTER_NAME}"