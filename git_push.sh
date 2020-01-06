#!/usr/bin/env sh

REPO=web-terminal

if [ -z ${GITHUB_TOKEN} ]; then
  echo "Env ver GITHUB_TOKEN is must not be empty"
  exit -1
fi


USER=$(curl -H "Authorization: token ${GITHUB_TOKEN}" https://api.github.com/user) && \
USER_ID=$(echo ${USER} | jq ".login") && \
EMAIL=$(echo ${USER} | jq ".email")

if [ -z ${USER_ID} ]; then
  echo "failed to get git user info ${USER}"
  exit -1
fi

TMP_DIR=$(mktemp -d) && \
cd ${TMP_DIR}

git clone "https://${USER_ID}:${GITHUB_TOKEN}@github.com/${USER_ID}/${REPO}"
if [ $? -ne 0 ]; then
  echo "Failed clone https://${USER_ID}:\${GITHUB_TOKEN}@github.com/${USER_ID}/${REPO}"
  exit -1
fi

cd ${REPO}


env bash -x update.sh

TIMESTAMP=$(date)

BRANCH_NAME="feature/bump-modules-$(date "+%Y%m%d-%H%M%S")"

REQUEST_BODY=$(cat << PULL_REQUEST
{
  "title": "Auto update at ${TIMESTAMP}",
  "body": "Update the modules at ${TIMESTAMP}",
  "head": "${BRANCH_NAME}",
  "base": "master"
}
PULL_REQUEST
)

git checkout -b "${BRANCH_NAME}" && \
git add * && \
git config --global user.email "${EMAIL}" && \
git config --global user.name "${USER_ID}" && \
git commit -m "Auto update at ${TIMESTAMP}" && \
git push --set-upstream origin "${BRANCH_NAME}" && \
curl -X POST \
  --url https://api.github.com/repos/poad/web-terminal/pulls \
  --header 'content-type: application/vnd.github.sailor-v-preview+json' \
  --header "authorization: bearer ${GITHUB_TOKEN}" \
  --data "${REQUEST_BODY}"
