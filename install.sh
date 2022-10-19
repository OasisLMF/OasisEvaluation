#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$(uname -s)" == "Darwin" ]; then
    export ENV_OSX=true
else
    export ENV_OSX=false
fi


export VERS_MDK=1.26.3
export VERS_API=1.26.3
export VERS_WORKER=1.26.3
export VERS_PIWIND=1.26.3
export VERS_UI=1.11.4
GIT_PIWIND=OasisPiWind
API_CLIENT_DEMO='false'

MSG=$(cat <<-END
Do you want to reinstall?
Note: This will wipe uploaded exposure and run data from the local API.
END
)


# Check for prev install and offer to clean wipe
if [ $(docker volume ls | grep OasisData -c) -gt 1 ]; then
    while true; do read -r -n 1 -p "${MSG:-Continue?} [y/n]: " REPLY
        case $REPLY in
          [yY]) echo ; WIPE=1; break ;;
          [nN]) echo ; WIPE=0; break ;;
          *) printf " \033[31m %s \n\033[0m" "invalid input"
        esac
    done

    # stop oasisui_proxy if running 
    docker-compose -f oasis-ui-proxy.yml down

    if [[ "$WIPE" == 1 ]]; then
        set +e
        docker-compose -f oasis-platform.yml -f oasis-ui-standalone.yml down
        set -e
        printf "Deleting docker data: \n"
        rm -rf $SCRIPT_DIR/$GIT_PIWIND
        docker volume ls | grep OasisData | awk 'BEGIN { FS = "[ \t\n]+" }{ print $2 }' | xargs -r docker volume rm
    else 
        echo "-- Reinstall aborted -- "
        exit 1
        

    fi
fi


# --- Clone PiWind ---------------------------------------------------------- #

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



# --- RUN Oasis Platform & UI ----------------------------------------------- #

cd $SCRIPT_DIR
git checkout -- oasis-platform.yml
git checkout -- oasis-ui-standalone.yml

# Run seds for OSX / Linux
if $ENV_OSX; then
    sed -i "" "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}|g" oasis-platform.yml
    sed -i "" "s|:latest|:${VERS_API}|g" oasis-platform.yml
    sed -i "" "s|:latest|:${VERS_UI}|g" oasis-ui-standalone.yml
else
    sed -i "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}|g" oasis-platform.yml
    sed -i "s|:latest|:${VERS_API}|g" oasis-platform.yml
    sed -i "s|:latest|:${VERS_UI}|g" oasis-ui-standalone.yml
fi

set +e
docker-compose -f oasis-platform.yml pull
docker network create shiny-net

# Workaround for older docker-compose
docker pull coreoasis/model_worker:${VERS_WORKER}
docker pull coreoasis/api_server:${VERS_API}
docker pull coreoasis/oasisui_app:$VERS_UI
#docker pull coreoasis/oasisui_proxy:$VERS_UI
set -e

# RUN OasisPlatform / OasisUI / Portainer
docker-compose -f $SCRIPT_DIR/oasis-platform.yml -f $SCRIPT_DIR/oasis-ui-standalone.yml up -d --no-build
docker-compose -f $SCRIPT_DIR/portainer.yaml up -d


## --- Run API eveluation notebook ------------------------------------------- #
#
#cd $SCRIPT_DIR
#git checkout -- api_evaluation_notebook/Dockerfile.ApiEvaluationNotebook
#
##### Run seds for OSX / Linux
#if $ENV_OSX; then
#    sed -i "" "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}-debian|g" api_evaluation_notebook/Dockerfile.ApiEvaluationNotebook
#else
#    sed -i "s|coreoasis/model_worker:latest|coreoasis/model_worker:${VERS_WORKER}-debian|g" api_evaluation_notebook/Dockerfile.ApiEvaluationNotebook
#fi
#
#docker-compose -f api_evaluation_notebook/docker-compose.api_evaluation_notebook.yml build
#docker-compose -f api_evaluation_notebook/docker-compose.api_evaluation_notebook.yml up -d
