#!/bin/bash

rm -rf ./agent/*
ssh-keygen -b 2048 -t rsa -f ./agent/is_rsa -q -N ""

PULL_SECRET=$(cat ./secrets/pull-secret.txt)
SSH_KEY=$(cat ./agent/is_rsa.pub)

envsubst < ./templates/install-config.yaml.template > ./agent/install-config.yaml
cp ./templates/agent-config.yaml ./agent/

openshift-install --dir ./agent/ agent create image