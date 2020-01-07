#!/usr/bin/env ash

if [ $# -ne 0 ]; then
  REVIEWERS=$(echo $@ | sed -e "s/ /,/g")
else
  REVIEWERS=${INPUT_REQUESTED_REVIEWER}
fi

REQUEST_BODY=$(cat << PULL_REQUEST
{
  "reviewers": [
    ${REVIEWERS}
  ]
}
PULL_REQUEST
)

curl -X POST \
    --url ${INPUT_PULL_REQUEST_URL}/requested_reviewers \
    --header "authorization: bearer ${INPUT_GITHUB_TOKEN}" \
    --data "${REQUEST_BODY}"

exit $?
