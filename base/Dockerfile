ARG BASE_IMAGE="lts-buster-slim"

FROM node:${BASE_IMAGE}

RUN npm install web-terminal -g

ENV WEB_SHELL="bash"

EXPOSE 8088

CMD [ "web-terminal", "--port", "8088" ]
