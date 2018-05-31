#! /bin/bash

# TODO should really not be a bash script.

for DOCKER_IMAGE in "curated" "quantified" "visualized" "modeled"; do
    echo "Building MOOC-Learner-${DOCKER_IMAGE} image";
    cd ./${DOCKER_IMAGE}_base_img;
    docker build -t ${DOCKER_IMAGE}:base .;
    cd ..;
done;

