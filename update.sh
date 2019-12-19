#!/usr/bin/env sh

CUR=$(pwd)

for target in $(ls -d xterm*)
do
  cd ${CUR}/${target}
  yarn upgrade
  yarn install
  cd assets/webshell
  yarn upgrade
  yarn install
done
