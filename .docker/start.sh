#!/bin/bash

# TOKEN, personal access token for runner registration process
ACCESS_TOKEN=$TOKEN
# GH_RUNNER_GROUP, github runner group to place runner in
RUNNER_GROUP=$GH_RUNNER_GROUP

#
ORGANISATION=$GH_ORGANISATION

REG_TOKEN=$(curl -X POST -H "Authorization: Bearer ${ACCESS_TOKEN}" \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/orgs/${ORGANISATION}/actions/runners/registration-token" | jq .token --raw-output)


echo $(hostname -s)

cd /home/docker/actions-runner


# Configure the GitHub self-hosted runner
./config.sh --url https://github.com/${ORGANISATION} --token ${REG_TOKEN} --runnergroup ${RUNNER_GROUP} --labels ${RUNNER_GROUP} --replace

# Start a simple HTTP server for ALB health checks
#mkdir -p /tmp/empty-dir
#touch /tmp/empty-dir/index.html
#nohup python3 -m http.server 8080 --bind 0.0.0.0 --directory /tmp/empty-dir &

# cleanup phase
cleanup() {
  # deregister runner from github.com
  RUNNER_NAME=$(hostname -s)
  RUNNER_ID=$(curl -s -X GET -H "Authorization: Bearer ${TOKEN}" \
       -H "Accept: application/vnd.github+json" \
       -H "X-GitHub-Api-Version: 2022-11-28" \
       https://api.github.com/orgs/${ORGANISATION}/actions/runners | jq --arg runnername "$RUNNER_NAME" '.runners[] | select(.name==$runnername) | .id')

  curl -s -X DELETE -H "Authorization: Bearer ${TOKEN}" \
       -H "Accept: application/vnd.github+json" \
       -H "X-GitHub-Api-Version: 2022-11-28" \
       "https://api.github.com/orgs/${ORGANISATION}/actions/runners/$RUNNER_ID"

  echo "Cleaning up processes..."
  pkill -9 -P 1
  exit 0
}

# trap cleanup SIGTERM SIGINT
trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
