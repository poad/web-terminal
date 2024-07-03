ARG BASE_IMAGE="jammy"

ARG PYTHON_VERSION="3.12"
ARG PYTHON_PIP_VERSION="23.1.2"
# https://github.com/docker-library/python/blob/master/3.11/bullseye/Dockerfile
ARG PIP_DOWNLOAD_HASH="0d8570dc44796f4369b652222cf176b3db6ac70e"
ARG PYTHON_GET_PIP_URL="https://github.com/pypa/get-pip/raw/${PIP_DOWNLOAD_HASH}/public/get-pip.py"
ARG PYTHON_GET_PIP_SHA256="96461deced5c2a487ddc65207ec5a9cffeca0d34e7af7ea1afc470ff0d746207"

ARG JAVA_VERSION="17"
ARG JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
ARG SRC_JAVA_HOME=/usr/lib/jvm/zulu-${JAVA_VERSION}-azure-amd64

# https://www.scala-sbt.org/download.html
ARG SBT_VERSION="1.9.9"
ARG SBT_HOME=/usr/local/sbt

# https://swift.org/download/
ARG SWIFT_VERSION="5.10"
ARG SWIFT_SIGNING_KEY="A62AE125BBBFBB96A6E042EC925CC1CCED3D1561"
ARG SWIFT_PLATFORM_COMMA_LESS="ubuntu2204"
ARG SWIFT_PLATFORM="ubuntu22.04"

ARG NODE_VERSION="20.x"
# https://llvm.org
ARG LLVM_VERSION=16

FROM mcr.microsoft.com/java/jdk:${JAVA_VERSION}-zulu-ubuntu AS jdk

FROM buildpack-deps:${BASE_IMAGE}-curl AS downloader-base

WORKDIR /tmp
RUN apt-get update -qq \
 && apt-get install -qqy --no-install-recommends gnupg2 ca-certificates unzip \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog

FROM downloader-base AS downloader

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ARG PYTHON_PIP_VERSION
# https://github.com/pypa/get-pip
ARG PYTHON_GET_PIP_URL
ARG PYTHON_GET_PIP_SHA256
ARG NODE_VERSION

WORKDIR /tmp
RUN curl -sSLo /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key \
 && curl -sSLo get-pip.py "${PYTHON_GET_PIP_URL}" \
 && echo "${PYTHON_GET_PIP_SHA256} *get-pip.py" | sha256sum -c - \
 && curl -sSLo /tmp/node_setup_${NODE_VERSION}.sh https://deb.nodesource.com/setup_${NODE_VERSION}

#-----------------------------

FROM downloader-base AS downloader-swift

ARG SWIFT_VERSION
ARG SWIFT_PLATFORM
ARG SWIFT_PLATFORM_COMMA_LESS
ARG SWIFT_SIGNING_KEY

ARG ARCHIVE_FILE="swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz"
ARG DOWNLOAD_URL="https://swift.org/builds/swift-${SWIFT_VERSION}-release/${SWIFT_PLATFORM_COMMA_LESS}/swift-${SWIFT_VERSION}-RELEASE/${ARCHIVE_FILE}"

WORKDIR /tmp
RUN echo ${DOWNLOAD_URL}
RUN curl -fsSL "$DOWNLOAD_URL" -o "/tmp/${ARCHIVE_FILE}" "${DOWNLOAD_URL}.sig" -o "/tmp/${ARCHIVE_FILE}.sig" \
 && export GNUPGHOME="$(mktemp -d)" \
 && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
 && gpg --batch --quiet --keyserver keyserver.ubuntu.com --recv-keys "$SWIFT_SIGNING_KEY" \
 && gpg --batch --verify swift.tar.gz.sig swift.tar.gz \
 ;  gpg --verify "/tmp/${ARCHIVE_FILE}.sig" \
 && tar xf "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz" \
 && rm -rf "${GNUPGHOME}" "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz" "/tmp/${ARCHIVE_FILE}.sig"

#-----------------------------

FROM downloader-base AS downloader-sbt

ARG SBT_VERSION

WORKDIR /tmp
RUN curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /tmp


FROM downloader-base AS downloader-rust

WORKDIR /tmp
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup.rs

#-----------------------------

FROM ubuntu:${BASE_IMAGE} AS base

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

USER root

ARG BASE_IMAGE
ARG PYTHON_PIP_VERSION
ARG NODE_VERSION
ARG LLVM_VERSION
ARG PYTHON_VERSION

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    SHELL=bash

COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py
COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key
COPY --from=downloader /tmp/node_setup_${NODE_VERSION}.sh /tmp/node_setup_${NODE_VERSION}.sh

# make some useful symlinks that are expected to exist
WORKDIR /usr/local/bin

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update -qq \
 && apt-get full-upgrade -qqy \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && cat /tmp/llvm-snapshot.gpg.key | gpg --dearmor -o /usr/share/keyrings/llvm-keyring.gpg \
 && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/llvm-keyring.gpg] http://apt.llvm.org/${BASE_IMAGE}/ llvm-toolchain-${BASE_IMAGE}-${LLVM_VERSION} main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && cat /tmp/node_setup_${NODE_VERSION}.sh | bash - \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends \
		libexpat1 \
        make \
		clang-${LLVM_VERSION} \
		lld-${LLVM_VERSION} \
		python${PYTHON_VERSION} \
        python3-distutils \
		libncurses5 \
		libxml2 \
        gcc \
        g++ \
        nodejs \
 && apt-get autoclean \
 && apt-get clean all \
 && npm -g i npm pnpm \
 && pnpm setup \
 && python${PYTHON_VERSION} /tmp/get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==${PYTHON_PIP_VERSION}" \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog

RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node 

USER node

RUN mkdir -p /home/node/.pnpm

COPY --chown=node:node assets/base/webshell /home/node/webshell
EXPOSE 3000

CMD [ "pnpm", "start" ]

#-----------------------------

FROM base AS xtermjs

COPY --chown=node:node assets/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN pnpm install \
 && pnpm build \
 && pnpm package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && chown -R node:node /home/node

#-----------------------------

FROM base AS ts-node

WORKDIR /home/node/webshell

RUN rm -rf package.json pnpm-lock.yaml

COPY --chown=node:node assets/ts-node/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN pnpm install \
 && pnpm build \
 && pnpm package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && chown -R node:node /home/node

#-----------------------------

FROM base AS java-base

ARG JAVA_VERSION
ARG JAVA_HOME
ARG SRC_JAVA_HOME

COPY --from=jdk ${SRC_JAVA_HOME} ${JAVA_HOME}

ENV JAVA_HOME ${JAVA_HOME}
ENV PATH "$JAVA_HOME/bin:$PATH"

USER root

RUN for tool_path in "${JAVA_HOME}"/bin/*; do \
          tool=$(basename $tool_path) \
       && update-alternatives --install /usr/bin/$tool "$tool" "$tool_path" 10000 \
       && update-alternatives --set "$tool" "$tool_path"; \
    done

USER node

#-----------------------------

FROM java-base AS sbt-console

ARG SBT_HOME

ENV SBT_HOME=${SBT_HOME} \
    PATH="$SBT_HOME/bin:$PATH"

USER root

COPY --from=downloader-sbt /tmp/sbt ${SBT_HOME}

RUN chown -R node:node /home/node 

USER node

RUN mkdir -p /home/node/sbt-console
WORKDIR /home/node/sbt-console

RUN sbt compile clean

COPY --chown=node:node assets/sbt-console/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN pnpm install \
 && pnpm build \
 && pnpm package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js

#-----------------------------

FROM java-base AS jshell

USER node

COPY --chown=node:node assets/jshell/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN pnpm install \
 && pnpm build \
 && pnpm package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js

#-----------------------------

FROM java-base AS jshell-gradle

USER node

ENV JAVA_OPTS="--add-exports jdk.jshell/jdk.internal.jshell.tool=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED"

COPY --chown=node:node assets/jshell-gradle/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN pnpm install \
 && pnpm build \
 && pnpm package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && mv build.gradle.example build.gradle

#-----------------------------

FROM java-base AS jshell-maven

USER root

USER node

ENV JAVA_OPTS="--add-exports jdk.jshell/jdk.internal.jshell.tool=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED"

COPY --chown=node:node assets/jshell-maven/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN pnpm install \
 && pnpm build \
 && pnpm package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && mv pom.xml.example pom.xml

#-----------------------------

FROM base AS rust

USER node

COPY --chown=node:node --from=downloader-rust /tmp/rustup.rs /tmp/rustup.rs
COPY --chown=node:node assets/rust/webshell /home/node/webshell

ENV PATH=/home/node/.cargo/bin:${PATH}

WORKDIR /home/node/webshell

RUN mkdir -p /home/node/.cargo \
 && pnpm install \
 && pnpm build \
 && pnpm package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && chmod 744 /tmp/rustup.rs \
 && /tmp/rustup.rs -y \
 && cargo update \
 && cargo install evcxr_repl

#-----------------------------

FROM base AS swift

ARG SWIFT_VERSION
ARG SWIFT_PLATFORM

USER node

COPY --chown=node:node assets/swift/webshell /home/node/webshell
COPY --from=downloader-swift "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}" /opt/swift

ENV PATH=/opt/swift/usr/bin:${PATH}

WORKDIR /home/node/webshell

RUN pnpm install \
 && pnpm build \
 && pnpm package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js
