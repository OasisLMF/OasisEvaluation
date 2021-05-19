#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$(uname -s)" == "Darwin" ]; then
    export ENV_OSX=true
    echo "debug check - running on OSX"
else
    export ENV_OSX=false
fi


export VERS_MDK=1.16.0
export VERS_API=1.16.0
export VERS_WORKER=1.16.0
export VERS_PIWIND=1.16.0
export VERS_UI=1.9.0
GIT_UI=OasisUI
GIT_PIWIND=OasisPiWind
#GIT_API=OasisPlatform

MSG=$(cat <<-END
Do you want to install from a clean state, this is recomended when updating the release version.
Note: This will wipe uploaded exposure and run data from the local API.
END
)


## Check for prev install and offer to clean wipe
#if [ -d $SCRIPT_DIR/$GIT_UI -o -d $SCRIPT_DIR/$GIT_API -o -d $SCRIPT_DIR/$GIT_PIWIND ]; then
#    while true; do read -r -n 1 -p "${MSG:-Continue?} [y/n]: " REPLY
#        case $REPLY in
#          [yY]) echo ; WIPE=1; break ;;
#          [nN]) echo ; WIPE=0; break ;;
#          *) printf " \033[31m %s \n\033[0m" "invalid input"
#        esac
#    done
#
#    if [[ "$WIPE" == 1 ]]; then
#        printf "Deleting: \n\t$SCRIPT_DIR/$GIT_API \n\t$SCRIPT_DIR/$GIT_UI \n\t$SCRIPT_DIR/$GIT_PIWIND\n"
#        sudo rm -rf $SCRIPT_DIR/$GIT_API $SCRIPT_DIR/$GIT_UI $SCRIPT_DIR/$GIT_PIWIND
#    fi
#
#fi

# ---  OASIS UI --- #
if [ -d $SCRIPT_DIR/$GIT_UI ]; then
    cd $SCRIPT_DIR/$GIT_UI
    git stash
    git fetch && git checkout $VERS_UI
else
    mkdir -p $SCRIPT_DIR/$GIT_UI
    cd $SCRIPT_DIR/$GIT_UI
    git clone --depth 1 --branch $VERS_UI https://github.com/OasisLMF/$GIT_UI.git .
    git checkout $VERS_UI
fi

## ---  OASIS API --- #
#if [ -d $SCRIPT_DIR/$GIT_API ]; then
#    cd $SCRIPT_DIR/$GIT_API
#    git stash
#    git fetch && git checkout $VERS_API
#else
#    mkdir -p $SCRIPT_DIR/$GIT_API
#    cd $SCRIPT_DIR/$GIT_API
#    git clone --depth 1 --branch $VERS_API https://github.com/OasisLMF/$GIT_API.git .
#    git checkout $VERS_API
#fi

# ---  MODEL PiWind --- #
if [ -d $SCRIPT_DIR/$GIT_PIWIND ]; then
    cd $SCRIPT_DIR/$GIT_PIWIND
    git stash
    git fetch && git checkout $VERS_PIWIND
else
    mkdir -p $SCRIPT_DIR/$GIT_PIWIND
    cd $SCRIPT_DIR/$GIT_PIWIND
    git clone --depth 1 --branch $VERS_PIWIND https://github.com/OasisLMF/$GIT_PIWIND.git .
    git checkout $VERS_PIWIND
fi


## setup and run API
#cd $SCRIPT_DIR/$GIT_API
#export OASIS_MODEL_DATA_DIR=$SCRIPT_DIR/$GIT_PIWIND
#git checkout -- docker-compose.yml
#sed -i "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}|g" docker-compose.yml
#sed -i "s|:latest|:${VERS_API}|g" docker-compose.yml

# setup and run API
cd $SCRIPT_DIR
git checkout -- oasis-platform.yml

# Run seds for OSX / Linux 
if $ENV_OSX; then 
    sed -i "" "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}|g" oasis-platform.yml
    sed -i "" "s|:latest|:${VERS_API}|g" oasis-platform.yml
else 
    sed -i "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}|g" oasis-platform.yml
    sed -i "s|:latest|:${VERS_API}|g" oasis-platform.yml
fi     


set +e
docker-compose -f oasis-platform.yml down
docker-compose -f oasis-platform.yml pull

# Workaround for older docker-compose 
docker pull coreoasis/model_worker:${VERS_WORKER}
docker pull coreoasis/api_server:${VERS_API}
set -e
docker-compose -f oasis-platform.yml up -d --no-build

# Run Oasis UI
cd $SCRIPT_DIR/$GIT_UI
git checkout -- docker-compose.yml


## Run seds for OSX / Linux 
if $ENV_OSX; then 
    sed -i "" "s|:latest|:${VERS_UI}|g" docker-compose.yml
else
    sed -i "s|:latest|:${VERS_UI}|g" docker-compose.yml
fi 

set +e
docker network create shiny-net
set -e
docker pull coreoasis/oasisui_app:$VERS_UI
docker-compose -f $SCRIPT_DIR/$GIT_UI/docker-compose.yml up -d

# Run API eveluation notebook
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

# Run Portainer 
docker-compose -f portainer.yaml up -d
