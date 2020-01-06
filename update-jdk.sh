#!/usr/bin/env sh

JAVA_VERSION=${1}

CUR=$(pwd)

for target in $(ls -d xterm*)
do
  cd ${CUR}/${target} 
  TMP=$(mktemp) && \
  cat Dockerfile | sed -E "s/JAVA_VERSION=\".*\"/JAVA_VERSION=\"${JAVA_VERSION}\"/g" > ${TMP} && \
  cat ${TMP} > Dockerfile && \
  rm -f ${TMP}
  TMP=$(mktemp) && \
  cat hooks/build | sed -E "s/JAVA_VERSION=\".*\"/JAVA_VERSION=\"${JAVA_VERSION}\"/g" > ${TMP} && \
  cat ${TMP} > hooks/build && \
  rm -f ${TMP}
done
