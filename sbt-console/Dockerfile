ARG SBT_VERSION="1.3.6"
ARG SBT_HOME=/usr/local/sbt

FROM buildpack-deps:bionic-curl AS sbt

ARG SBT_VERSION

RUN curl -sL "https://github.com/sbt/sbt/releases/download/v${SBT_VERSION}/sbt-${SBT_VERSION}.tgz" | tar -xz -C /tmp


FROM poad/web-terminal:jshell

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

ARG SBT_HOME

ENV SBT_HOME=${SBT_HOME} \
    PATH="$SBT_HOME/bin:$PATH"

USER root

COPY --from=sbt /tmp/sbt ${SBT_HOME}

USER node

RUN mkdir -p /home/node/sbt-console

COPY --chown=node:node assets/ /home/node/sbt-console

WORKDIR /home/node/sbt-console

RUN sbt compile clean

ENV WEB_SHELL="bash"

EXPOSE 8088

CMD [ "web-terminal", "--port", "8088" ]
