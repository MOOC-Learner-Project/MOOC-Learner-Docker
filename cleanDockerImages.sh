#! /bin/bash

for DOCKER_IMAGE in "curated" "quantified" "visualized" "modeled"; do
    echo "Cleaning MOOC-Learner-${DOCKER_IMAGE} image";
    docker rmi ${DOCKER_IMAGE}:base
done;

