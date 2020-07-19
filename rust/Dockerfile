FROM buildpack-deps:bionic-curl AS downloader

ARG SBT_VERSION

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > /tmp/rustup.rs \
 && curl -sL https://apt.llvm.org/llvm-snapshot.gpg.key > /tmp/llvm-snapshot.gpg.key

FROM poad/web-terminal:base

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

USER root
COPY --from=downloader /tmp/llvm-snapshot.gpg.key /tmp/llvm-snapshot.gpg.key

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy ca-certificates gnupg2 binutils apt-utils libssl-dev librocksdb-dev git \
 && cat /tmp/llvm-snapshot.gpg.key | apt-key add - \
 && echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && echo "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-10 main" >> /etc/apt/sources.list.d/llvm-toolchain.list \
 && apt-get update -qq \
 && apt-get install -qqy --no-install-recommends llvm-10 clang-10 lld-10 git make \
 && apt-get autoremove --purge -qqy \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog

RUN ln -s /usr/bin/clang-10 /usr/bin/gcc \
 && ln -s /usr/bin/clang-10 /usr/bin/cc

USER node

ENV CC=clang-10 \
    CXX=clang++-10

USER root

RUN apt-get update -qq \
 && apt-get install -qqy --no-install-recommends curl \
 && apt-get clean -qq \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog

COPY --chown=node:node --from=downloader /tmp/rustup.rs /tmp/rustup.rs

USER node

RUN chmod 744 /tmp/rustup.rs \
 && /tmp/rustup.rs -y

USER root

RUN apt-get update -qq \
 && apt-get autoremove --purge -qqy curl \
 && apt-get clean -qq \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog

USER node

ENV PATH=/home/node/.cargo/bin:${PATH}

RUN cargo install evcxr_repl

ENV WEB_SHELL="evcxr"

EXPOSE 8088

CMD [ "web-terminal", "--port", "8088" ]
