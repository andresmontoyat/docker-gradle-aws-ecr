#!/usr/bin/env bash
# @Author: Andres Montoya
# Copyright (c) 2020, codehunters.io

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace

function usage() {
    printf "Print Help options and description"
}

function login() {
    {    
        aws ecr get-login-password --region $AWS_DEFAULT_REGION | docker login --username AWS --password-stdin $AWSEB_DOCKER_REGISTRY
    } || {
        echo "An error occurred while trying to execute docker login command."
        return 1
    }
}

function build() {
    {    
        docker build -t $AWSECR_RELEASE_TAG .
    } || {
        echo "An error occurred while trying to execute docker build."
        return 1
    }
}

function push() {
    {
        docker tag $AWSECR_RELEASE_TAG $AWSEB_DOCKER_REGISTRY/$AWSECR_RELEASE_TAG
        docker push $AWSEB_DOCKER_REGISTRY/$AWSECR_RELEASE_TAG
    } || {
        echo "An error occurred while trying to execute docker push command."
        return 1
    }
}


printf "Starting the AWS ECR deployment container registry\n"

if [[ $# -ne 0 ]]; then
    if ([[ -n "$1" ]]) && [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then 
	    usage && exit 0
    fi
fi 
    
login || { printf "An error occurred while trying to execute docker login command." && exit 1; }
build || { printf "An error occurred while trying to execute docker build.s" && exit 1; }
push || { printf "An error occurred while trying to execute docker push command" && exit 1; }

printf "Success deploy docker registry"
exit 0