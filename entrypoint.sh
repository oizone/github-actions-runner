#!/bin/bash

export RUNNER_ALLOW_RUNASROOT=1
export PATH=$PATH:/actions-runner
API_VERSION=v3
API_HEADER="Accept: application/vnd.github.${API_VERSION}+json"
AUTH_HEADER="Authorization: token ${TOKEN}"

deregister_runner() {
    echo "Caught SIGTERM. Deregistering runner"
    RUNNER_TOKEN=`curl -X POST -H "${API_HEADER}" -H "${AUTH_HEADER}" https://api.github.com/repos/${REPO}/actions/runners/registration-token|jq -r '.token'`
    ./config.sh remove --token "${RUNNER_TOKEN}"
    exit
}

RUNNER_TOKEN=`curl -X POST -H "${API_HEADER}" -H "${AUTH_HEADER}" https://api.github.com/repos/${REPO}/actions/runners/registration-token|jq -r '.token'`

REPO_URL="https://github.com/{REPO}"

echo "Configuring"
./config.sh \
    --url "${REPO_URL}" \
    --token "${RUNNER_TOKEN}" \
    --name "${RUNNER_NAME}" \
    --labels "${RUNNER_LABELS}" \
    --unattended \
    --replace

unset RUNNER_TOKEN
trap deregister_runner SIGINT SIGQUIT SIGTERM

./bin/runsvc.sh

