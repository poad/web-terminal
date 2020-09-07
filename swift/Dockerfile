ARG SWIFT_VERSION=5.2.5
ARG SWIFT_SIGNING_KEY=A62AE125BBBFBB96A6E042EC925CC1CCED3D1561
ARG SWIFT_PLATFORM=ubuntu18.04

FROM buildpack-deps:bionic-curl AS downloader

ARG SWIFT_VERSION
ARG SWIFT_PLATFORM
ARG SWIFT_SIGNING_KEY

ARG ARCHIVE_FILE="swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz"
ARG DOWNLOAD_URL="https://swift.org/builds/swift-${SWIFT_VERSION}-release/ubuntu1804/swift-${SWIFT_VERSION}-RELEASE/${ARCHIVE_FILE}"

RUN apt-get update -qq \
 && apt-get install -qqy --no-install-recommends gnupg2 \
 && export GNUPGHOME="$(mktemp -d)" \
 && echo "disable-ipv6" >> ${GNUPGHOME}/dirmngr.conf

RUN curl -sLo /tmp/llvm-snapshot.gpg.key https://apt.llvm.org/llvm-snapshot.gpg.key \
 && curl -fsSL "$DOWNLOAD_URL" -o "/tmp/${ARCHIVE_FILE}" "${DOWNLOAD_URL}.sig" -o "/tmp/${ARCHIVE_FILE}.sig"
RUN curl -sS https://swift.org/keys/all-keys.asc | gpg --import - \
 && curl -sS https://swift.org/keys/release-key-swift-5.x.asc | gpg --import - \
 && gpg --batch --quiet --keyserver ha.pool.sks-keyservers.net --recv-keys "${SWIFT_SIGNING_KEY}" \
 && gpg --keyserver hkp://pool.sks-keyservers.net --refresh-keys Swift
RUN gpg --verify "/tmp/${ARCHIVE_FILE}.sig"
WORKDIR /tmp
RUN tar xf "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}.tar.gz"

FROM poad/web-terminal:base

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

ARG SWIFT_VERSION
ARG SWIFT_PLATFORM

USER root
COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key
COPY --from=downloader "/tmp/swift-${SWIFT_VERSION}-RELEASE-${SWIFT_PLATFORM}" /home/node/.swift

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 apt-utils libssl-dev librocksdb-dev \
 && cat /tmp/llvm-snapshot.gpg.key | apt-key add - \
 && echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-10 main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends \
            llvm-10 \
            clang-10 \
            lld-10 \
            make \
            libicu-dev \
            binutils \
            git \
            libc6-dev \
            libcurl4 \
            libedit2 \
            libgcc-8-dev \
            libpython2.7 \
            libncurses5 \
            libsqlite3-0 \
            libstdc++-8-dev \
            libxml2 \
            pkg-config \
            tzdata \
            zlib1g-dev\
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog

USER node

ENV CC=clang-10 \
    CXX=clang++-10

USER node

ENV PATH=/home/node/.swift/usr/bin:${PATH}

ENV WEB_SHELL="swift"

EXPOSE 8088

CMD [ "web-terminal", "--port", "8088" ]
