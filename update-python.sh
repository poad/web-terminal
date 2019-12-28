#!/usr/bin/env sh

PYTHON_VERSION=${1}

CUR=$(pwd)

for target in $(ls -d xterm*)
do
  cd ${CUR}/${target} 
  TMP=$(mktemp) && \
  cat Dockerfile | sed -E "s/PYTHON_VERSION=\".*\"/PYTHON_VERSION=\"${PYTHON_VERSION}\"/g" > ${TMP} && \
  cat ${TMP} > Dockerfile && \
  rm -f ${TMP}
  TMP=$(mktemp) && \
  cat hooks/build | sed -E "s/PYTHON_VERSION=\".*\"/PYTHON_VERSION=\"${PYTHON_VERSION}\"/g" > ${TMP} && \
  cat ${TMP} > hooks/build && \
  rm -f ${TMP}
done
