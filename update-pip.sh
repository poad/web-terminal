#!/usr/bin/env sh

PYTHON_PIP_VERSION=${1}
PYTHON_GET_PIP_SHA256=${2}
PIP_DOWNLOAD_HASH=${3}

if [ -z "${PYTHON_PIP_VERSION}" ]; then
  echo "pip version must not be empty."
  echo "${0} {PYTHON_PIP_VERSION} {PYTHON_GET_PIP_SHA256} PIP_DOWNLOAD_HASH}"
  exit 1
fi

if [ -z "${PYTHON_GET_PIP_SHA256}" ]; then
  echo "pip sha256 must not be empty."
  echo "${0} {PYTHON_PIP_VERSION} {PYTHON_GET_PIP_SHA256} PIP_DOWNLOAD_HASH}"
  exit 1
fi

if [ -z "${PIP_DOWNLOAD_HASH}" ]; then
  echo "hash code of pip download url. must not be empty."
  echo "${0} {PYTHON_PIP_VERSION} {PYTHON_GET_PIP_SHA256} PIP_DOWNLOAD_HASH}"
  exit 1
fi

CUR=$(pwd)

for target in $(ls -d xterm*)
do
  cd ${CUR}/${target} 
  TMP=$(mktemp) && \
  cat Dockerfile | sed -E "s/PYTHON_PIP_VERSION=\".*\"/PYTHON_PIP_VERSION=\"${PYTHON_PIP_VERSION}\"/g" \
                 | sed -E "s/PYTHON_GET_PIP_SHA256=\".*\"/PYTHON_GET_PIP_SHA256=\"${PYTHON_GET_PIP_SHA256}\"/g" \
                 | sed -E "s/PIP_DOWNLOAD_HASH=\".*\"/PIP_DOWNLOAD_HASH=\"${PIP_DOWNLOAD_HASH}\"/g" > ${TMP} && \
  cat ${TMP} > Dockerfile && \
  rm -f ${TMP}
  TMP=$(mktemp) && \
  cat hooks/build | sed -E "s/PYTHON_PIP_VERSION=\".*\"/PYTHON_PIP_VERSION=\"${PYTHON_PIP_VERSION}\"/g" \
                  | sed -E "s/PYTHON_GET_PIP_SHA256=\".*\"/PYTHON_GET_PIP_SHA256=\"${PYTHON_GET_PIP_SHA256}\"/g" \
                  | sed -E "s/PIP_DOWNLOAD_HASH=\".*\"/PIP_DOWNLOAD_HASH=\"${PIP_DOWNLOAD_HASH}\"/g" > ${TMP} && \
  cat ${TMP} > hooks/build && \
  rm -f ${TMP}
done
