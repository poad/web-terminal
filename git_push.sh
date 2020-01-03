#!/usr/bin/env sh

TIMESTAMP=$(date)

REQUEST_BODY=$(cat << PULL_REQUEST
{
  "title": "Auto update at ${TIMESTAMP}",
  "body": "Update the modules at ${TIMESTAMP}",
  "head": "feature/bump-modules-${TIMESTAMP}",
  "base": "master"
}
PULL_REQUEST
)

git switch -c "feature/bump-modules-${TIMESTAMP}" && \
git add * && \
git commit -m "Auto update at ${TIMESTAMP}" && \
git push --set-upstream origin "feature/bump-modules-${TIMESTAMP}" && \
curl -X POST \
  --url https://api.github.com/repos/poad/web-terminal/pulls \
  --header 'content-type: application/vnd.github.sailor-v-preview+json' \
  --cookie logged_in=no \
  --data "${REQUEST_BODY}"
