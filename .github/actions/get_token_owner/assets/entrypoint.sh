#!/usr/bin/env ash

USER=$(
    curl -X GET \
      --url https://api.github.com/user \
      --header "authorization: bearer ${INPUT_GITHUB_TOKEN}" \
  )
if [ $? -ne 0 ]; then
  exit -1
fi

echo ${USER}

USER_ID=$(echo ${USER} | jq ".login")

echo ${USER_ID}

echo "::set-env name=GITHUB_TOKEN_OWNER::${USER_ID}"
