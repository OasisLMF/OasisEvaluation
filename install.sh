#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# --- Check prerequisites ---------------------------------------------------- #

if ! command -v docker &> /dev/null; then
    printf "\033[31mError: docker is not installed or not on PATH.\033[0m\n"
    exit 1
fi

if ! docker info &> /dev/null; then
    printf "\033[31mError: docker daemon is not running or not accessible.\033[0m\n"
    exit 1
fi

if ! docker compose version &> /dev/null; then
    printf "\033[31mError: docker compose plugin is not available.\033[0m\n"
    exit 1
fi


export VERS_UI=2.0.1
export SERVER_IMG=coreoasis/api_server
export WORKER_IMG=coreoasis/model_worker
export GIT_PIWIND=OasisPiWind

MSG=$(cat <<-END
Do you want to reinstall?
Note: This will wipe uploaded exposure and run data from the local API.
END
)


# Check for prev install and offer to clean wipe
if [[ $(docker volume ls | grep OasisData -c) -gt 1 || -d "$SCRIPT_DIR/$GIT_PIWIND" ]]; then
    while true; do read -r -n 1 -p "${MSG:-Continue?} [y/n]: " REPLY
        case $REPLY in
          [yY]) echo ; WIPE=1; break ;;
          [nN]) echo ; WIPE=0; break ;;
          *) printf " \033[31m %s \n\033[0m" "invalid input"
        esac
    done

    if [[ "$WIPE" == 1 ]]; then
        # stop oasisui_proxy if running
        docker compose -f "$SCRIPT_DIR/oasis-ui-proxy.yml" down --remove-orphans
        docker compose -f "$SCRIPT_DIR/portainer.yaml" down --remove-orphans

        set +e
        docker compose -f "$SCRIPT_DIR/oasis-platform.yml" -f "$SCRIPT_DIR/oasis-ui-standalone.yml" down --remove-orphans
        set -e

        if [[ -z "$SCRIPT_DIR" || -z "$GIT_PIWIND" ]]; then
            printf "\033[31mError: SCRIPT_DIR or GIT_PIWIND is unset; refusing to delete.\033[0m\n"
            exit 1
        else
            printf "Deleting docker data: \n"
            rm -rf "$SCRIPT_DIR/$GIT_PIWIND"
        fi
        docker volume ls | grep OasisData | awk 'BEGIN { FS = "[ \t\n]+" }{ print $2 }' | xargs -r docker volume rm
    else
        echo "-- Reinstall aborted -- "
        exit 1
    fi
fi


# --- Select OasisLMF version ------------------------------------------------ #

set_version() {
    case $1 in
      2.5.x|2.5)
        export VERS_API=2.5
        export VERS_WORKER=2.5
        export VERS_PIWIND='stable/2.5.x'
        return 0
        ;;
      2.4.x|2.4)
        export VERS_API=2.4
        export VERS_WORKER=2.4
        export VERS_PIWIND='stable/2.4.x'
        return 0
        ;;
      *)
        return 1
        ;;
    esac
}

if [[ -n "$1" ]]; then
    if ! set_version "$1"; then
        printf "\033[31m%s\033[0m\n" "invalid version argument '$1', please pass 2.5 or 2.4"
        exit 1
    fi
else
    while true; do read -r -p "Which stable OasisLMF version do you want to install? [ '2.5' or '2.4' ] (default: 2.4 ~ pressing enter): " VERSION_REPLY
        VERSION_REPLY=${VERSION_REPLY:-2.4}
        if set_version "$VERSION_REPLY"; then
            break
        fi
        printf " \033[31m %s \n\033[0m" "invalid input, please enter 2.5 or 2.4"
    done
fi


# --- Clone PiWind ---------------------------------------------------------- #

if [[ -z "$SCRIPT_DIR" || -z "$GIT_PIWIND" ]]; then
    printf "\033[31mError: SCRIPT_DIR or GIT_PIWIND is unset; refusing to delete.\033[0m\n"
    exit 1
else
    rm -rf "$SCRIPT_DIR/$GIT_PIWIND"
fi
mkdir -p "$SCRIPT_DIR/$GIT_PIWIND"
cd "$SCRIPT_DIR/$GIT_PIWIND"
git clone --depth 1 --branch "$VERS_PIWIND" "https://github.com/OasisLMF/$GIT_PIWIND.git" .
git checkout "$VERS_PIWIND"



# --- RUN Oasis Platform & UI ----------------------------------------------- #

cd "$SCRIPT_DIR"

set +e
docker pull "${WORKER_IMG}:${VERS_WORKER}"
docker pull "${SERVER_IMG}:${VERS_API}"
docker pull "coreoasis/oasisui_app:$VERS_UI"
set -e

# RUN OasisPlatform / OasisUI / Portainer
docker compose -f "$SCRIPT_DIR/oasis-platform.yml" -f "$SCRIPT_DIR/oasis-ui-standalone.yml" up -d --no-build
docker compose -f "$SCRIPT_DIR/portainer.yaml" up -d
