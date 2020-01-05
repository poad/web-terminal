#!/usr/bin/env sh

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
git config user.name "${USERNAME}" && \
git config user.email "${MAIL}" && \
git add * && \
git commit -m "Auto update at ${TIMESTAMP}" && \
git push --set-upstream origin "${BRANCH_NAME}" && \
curl -X POST \
  --url https://api.github.com/repos/poad/web-terminal/pulls \
  --header 'content-type: application/vnd.github.sailor-v-preview+json' \
  --header "authorization: bearer ${GITHUB_TOKEN}" \
  --data "${REQUEST_BODY}"
