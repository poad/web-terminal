#!/usr/bin/env sh

TIMESTAMP=$(date)

BRANCH_NAME="feature/bump-modules-${TIMESTAMP}"

REQUEST_BODY=$(cat << PULL_REQUEST
{
  "title": "Auto update at ${TIMESTAMP}",
  "body": "Update the modules at ${TIMESTAMP}",
  "head": "${TIMESTAMP}",
  "base": "master"
}
PULL_REQUEST
)

git checkout -b "${BRANCH_NAME}" && \
git add * && \
git commit -m "Auto update at ${TIMESTAMP}" && \
git push --set-upstream origin "${BRANCH_NAME}" && \
curl -X POST \
  --url https://api.github.com/repos/poad/web-terminal/pulls \
  --header 'content-type: application/vnd.github.sailor-v-preview+json' \
  --cookie logged_in=no \
  --data "${REQUEST_BODY}"
