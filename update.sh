#!/bin/sh

CUR=$(pwd)

CURRENT=$(cd $(dirname $0);pwd)
echo "${CURRENT}"

cd "${CURRENT}"
git pull --prune
result=$?
if [ $result -ne 0 ]; then
  cd "${CUR}"
  exit $result
fi

cd "${CURRENT}"/xtermjs/assets/base/webshell
result=$?
if [ $result -ne 0 ]; then
  cd "${CUR}"
  exit $result
fi
echo ""
pwd
yarn install && yarn upgrade
result=$?
if [ $result -ne 0 ]; then
  cd "${CUR}"
  exit $result
fi

cd "${CURRENT}"/xtermjs/assets/ts-node/webshell
result=$?
if [ $result -ne 0 ]; then
  cd "${CUR}"
  exit $result
fi
echo ""
pwd
yarn install && yarn upgrade
result=$?
if [ $result -ne 0 ]; then
  cd "${CUR}"
  exit $result
fi

cd "${CURRENT}"
result=$?
if [ $result -ne 0 ]; then
  cd "${CUR}"
  exit $result
fi
git commit -am "Bumps node modules" && git push
result=$?
if [ $result -ne 0 ]; then
  cd "${CUR}"
  exit $result
fi

cd "${CUR}"
