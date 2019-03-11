#/bin/bash
set -e
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export VERS_OASIS=1.0.1
export VERS_UI=1.0.0-rc1
export VERS_PIWIND=1.0.1

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
      git clone https://github.com/OasisLMF/$GIT_UI.git -b $VERS_UI
  fi 
  
  cd $SCRIPT_DIR
  if [ -d $SCRIPT_DIR/$GIT_API ]; then
      cd $SCRIPT_DIR/$GIT_API
      git fetch && git checkout $VERS_OASIS
  else
      # Git Clone API
      git clone https://github.com/OasisLMF/$GIT_API.git -b $VERS_OASIS
  fi 
  
  cd $SCRIPT_DIR
  if [ -d $SCRIPT_DIR/$GIT_PIWIND ]; then
      cd $SCRIPT_DIR/$GIT_PIWIND
      git fetch && git checkout $VERS_PIWIND
  else
      # Git Clone PiWind
      git clone https://github.com/OasisLMF/$GIT_PIWIND.git -b $VERS_PIWIND
  fi 



# setup and run API
  cd $SCRIPT_DIR/$GIT_API
  export OASIS_MODEL_DATA_DIR=$SCRIPT_DIR/$GIT_PIWIND
  git checkout -- docker-compose.yml
  sed -i "s|:latest|:${VERS_OASIS}|g" docker-compose.yml
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
