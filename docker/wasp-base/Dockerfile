ARG GOLANG_IMAGE_TAG=1.17-buster

# Build stage
FROM golang:${GOLANG_IMAGE_TAG} AS build
ARG BUILD_TAGS="rocksdb,builtin_static"
ARG BUILD_LD_FLAGS=""
ARG BUILD_TARGET="./..."

WORKDIR /wasp

# Make sure that modules only get pulled when the module file has changed
COPY go.mod go.sum ./
RUN go mod download
RUN go mod verify

# Project build stage
COPY . .

RUN go build -o . -tags=${BUILD_TAGS} -ldflags="${BUILD_LD_FLAGS}" ${BUILD_TARGET}

# Wasp build
FROM ipv6-base

RUN apt-get update -y
RUN apt-get install build-essential software-properties-common -y
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y
RUN apt-get update -y
RUN apt-get install gcc-8 g++-8 -y
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 60 --slave /usr/bin/g++ g++ /usr/bin/g++-8
RUN update-alternatives --config gcc
RUN apt-get install jq -y

ARG WASP="wasp"
ARG WASP_CLI="wasp-cli"

EXPOSE 7000/tcp
EXPOSE 9090/tcp
EXPOSE 5550/tcp
EXPOSE 4000/udp

EXPOSE 8545/tcp

COPY --from=build /wasp/${WASP} /usr/bin/
COPY --from=build /wasp/${WASP_CLI} /usr/bin/
COPY docker_config.json /etc/wasp_config.json
