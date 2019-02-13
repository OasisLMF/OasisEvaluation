#/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
GIT_UI=OasisUI
GIT_API=OasisPlatform
GIT_PIWIND=OasisPiWind
BRANCH_UI=develop
BRANCH_API=beta-release/1.0.0
BRANCH_PIWIND=master

# Git Clone
git clone --depth 1 https://github.com/OasisLMF/$GIT_UI.git -b $BRANCH_UI
git clone --depth 1 https://github.com/OasisLMF/$GIT_API.git -b $BRANCH_API
git clone --depth 1 https://github.com/OasisLMF/$GIT_PIWIND.git -b $BRANCH_PIWIND

# Run Oasis API
export export OASIS_MODEL_DATA_DIR=$SCRIPT_DIR/$GIT_PIWIND
docker-compose -f $SCRIPT_DIR/$GIT_API/docker-compose.yml up -d

# Run Oasis UI
docker network create shiny-net
docker-compose -f $SCRIPT_DIR/$GIT_UI/docker-compose.yml up -d
