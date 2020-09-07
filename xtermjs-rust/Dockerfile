ARG BASE_IMAGE="lts-buster-slim"

ARG PYTHON_PIP_VERSION="20.2.2"
# https://github.com/pypa/get-pip
ARG PIP_DOWNLOAD_HASH="2739acb7ffe6814449fa80ffec68604ca48aa59d"
ARG PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/${PIP_DOWNLOAD_HASH}/get-pip.py
ARG PYTHON_GET_PIP_SHA256="d4d62a0850fe0c2e6325b2cc20d818c580563de5a2038f917e3cb0e25280b4d1"


FROM alpine:3 AS downloader

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ARG PYTHON_PIP_VERSION
# https://github.com/pypa/get-pip
ARG PYTHON_GET_PIP_URL
ARG PYTHON_GET_PIP_SHA256


ENV PATH=/usr/local/python/bin:$PATH

RUN apk add --no-cache --virtual .build-deps \
    curl \
    gnupg \
    xz 

WORKDIR /tmp
RUN curl -sSLo get-pip.py "${PYTHON_GET_PIP_URL}" \
 && echo "${PYTHON_GET_PIP_SHA256} *get-pip.py" | sha256sum -c - \
 && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup.rs \
 && curl -sL https://apt.llvm.org/llvm-snapshot.gpg.key > /tmp/llvm-snapshot.gpg.key



FROM node:${BASE_IMAGE}

USER root
LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

ARG PYTHON_PIP_VERSION

USER root

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py
COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && cat /tmp/llvm-snapshot.gpg.key | apt-key add - \
 && echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends \
		libexpat1 \
      	libssl1.1 \
        make \
		clang-10 \
		lld-10 \
		curl \
		python3.8 \
 && ldconfig \
 && python /tmp/get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==${PYTHON_PIP_VERSION}" \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog 

ENV CPPFLAGS="" \
    LDFLAGS="" \
    CC="clang-10" \
    CXX="clang++-10"

USER node

ENV PATH=/home/node/.cargo/bin:${PATH}

COPY --chown=node:node assets/webshell /home/node/webshell
COPY --chown=node:node --from=downloader /tmp/rustup.rs /tmp/rustup.rs

WORKDIR /home/node/webshell

RUN yarn install \
 && yarn run build \
 && yarn run package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && chmod 744 /tmp/rustup.rs \
 && /tmp/rustup.rs -y \
 && cargo install evcxr_repl

EXPOSE 3000

CMD [ "yarn", "start" ]
