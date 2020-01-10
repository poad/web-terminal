ARG BASE_IMAGE="lts-buster-slim"

FROM node:${BASE_IMAGE}

USER root

RUN apt-get update -qq \
 && apt-get install -qqy --no-install-recommends curl \
 && apt-get clean -qq \
 && npm install web-terminal -g \
 && rm -rf /var/lib/apt/lists/* /tmp/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog

ENV WEB_SHELL="bash"

USER node

EXPOSE 8088

CMD [ "web-terminal", "--port", "8088" ]
