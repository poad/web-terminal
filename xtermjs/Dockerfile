ARG BASE_IMAGE="bionic"

ARG PYTHON_PIP_VERSION="20.2.2"
# https://github.com/pypa/get-pip
ARG PIP_DOWNLOAD_HASH="2739acb7ffe6814449fa80ffec68604ca48aa59d"
ARG PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/${PIP_DOWNLOAD_HASH}/get-pip.py
ARG PYTHON_GET_PIP_SHA256="d4d62a0850fe0c2e6325b2cc20d818c580563de5a2038f917e3cb0e25280b4d1"

ARG JAVA_VERSION="11.0.8_10"
ARG JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
ARG SBT_VERSION="1.3.13"
ARG SBT_HOME=/usr/local/sbt

ARG SWIFT_VERSION="5.2.5"
ARG SWIFT_SIGNING_KEY="A62AE125BBBFBB96A6E042EC925CC1CCED3D1561"
ARG SWIFT_PLATFORM="ubuntu18.04"

FROM poad/docker-openjdk:11-adopt-buster AS jdk

FROM buildpack-deps:${BASE_IMAGE}-curl AS downloader

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ARG PYTHON_PIP_VERSION
# https://github.com/pypa/get-pip
ARG PYTHON_GET_PIP_URL
ARG PYTHON_GET_PIP_SHA256

ARG SBT_VERSION

ARG SWIFT_VERSION
ARG SWIFT_PLATFORM
ARG SWIFT_SIGNING_KEY

ARG ARCHIVE_FILE="swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz"
ARG DOWNLOAD_URL="https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1804/swift-${SWIFT_VERSION}-RELEASE/${ARCHIVE_FILE}"

WORKDIR /tmp
RUN apt-get update -qq \
 && apt-get install -qqy --no-install-recommends gnupg2 ca-certificates \
 && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup.rs \
 && curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /tmp \
 && curl -sSLo /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key \
 && curl -fsSL "$DOWNLOAD_URL" -o "/tmp/${ARCHIVE_FILE}" "${DOWNLOAD_URL}.sig" -o "/tmp/${ARCHIVE_FILE}.sig" \
 && curl -sSLo get-pip.py "${PYTHON_GET_PIP_URL}" \
 && echo "${PYTHON_GET_PIP_SHA256} *get-pip.py" | sha256sum -c - \
 && export GNUPGHOME="$(mktemp -d)" \
 && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
 && curl -sS https://swift.org/keys/all-keys.asc | gpg --import - \
 && curl -sS https://swift.org/keys/release-key-swift-5.x.asc | gpg --import - \
 && for keyserver in "ha.pool.sks-keyservers.net" "hkp://pool.sks-keyservers.net" "hkp://pgp.mit.edu:80"; do \
        gpg --batch --quiet --keyserver "${keyserver}" --recv-keys "${SWIFT_SIGNING_KEY}" \
     && gpg --keyserver "${keyserver}" --refresh-keys Swift \
     && break;\
    done \
 ;  gpg --verify "/tmp/${ARCHIVE_FILE}.sig" \
 && tar xf "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz" \
 && rm -rf "${GNUPGHOME}" "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz" "/tmp/${ARCHIVE_FILE}.sig" \
 && curl -sSLo /tmp/node_setup_12.x.sh https://deb.nodesource.com/setup_12.x


FROM ubuntu:${BASE_IMAGE} AS base

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

USER root

ARG PYTHON_PIP_VERSION

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py
COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key
COPY --from=downloader /tmp/node_setup_12.x.sh /tmp/node_setup_12.x.sh

# make some useful symlinks that are expected to exist
WORKDIR /usr/local/bin

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && apt-key add /tmp/llvm-snapshot.gpg.key \
 && echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && cat /tmp/node_setup_12.x.sh | bash - \
 && apt-get install -qqy --no-install-recommends \
		libexpat1 \
      	libssl1.1 \
        make \
		clang-10 \
		lld-10 \
		python3.8 \
		libpython2.7 \
		libncurses5 \
		libxml2 \
		nodejs \
        gcc \
        g++ \
 && npm i -g yarn \
 && python /tmp/get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==${PYTHON_PIP_VERSION}" \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog


RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node 

USER node

RUN mkdir -p /home/node/.yarn

EXPOSE 3000

CMD [ "yarn", "start" ]

FROM base AS xtermjs

COPY --chown=node:node assets/xtermjs/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN yarn install \
 && yarn run build \
 && yarn run package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && chown -R node:node /home/node

EXPOSE 3000

CMD [ "yarn", "start" ]

FROM base AS java-base

ARG JAVA_VERSION
ARG JAVA_HOME

COPY --from=jdk ${JAVA_HOME} ${JAVA_HOME}

ENV JAVA_HOME ${JAVA_HOME}
ENV PATH "$JAVA_HOME/bin:$PATH"

USER root

RUN for tool_path in "${JAVA_HOME}"/bin/*; do \
          tool=$(basename $tool_path) \
       && update-alternatives --install /usr/bin/$tool "$tool" "$tool_path" 10000 \
       && update-alternatives --set "$tool" "$tool_path"; \
    done

USER node

FROM java-base AS sbt-console

ARG SBT_HOME

ENV SBT_HOME=${SBT_HOME} \
    PATH="$SBT_HOME/bin:$PATH"

USER root

COPY --from=downloader /tmp/sbt ${SBT_HOME}

RUN chown -R node:node /home/node 

USER node

RUN sbt compile clean

RUN mkdir -p /home/node/sbt-console
WORKDIR /home/node/sbt-console

COPY --chown=node:node assets/sbt-console/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN yarn install \
 && yarn run build \
 && yarn run package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js


FROM java-base AS jshell

USER node

COPY --chown=node:node assets/jshell/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN yarn install \
 && yarn run build \
 && yarn run package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js


FROM java-base AS jshell-gradle

USER node

ENV JAVA_OPTS="--add-exports jdk.jshell/jdk.internal.jshell.tool=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED"

COPY --chown=node:node assets/jshell-gradle/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN yarn install \
 && yarn run build \
 && yarn run package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && mv build.gradle.example static/build.gradle


FROM java-base AS jshell-maven

USER node

COPY --chown=node:node assets/jshell-maven/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN yarn install \
 && yarn run build \
 && yarn run package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && mv pom.xml.example static/pom.xml


FROM base AS rust

USER node

COPY --chown=node:node --from=downloader /tmp/rustup.rs /tmp/rustup.rs
COPY --chown=node:node assets/rust/webshell /home/node/webshell

ENV PATH=/home/node/.cargo/bin:${PATH}

WORKDIR /home/node/webshell

RUN mkdir -p /home/node/.cargo \
 && yarn install \
 && yarn run build \
 && yarn run package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js \
 && chmod 744 /tmp/rustup.rs \
 && /tmp/rustup.rs -y \
 && cargo install evcxr_repl


FROM base AS swift

ARG SWIFT_VERSION
ARG SWIFT_PLATFORM

USER node

COPY --chown=node:node assets/swift/webshell /home/node/webshell
COPY --from=downloader "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}" /opt/swift

ENV PATH=/opt/swift/usr/bin:${PATH}

WORKDIR /home/node/webshell

RUN yarn install \
 && yarn run build \
 && yarn run package \
 && cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js
