#!/usr/bin/env sh

apt-get update -qq && \
apt-get install -qqy --no-install-recommends \
  jq

CUR=$(pwd)

for target in $(ls -d xterm/assets/*)
do
  cd ${CUR}/${target}/webshell
    # parse package.json
  dev_modules=$(echo -n $(cat package.json | jq -r ".devDependencies | to_entries | .[].key"))
  echo ${dev_modules}

  modules=$(echo -n $(cat package.json | jq -r ".dependencies | to_entries | .[].key"))
  echo ${modules}
  yarn add --dev ${dev_modules}
  yarn add ${modules}  yarn upgrade

  yarn install
  yarn upgrade
done
