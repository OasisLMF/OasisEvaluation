#!/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ "$(uname -s)" == "Darwin" ]; then
    export ENV_OSX=true
else
    export ENV_OSX=false
fi


export VERS_MDK=1.27.1
export VERS_API=1.27.1
export VERS_WORKER=1.27.1
export VERS_PIWIND='backports/1.27.x'
export VERS_UI=1.11.6
GIT_PIWIND=OasisPiWind

MSG=$(cat <<-END
Do you want to reinstall?
Note: This will wipe uploaded exposure and run data from the local API.
END
)


# Check for prev install and offer to clean wipe
if [[ $(docker volume ls | grep OasisData -c) -gt 1 || -d $SCRIPT_DIR/$GIT_PIWIND ]]; then
    while true; do read -r -n 1 -p "${MSG:-Continue?} [y/n]: " REPLY
        case $REPLY in
          [yY]) echo ; WIPE=1; break ;;
          [nN]) echo ; WIPE=0; break ;;
          *) printf " \033[31m %s \n\033[0m" "invalid input"
        esac
    done

    if [[ "$WIPE" == 1 ]]; then
        # stop oasisui_proxy if running
        docker-compose -f $SCRIPT_DIR/oasis-ui-proxy.yml down --remove-orphans
        docker-compose -f $SCRIPT_DIR/portainer.yaml down --remove-orphans

        set +e
        docker-compose -f $SCRIPT_DIR/oasis-platform.yml -f $SCRIPT_DIR/oasis-ui-standalone.yml down --remove-orphans
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

mkdir -p $SCRIPT_DIR/$GIT_PIWIND
cd $SCRIPT_DIR/$GIT_PIWIND
git clone --depth 1 --branch $VERS_PIWIND https://github.com/OasisLMF/$GIT_PIWIND.git .
git checkout $VERS_PIWIND



# --- RUN Oasis Platform & UI ----------------------------------------------- #

cd $SCRIPT_DIR

# check if this repo was downloaded as zip or cloned
if git rev-parse --git-dir > /dev/null 2>&1; then
    # if git, then reset the compose files
    git checkout -- oasis-platform.yml
    git checkout -- oasis-ui-standalone.yml
else
    # otherwise 'sed' the files to reset version tags
    if $ENV_OSX; then
        sed -i "" "s|coreoasis/api_server:.*|coreoasis/api_server:latest|g" oasis-platform.yml
        sed -i "" "s|coreoasis/model_worker:.*|coreoasis/model_worker:latest|g" oasis-platform.yml
        sed -i "" "s|coreoasis/oasisui_app:.*|coreoasis/oasisui_app:latest|g" oasis-ui-standalone.yml
    else
        sed -i "s|coreoasis/api_server:.*|coreoasis/api_server:latest|g" oasis-platform.yml
        sed -i "s|coreoasis/model_worker:.*|coreoasis/model_worker:latest|g" oasis-platform.yml
        sed -i "s|coreoasis/oasisui_app:.*|coreoasis/oasisui_app:latest|g" oasis-ui-standalone.yml
    fi
fi


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

# Workaround for older docker-compose
docker pull coreoasis/model_worker:${VERS_WORKER}
docker pull coreoasis/api_server:${VERS_API}
docker pull coreoasis/oasisui_app:$VERS_UI
set -e

# RUN OasisPlatform / OasisUI / Portainer
docker-compose -f $SCRIPT_DIR/oasis-platform.yml -f $SCRIPT_DIR/oasis-ui-standalone.yml up -d --no-build
docker-compose -f $SCRIPT_DIR/portainer.yaml up -d
