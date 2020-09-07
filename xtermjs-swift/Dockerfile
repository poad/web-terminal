ARG BASE_IMAGE="bionic"

ARG PYTHON_XZ_GPG_KEY="E3FF2839C048B25C084DEBE9B26995E310250568"
ARG PYTHON_VERSION="3.8.5"
ARG PYTHON_PIP_VERSION="20.2.2"
# https://github.com/pypa/get-pip
ARG PIP_DOWNLOAD_HASH="2739acb7ffe6814449fa80ffec68604ca48aa59d"
ARG PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/${PIP_DOWNLOAD_HASH}/get-pip.py
ARG PYTHON_GET_PIP_SHA256="d4d62a0850fe0c2e6325b2cc20d818c580563de5a2038f917e3cb0e25280b4d1"

ARG SWIFT_VERSION=5.2.5
ARG SWIFT_SIGNING_KEY=A62AE125BBBFBB96A6E042EC925CC1CCED3D1561
ARG SWIFT_PLATFORM=ubuntu18.04

FROM buildpack-deps:bionic-curl AS downloader

ARG PYTHON_XZ_GPG_KEY
ARG PYTHON_VERSION

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ARG PYTHON_PIP_VERSION
# https://github.com/pypa/get-pip
ARG PYTHON_GET_PIP_URL
ARG PYTHON_GET_PIP_SHA256

ARG SWIFT_VERSION
ARG SWIFT_PLATFORM
ARG SWIFT_SIGNING_KEY

ARG ARCHIVE_FILE="swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz"
ARG DOWNLOAD_URL="https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1804/swift-${SWIFT_VERSION}-RELEASE/${ARCHIVE_FILE}"

WORKDIR /tmp
RUN apt-get update -qq \
 && apt-get install -qqy --no-install-recommends gnupg2 ca-certificates \
 && curl -sSLo /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key \
 && curl -fsSL "$DOWNLOAD_URL" -o "/tmp/${ARCHIVE_FILE}" "${DOWNLOAD_URL}.sig" -o "/tmp/${ARCHIVE_FILE}.sig" \
 && curl -sSLo get-pip.py "${PYTHON_GET_PIP_URL}" \
 && echo "${PYTHON_GET_PIP_SHA256} *get-pip.py" | sha256sum -c - \
 && export GNUPGHOME="$(mktemp -d)" \
 && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
 && curl -sS https://swift.org/keys/all-keys.asc | gpg --import - \
 && curl -sS https://swift.org/keys/release-key-swift-5.x.asc | gpg --import - \
 && gpg --batch --quiet --keyserver ha.pool.sks-keyservers.net --recv-keys "${SWIFT_SIGNING_KEY}" \
 && gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift \
 && gpg --verify "/tmp/${ARCHIVE_FILE}.sig" \
 && tar xf "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz" \
 && rm -rf "${GNUPGHOME}" "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz" "/tmp/${ARCHIVE_FILE}.sig" \
 && curl -sSLo /tmp/node_setup_12.x.sh https://deb.nodesource.com/setup_12.x


FROM ubuntu:${BASE_IMAGE}

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

ARG SWIFT_VERSION
ARG SWIFT_PLATFORM

USER root

ARG PYTHON_PIP_VERSION

ENV PATH=/usr/local/bin:${PATH}

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive


COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py
COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key
COPY --from=downloader /tmp/node_setup_12.x.sh /tmp/node_setup_12.x.sh

COPY --from=downloader "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}" /opt/swift

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && apt-key add /tmp/llvm-snapshot.gpg.key \
 && echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && bash /tmp/node_setup_12.x.sh \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends \
		libexpat1 \
      	libssl1.1 \
        make \
		clang-10 \
		lld-10 \
		libpython2.7 \
		libncurses5 \
		libxml2 \
		python3.8 \
		nodejs \
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

COPY --chown=node:node assets/webshell /home/node/webshell

ENV PATH=/opt/swift/usr/bin:${PATH}


WORKDIR /home/node/webshell


ENV CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/sqlite3/include -I/usr/local/opt/openssl/include" \
    LDFLAGS="-L/usr/local/lib -L/usr/local/opt/openssl/lib" \
    CC="/usr/bin/clang-10 -O5 -fsanitize=undefined" \
    CXX="clang++-10 -O5 -fsanitize=undefined -fno-sanitize=vptr"

RUN mkdir -p /home/node/.yarn \
 && yarn install

RUN yarn run build
RUN yarn run package

RUN cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js

EXPOSE 3000

CMD [ "yarn", "start" ]
