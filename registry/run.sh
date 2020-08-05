#!/bin/bash

docker run -d -p 5000:5000 \
    --restart=always \
    --name registry-swift \
    -v $PWD/config.yml:/etc/docker/registry/config.yml \
    registry:latest
