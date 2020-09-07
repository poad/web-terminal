ARG BASE_IMAGE="lts-buster-slim"

ARG PYTHON_PIP_VERSION="20.2.2"
# https://github.com/pypa/get-pip
ARG PIP_DOWNLOAD_HASH="2739acb7ffe6814449fa80ffec68604ca48aa59d"
ARG PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/${PIP_DOWNLOAD_HASH}/get-pip.py
ARG PYTHON_GET_PIP_SHA256="d4d62a0850fe0c2e6325b2cc20d818c580563de5a2038f917e3cb0e25280b4d1"

ARG JAVA_VERSION="11.0.8_10"
ARG JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64
ARG SBT_VERSION="1.3.13"
ARG SBT_HOME=/usr/local/sbt

FROM poad/docker-openjdk:11-adopt-buster AS jdk

FROM alpine:3 AS downloader

ARG SBT_VERSION

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ARG PYTHON_PIP_VERSION
# https://github.com/pypa/get-pip
ARG PYTHON_GET_PIP_URL
ARG PYTHON_GET_PIP_SHA256


ENV PATH=/usr/local/python/bin:$PATH \
    JAVA_HOME=${JAVA_HOME}

RUN apk add --no-cache --virtual .build-deps \
    curl \
    gnupg \
    xz 

WORKDIR /tmp
RUN curl -sSL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /tmp \
 && curl -sSL https://apt.llvm.org/llvm-snapshot.gpg.key > /tmp/llvm-snapshot.gpg.key\
 && curl -sSLo get-pip.py "${PYTHON_GET_PIP_URL}" \
 && echo "${PYTHON_GET_PIP_SHA256} *get-pip.py" | sha256sum -c -


FROM node:${BASE_IMAGE}

LABEL maintainer="Kenji Saito<ken-yo@mbr.nifty.com>"

ARG JAVA_VERSION
ARG JAVA_HOME

ENV JAVA_HOME ${JAVA_HOME}
ENV PATH "$JAVA_HOME/bin:$PATH"

USER root

ARG PYTHON_PIP_VERSION

ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive

COPY --from=downloader /tmp/get-pip.py /tmp/get-pip.py

# make some useful symlinks that are expected to exist
WORKDIR /usr/local/bin

# extra dependencies (over what buildpack-deps already includes)
RUN apt-get update -qq \
 && apt-get autoremove --purge -qqy gcc \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils software-properties-common \
 && add-apt-repository ppa:deadsnakes/ppa -y \
 && apt-key add /tmp/llvm-snapshot.gpg.key \
 && echo "deb http://apt.llvm.org/bionic/ llvm-toolchain-bionic-10 main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends \
		libexpat1 \
      	libssl1.1 \
        make \
		clang-10 \
		lld-10 \
		python3.8 \
 && ldconfig \
 && python /tmp/get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==${PYTHON_PIP_VERSION}" \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog 

ENV CPPFLAGS="-I/usr/local/opt/zlib/include -I/usr/local/opt/sqlite3/include -I/usr/local/opt/openssl/include" \
    LDFLAGS="-L/usr/local/lib -L/usr/local/opt/openssl/lib" \
    CC="/usr/bin/clang-10 -O5 -fsanitize=undefined" \
    CXX="clang++-10 -O5 -fsanitize=undefined -fno-sanitize=vptr"

COPY --from=jdk ${JAVA_HOME} ${JAVA_HOME}

RUN for tool_path in "${JAVA_HOME}"/bin/*; do \
          tool=$(basename $tool_path) \
       && update-alternatives --install /usr/bin/$tool "$tool" "$tool_path" 10000 \
       && update-alternatives --set "$tool" "$tool_path"; \
    done

ARG SBT_HOME

ENV SBT_HOME=${SBT_HOME} \
    PATH="$SBT_HOME/bin:$PATH"

USER root

COPY --from=downloader /tmp/sbt ${SBT_HOME}

USER node

WORKDIR /home/node/sbt-console

RUN sbt compile clean

RUN mkdir -p /home/node/sbt-console

COPY --chown=node:node assets/webshell /home/node/webshell

WORKDIR /home/node/webshell

RUN yarn install

RUN yarn run build
RUN yarn run package

RUN cp -pR node_modules static/ \
 && rm -rf src tsconfig.json webpack.config.js

EXPOSE 3000

CMD [ "yarn", "start" ]
