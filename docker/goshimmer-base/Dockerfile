# syntax = docker/dockerfile:1.2.1

############################
# golang 1.18-bullseye multi-arch
FROM golang:1.18.1-bullseye AS build

ARG RUN_TEST=0
ARG BUILD_TAGS=rocksdb

# Download and include snapshot into resulting image by default.
ARG DOWNLOAD_SNAPSHOT=1

# Ensure ca-certficates are up to date
RUN update-ca-certificates

RUN if [ $RUN_TEST -gt 0 ]; then \
    set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends libgflags-dev libsnappy-dev zlib1g-dev libbz2-dev liblz4-dev libzstd-dev ; \
    fi

# Set the current Working Directory inside the container
RUN mkdir /goshimmer
WORKDIR /goshimmer

# Use Go Modules
COPY go.mod .
COPY go.sum .

ENV GO111MODULE=on
RUN go mod download
RUN go mod verify

# 1. Mount everything from the current directory to the PWD(Present Working Directory) inside the container
# 2. Mount the testing cache volume
# 3. Run unittests
RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    if [ $RUN_TEST -gt 0 ]; then \
    go test ./... -tags rocksdb -count=1; \
    fi

# 1. Mount everything from the current directory to the PWD(Present Working Directory) inside the container
# 2. Mount the build cache volume
# 3. Build the binary
RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    go build \
    -tags="$BUILD_TAGS" \
    -ldflags='-w -s' \
    -o /go/bin/goshimmer;

# Docker cache will be invalidated for RUNs after ARG definition (https://docs.docker.com/engine/reference/builder/#impact-on-build-caching)
ARG DEFAULT_SNAPSHOT_URL=https://dbfiles-goshimmer.s3.eu-central-1.amazonaws.com/snapshots/nectar/snapshot-latest.bin
ARG CUSTOM_SNAPSHOT_URL

# Enable building the image without downloading the snapshot.
# It's possible to download custom snapshot from external storage service - necessary for feature network deployment.
# If built with dummy snapshot then a snapshot needs to be mounted into the resulting image.
RUN if [ "$DOWNLOAD_SNAPSHOT" -gt 0 ] && [ "$CUSTOM_SNAPSHOT_URL" = "" ] ; then \
      wget -O /tmp/snapshot.bin $DEFAULT_SNAPSHOT_URL;  \
    elif [ "$DOWNLOAD_SNAPSHOT" -gt 0 ] && [ "$CUSTOM_SNAPSHOT_URL" != "" ]; then \
      apt update; apt install -y gawk; \
      git clone https://github.com/ffluegel/zippyshare.git; \
      cd zippyshare; \
      ./zippyshare.sh "$CUSTOM_SNAPSHOT_URL"; \
      SNAPSHOT_FILE=$(ls -t *.bin | head -1); \
      mv "$SNAPSHOT_FILE" /tmp/snapshot.bin; \
    else  \
      touch /tmp/snapshot.bin ; \
    fi

RUN mkdir -p /tmp/db/devnetdb /tmp/db/peerdb
# 65532:65532 is the UID:GUID of nonroot user of distroless image
# RUN chown 65532:65532 /tmp/db/devnetdb /tmp/db/peerdb

############################
# Image
############################
# https://github.com/GoogleContainerTools/distroless/tree/master/cc
# using distroless cc image, which includes everything in the base image (glibc, libssl and openssl)
#FROM gcr.io/distroless/cc-debian11:nonroot as prepare-runtime
FROM ubuntu:focal

RUN apt-get update

# Prepare environment
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8  
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

# Install required packages
RUN apt-get install -y git g++ make openssl libssl-dev
RUN apt-get install -y libprotobuf-dev protobuf-compiler
RUN apt-get install -y swig
RUN apt-get install -y netcat
RUN apt-get install -y rsyslog


# Install tools
RUN apt install -y iproute2
RUN apt-get install -y net-tools
RUN apt-get install -y iputils-ping
RUN apt-get install -y traceroute
RUN apt-get install -y iptables
RUN apt-get install -y bc

# Gossip
EXPOSE 14666/tcp
# AutoPeering
EXPOSE 14626/udp
# Pprof Profiling
EXPOSE 6061/tcp
# Prometheus exporter
EXPOSE 9311/tcp
# Webapi
EXPOSE 8080/tcp
# Dashboard
EXPOSE 8081/tcp
# DAGs Visualizer
EXPOSE 8061/tcp
# TX Stream
EXPOSE 5000/tcp

# Default directory and drop privileges
WORKDIR /app

# Copy the Pre-built binary file from the previous stage
COPY --from=build /go/bin/goshimmer /app/goshimmer
RUN chmod +x goshimmer

# Copy configuration and snapshot from the previous stage
COPY config.default.json /app/config.json
#COPY --from=build /tmp/snapshot.bin /app/snapshot.bin
COPY snapshotTest.bin /app/snapshot.bin
RUN chmod 777 snapshot.bin

# Fix permission issue when mounting volumes
COPY --from=build /tmp/db/ /app/
RUN chmod -R 777 /app/