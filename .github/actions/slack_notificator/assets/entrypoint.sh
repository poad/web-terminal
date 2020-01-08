#!/usr/bin/env ash


if [ -z ${INPUT_WEBHOOK_URL} ]; then
  echo "WebHook URL must not empty"
  exit -1
fi

if [ -z ${INPUT_TEXT} ]; then
  echo "text must not empty"
  exit -1
fi

echo ${INPUT_WEBHOOK_URL}

echo "${INPUT_TEXT}"

REQUEST_BODY=$(cat << MESSAGE
{
    "text": "${INPUT_TEXT}"
}
MESSAGE
)


curl -X POST \
    --url ${INPUT_PULL_REQUEST_URL}/requested_reviewers \
    --header "Content-type: application/json" \
    --data "${REQUEST_BODY}"

exit $?
