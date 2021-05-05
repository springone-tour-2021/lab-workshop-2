#!/bin/bash

export EDUCATES_VERSION="develop"
export DEFAULT_CLUSTER_NAME="CHANGEME"
export DEFAULT_ENVIRONMENT="base"
export WORKSHOP_NAME="${2:-$WORKSHOP_NAME}"
export ENVIRONMENT="${3:-$DEFAULT_ENVIRONMENT}"
export CLUSTER_NAME="${WORKSHOP_NAME}"

DIR=$(dirname $0)

installEducates() {
    if kubectl get trainingportals.training.eduk8s.io; then
        kubectl delete trainingportals.training.eduk8s.io ${WORKSHOP_NAME} || true
        kubectl delete workshops.training.eduk8s.io ${WORKSHOP_NAME} || true
    else
        EDUCATES_YAML_ORIGINAL=$(kubectl kustomize github.com/eduk8s/eduk8s?ref=${EDUCATES_VERSION})
        EDUCATES_OPERATOR_IMAGE=$(echo "${EDUCATES_YAML_ORIGINAL}" | grep eduk8s-operator: | awk '{print $2}')
        EDUCATES_PORTAL_IMAGE=$(echo "${EDUCATES_YAML_ORIGINAL}" | grep eduk8s-portal: | awk '{print $2}' | sed s/'$(image_repository)'/"quay.io\\/eduk8s"/g)
        EDUCATES_WORKSHOP_BASE_IMAGE=$(echo "${EDUCATES_YAML_ORIGINAL}" | grep base-environment: | awk '{print $2}' | sed s/'$(image_repository)'/"quay.io\\/eduk8s"/g)

        echo "===== Pulling Educates images to cache"
        docker pull "${EDUCATES_OPERATOR_IMAGE}"
        docker pull "${EDUCATES_PORTAL_IMAGE}"
        docker pull "${EDUCATES_WORKSHOP_BASE_IMAGE}"

        echo "===== Pushing Educates images into local registry to avoid re-download"
        docker tag "${EDUCATES_OPERATOR_IMAGE}" $(echo "${EDUCATES_OPERATOR_IMAGE}" | sed s/"quay.io"/"localhost:5000"/g)
        docker push $(echo "${EDUCATES_OPERATOR_IMAGE}" | sed s/"quay.io"/"localhost:5000"/g)
        docker tag "${EDUCATES_PORTAL_IMAGE}" $(echo "${EDUCATES_PORTAL_IMAGE}" | sed s/"quay.io"/"localhost:5000"/g)
        docker push $(echo "${EDUCATES_PORTAL_IMAGE}" | sed s/"quay.io"/"localhost:5000"/g)
        docker tag "${EDUCATES_WORKSHOP_BASE_IMAGE}" $(echo "${EDUCATES_WORKSHOP_BASE_IMAGE}" | sed s/"quay.io"/"localhost:5000"/g)
        docker push $(echo "${EDUCATES_WORKSHOP_BASE_IMAGE}" | sed s/"quay.io"/"localhost:5000"/g)

        echo "===== Installing educates"
        echo "${EDUCATES_YAML_ORIGINAL}" | sed s/'quay.io'/'localhost:5000'/g | kubectl apply -f -
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
    declare -i kubectl_version=$(kubectl version --client | sed s/.*Minor:\"// | sed s/\".*//)
	if [ $kubectl_version -lt 21 ]; then
        echo "===== Installed kubectl version is too old, please install version v1.21 or newer"
        exit -1
    fi

    echo "===== Loading workshop image into cluster"
    docker tag ${WORKSHOP_NAME} localhost:5000/${WORKSHOP_NAME}
    docker push localhost:5000/${WORKSHOP_NAME}

    echo "===== Installing the workshop and training portal"
    kubectl apply -k $DIR/$ENVIRONMENT

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
    echo "===== Run \"update-workshop\" in the workshop terminal to see the updates"
}

"$@"