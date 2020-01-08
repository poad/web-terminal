#!/usr/bin/env ash

USER=$(curl -H "Authorization: token ${INPUT_GITHUB_TOKEN}" https://api.github.com/user)
if [ $? -ne 0 ]; then
  exit -1
fi

echo ${USER}

USER_ID=$(echo ${USER} | jq ".login")

echo ${USER_ID}

echo "::set-env name=GITHUB_TOKEN_OWNER::${USER_ID}"
