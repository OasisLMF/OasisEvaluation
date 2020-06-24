#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export VERS_MDK=1.8.3
export VERS_API=1.8.3
export VERS_WORKER=1.8.3
export VERS_PIWIND=1.8.3
export VERS_UI=1.7.0
GIT_UI=OasisUI
GIT_API=OasisPlatform
GIT_PIWIND=OasisPiWind


# ---  OASIS UI --- # 
if [ -d $SCRIPT_DIR/$GIT_UI ]; then
    cd $SCRIPT_DIR/$GIT_UI
    git stash
    git fetch && git checkout $VERS_UI
else
    mkdir -p $SCRIPT_DIR/$GIT_UI
    cd $SCRIPT_DIR/$GIT_UI
    git clone https://github.com/OasisLMF/$GIT_UI.git .
    git checkout $VERS_UI
fi 

# ---  OASIS API --- # 
if [ -d $SCRIPT_DIR/$GIT_API ]; then
    cd $SCRIPT_DIR/$GIT_API
    git stash
    git fetch && git checkout $VERS_API
else
    mkdir -p $SCRIPT_DIR/$GIT_API
    cd $SCRIPT_DIR/$GIT_API
    git clone https://github.com/OasisLMF/$GIT_API.git .
    git checkout $VERS_API
fi 

# ---  MODEL PiWind --- # 
if [ -d $SCRIPT_DIR/$GIT_PIWIND ]; then
    cd $SCRIPT_DIR/$GIT_PIWIND
    git stash
    git fetch && git checkout $VERS_PIWIND
else
    mkdir -p $SCRIPT_DIR/$GIT_PIWIND
    cd $SCRIPT_DIR/$GIT_PIWIND
    git clone https://github.com/OasisLMF/$GIT_PIWIND.git .
    git checkout $VERS_PIWIND
fi 



# setup and run API
cd $SCRIPT_DIR/$GIT_API
export OASIS_MODEL_DATA_DIR=$SCRIPT_DIR/$GIT_PIWIND
git checkout -- docker-compose.yml
sed -i "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}|g" docker-compose.yml
sed -i "s|:latest|:${VERS_API}|g" docker-compose.yml

set +e
docker-compose down
docker-compose pull
set -e
docker-compose up -d --no-build

# Run Oasis UI
cd $SCRIPT_DIR/$GIT_UI
git checkout -- docker-compose.yml
sed -i "s|:latest|:${VERS_UI}|g" docker-compose.yml
set +e
docker network create shiny-net
set -e
docker pull coreoasis/oasisui_app:$VERS_UI
docker-compose -f $SCRIPT_DIR/$GIT_UI/docker-compose.yml up -d

# Run API eveluation notebook
cd $SCRIPT_DIR

sed -i "s|^oasislmf.*|oasislmf==$VERS_MDK|g" api_evaluation_notebook/requirements.txt
docker-compose -f api_evaluation_notebook/docker-compose.api_evaluation_notebook.yml build
docker-compose -f api_evaluation_notebook/docker-compose.api_evaluation_notebook.yml up -d
