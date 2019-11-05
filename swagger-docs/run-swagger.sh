#!/bin/bash
# https://github.com/swagger-api/swagger-ui/blob/master/docs/usage/installation.md
# https://hub.docker.com/r/swaggerapi/swagger-ui/tags

API_VER="1.3.2"
API_URL="https://github.com/OasisLMF/OasisPlatform/releases/download/$API_VER/openapi-schema-$API_VER.json"

export SWAGGER_SCHEMA="oasis-api-schema.json"
export SWAGGER_IMAGE="swaggerapi/swagger-ui"
export SWAGGER_TAG="v3.24.2"

wget $API_URL -O $SWAGGER_SCHEMA
docker-compose up -d
