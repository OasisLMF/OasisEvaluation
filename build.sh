#!/bin/bash

set -x

ODS_BRANCH='feature/v4_integration'
LMF_BRANCH='feature/oed_v4'
IMG_TAG='oed-4-dev'

if [ ! -z $ODS_BRANCH ]; then
    BUILD_ARGS_WORKER="${BUILD_ARGS_WORKER} --build-arg ods_tools_branch=${ODS_BRANCH}"
    BUILD_ARGS_SERVER="${BUILD_ARGS_SERVER} --build-arg ods_tools_branch=${ODS_BRANCH}"
fi

if [ ! -z $LMF_BRANCH ]; then
    BUILD_ARGS_WORKER="${BUILD_ARGS_WORKER} --build-arg oasislmf_branch=${LMF_BRANCH}"
fi

docker build -f Dockerfile.oed-4_worker $BUILD_ARGS_WORKER -t coreoasis/model_worker:$IMG_TAG .
docker build -f Dockerfile.oed-4_server $BUILD_ARGS_SERVER -t coreoasis/api_server:$IMG_TAG .
