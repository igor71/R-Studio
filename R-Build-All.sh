#!/usr/bin/env bash
EXTRA_FLAGS="--no-cache"

R_VER=0.0
RSTUDIO_VER=0.0

docker build $EXTRA_FLAGS -f Dockerfile.r-ver -t yi/r-base:${R_VER} . && \
docker build $EXTRA_FLAGS -f Dockerfile.r-studio -t yi/r-studio:${RSTUDIO_VER} . 
