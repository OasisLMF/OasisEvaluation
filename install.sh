#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export VERS_API=1.0.1
export VERS_WORKER=1.0.2-rc2
export VERS_UI=1.0.0-rc1
export VERS_PIWIND=ab206f849f42d46bfd58daf8bfee847654d7c33c
GIT_UI=OasisUI
GIT_API=OasisPlatform
GIT_PIWIND=OasisPiWind


# Clone and update repos 
cd $SCRIPT_DIR
if [ -d $SCRIPT_DIR/$GIT_UI ]; then
    cd $SCRIPT_DIR/$GIT_UI
    git fetch && git checkout $VERS_UI
else
    # Git Clone UI
    git clone https://github.com/OasisLMF/$GIT_UI.git 
    git checkout -b $VERS_UI
fi 

cd $SCRIPT_DIR
if [ -d $SCRIPT_DIR/$GIT_API ]; then
    cd $SCRIPT_DIR/$GIT_API
    git fetch && git checkout $VERS_API
else
    # Git Clone API
    git clone https://github.com/OasisLMF/$GIT_API.git 
    git checkout -b $VERS_API
fi 

cd $SCRIPT_DIR
if [ -d $SCRIPT_DIR/$GIT_PIWIND ]; then
    cd $SCRIPT_DIR/$GIT_PIWIND
    git fetch && git checkout $VERS_PIWIND
else
    # Git Clone PiWind
    git clone https://github.com/OasisLMF/$GIT_PIWIND.git 
    git checkout -b $VERS_PIWIND
fi 


# setup and run API
cd $SCRIPT_DIR/$GIT_API
export OASIS_MODEL_DATA_DIR=$SCRIPT_DIR/$GIT_PIWIND
git checkout -- docker-compose.yml
sed -i "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}|g" docker-compose.yml
sed -i "s|:latest|:${VERS_API}|g" docker-compose.yml
docker-compose up -d

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
docker-compose -f api_evaluation_notebook/docker-compose.api_evaluation_notebook.yml build
docker-compose -f api_evaluation_notebook/docker-compose.api_evaluation_notebook.yml up -d
