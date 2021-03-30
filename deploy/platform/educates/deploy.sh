#!/bin/bash

export EDUCATES_VERSION="master"
export DEFAULT_CLUSTER_NAME="workshop"
export WORKSHOP_NAME="${2:-$WORKSHOP_NAME}"

DIR=$(dirname $0)

installEducates() {
    if kubectl get trainingportals.training.eduk8s.io; then
        kubectl delete trainingportals.training.eduk8s.io ${WORKSHOP_NAME} || true
        kubectl delete workshops.training.eduk8s.io ${WORKSHOP_NAME} || true
    else
        echo "===== Installing educates"
        kubectl apply -k "github.com/eduk8s/eduk8s?ref=$EDUCATES_VERSION"
        IPADDRESS="$(ifconfig | grep 'broadcast\|Bcast' | awk -F ' ' {'print $2'} | head -n 1 | sed -e 's/addr://g')"
        if [ -z "$IPADDRESS" ]
        then
            IPADDRESS="$(hostname -I |grep -oE '((1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])\.){3}(1?[0-9][0-9]?|2[0-4][0-9]|25[0-5])' |head -n 1)" # workaround if ifconfig is not installed on recent versions of Debian
        fi

        echo "===== Setting Ingress Domain to ${IPADDRESS}.nip.io"
        kubectl set env deployment/eduk8s-operator -n eduk8s INGRESS_DOMAIN="${IPADDRESS}.nip.io"
    fi
}

loadWorkshop() {
    echo "===== Installing the workshop and training portal"
    kubectl apply -f $DIR

    echo "===== Waiting for Trainging Portal to be Running"
    while true; do
        if [[ `kubectl get trainingportals.training.eduk8s.io --no-headers | grep ${WORKSHOP_NAME}` =~ "Running" ]]
        then
            echo ""
            echo "===== Training Portal is now running"
            break
        fi
        echo -n "."
        sleep 3
    done

    echo "===== Waiting for files server to be ready"
    while true; do
        if [[ `kubectl get pod --namespace=${WORKSHOP_NAME}-w01 -l deployment=files --no-headers` =~ "Running" ]]
        then
            echo ""
            echo "===== Files server is now ready"
            kubectl get pod --namespace=${WORKSHOP_NAME}-w01 -l deployment=files
            break
        fi
        echo -n "."
        sleep 3
    done
}

loadContent() {
    WORKSHOP_FILES_POD=`kubectl get pod --namespace=${WORKSHOP_NAME}-w01 -l deployment=files --no-headers -o=custom-columns=':metadata.name'`
    echo "===== Copying tarball to files server"
    # TODO - figure out to get the copy commond to copy the entire directory contents without making "build" or "html" directory
    kubectl cp --namespace="${WORKSHOP_NAME}-w01" "${DIR}/../../../build/workshop.tar.gz" "${WORKSHOP_FILES_POD}:/usr/share/nginx/html/"
    kubectl exec --namespace="${WORKSHOP_NAME}-w01" "${WORKSHOP_FILES_POD}" -- ls -lah /usr/share/nginx/html
    kubectl get trainingportals.training.eduk8s.io
}

"$@"