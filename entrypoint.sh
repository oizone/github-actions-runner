#!/bin/bash

export RUNNER_ALLOW_RUNASROOT=1
export PATH=$PATH:/actions-runner

deregister_runner() {
  echo "Caught SIGTERM. Deregistering runner"
  RUNNER_TOKEN=`curl -X POST -H "Accept: ${ACCEPT}" https://${USER}:${TOKEN}@api.github.com/repos/${REPO}/actions/runners/registration-token|grep token|cut -d'"' -f 4`
  ./config.sh remove --token "${RUNNER_TOKEN}"
  exit
}

ACCEPT="application/vnd.github.v3+json"


RUNNER_TOKEN=`curl -X POST -H "Accept: ${ACCEPT}" https://${USER}:${TOKEN}@api.github.com/repos/${REPO}/actions/runners/registration-token|grep token|cut -d'"' -f 4`

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

