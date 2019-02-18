FROM alpine:latest
# docker run --rm -ti --net=host --ipc=host --pid=host --privileged --name test alpine:latest

ENV LINUX_DASH_SERVER_PORT 8081
EXPOSE 8081

WORKDIR /
RUN apk add --no-cache git nodejs nodejs-npm netcat-openbsd

RUN git clone --depth 1 https://github.com/afaqurk/linux-dash.git

WORKDIR /linux-dash/app/server
RUN npm install --production

CMD ["node", "index.js"]