ARG JAVA_VERSION="11.0.8_10"
ARG JAVA_HOME=/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64


FROM poad/docker-openjdk:11-adopt-buster AS jdk

FROM poad/web-terminal:base

LABEL maintenar="Kenji Saito <ken-yo@mbr.nifty.com>"

ARG JAVA_VERSION
ARG JAVA_HOME

ENV JAVA_HOME ${JAVA_HOME}
ENV PATH "$JAVA_HOME/bin:$PATH"

USER root

COPY --from=jdk ${JAVA_HOME} ${JAVA_HOME}

RUN for tool_path in ${JAVA_HOME}/bin/*; do \
          tool=`basename $tool_path` \
       && update-alternatives --install /usr/bin/$tool $tool $tool_path 10000 \
       && update-alternatives --set $tool $tool_path; \
    done


USER node

ENV WEB_SHELL="jshell"

EXPOSE 8088

CMD [ "web-terminal", "--port", "8088" ]
