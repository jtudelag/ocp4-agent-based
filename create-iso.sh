#!/bin/bash

set -x

AGENT_CONFIG_FILE="agent-config.yaml"
#AGENT_CONFIG_FILE="agent-config-one-nic.yaml"


rm -rf ./agent/*

# Hidden files, but .gitkeep
rm -rf ./agent/.openshift_install.log
rm -rf ./agent/.openshift_install_state.json

ssh-keygen -b 2048 -t rsa -f ./agent/is_rsa -q -N ""

export PULL_SECRET=$(cat ./secrets/pull-secret.txt)
export SSH_KEY=$(cat ./agent/is_rsa.pub)

envsubst < ./templates/install-config.yaml.template > ./agent/install-config.yaml
cp "./templates/${AGENT_CONFIG_FILE}" ./agent/agent-config.yaml
cp "./templates/partition.yaml" ./agent/partition.yaml

TIMESTAMP=$(date +"%Y-%m-%d_%H:%M:%S")
mkdir "logs/$TIMESTAMP"

cp ./agent/install-config.yaml "logs/$TIMESTAMP/"
cp ./agent/agent-config.yaml "logs/$TIMESTAMP/"

openshift-install --dir ./agent/ agent create image