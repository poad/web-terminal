#!/usr/bin/env ash

REQUEST_BODY=$(cat << PULL_REQUEST
{
    "title": "${INPUT_TITLE}",
    "body": "${INPUT_BODY}",
    "head": "${INPUT_BRANCH_NAME}",
    "base": "${INPUT_TARGET_BRANCH_NAME}"
}
PULL_REQUEST
)
curl -X POST \
    --url https://api.github.com/repos/${INPUT_REPOSITORY}/pulls \
    --header 'content-type: application/vnd.github.sailor-v-preview+json' \
    --header "authorization: bearer ${INPUT_GITHUB_TOKEN}" \
    --data "${REQUEST_BODY}"

exit $?
