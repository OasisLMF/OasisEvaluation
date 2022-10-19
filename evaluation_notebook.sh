#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VERS_WORKER=$(grep -Po  '(?<=VERS_WORKER=)[^;]+' $SCRIPT_DIR/install.sh)

if [ "$(uname -s)" == "Darwin" ]; then
    export ENV_OSX=true
else
    export ENV_OSX=false
fi


# --- Run API eveluation notebook ------------------------------------------- #

cd $SCRIPT_DIR
git checkout -- api_evaluation_notebook/Dockerfile.ApiEvaluationNotebook

#### Run seds for OSX / Linux
if $ENV_OSX; then
    sed -i "" "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}-debian|g" api_evaluation_notebook/Dockerfile.ApiEvaluationNotebook
else
    sed -i "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}-debian|g" api_evaluation_notebook/Dockerfile.ApiEvaluationNotebook
fi

docker-compose -f api_evaluation_notebook/docker-compose.api_evaluation_notebook.yml build
docker-compose -f api_evaluation_notebook/docker-compose.api_evaluation_notebook.yml up -d
