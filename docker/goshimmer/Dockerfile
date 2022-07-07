# syntax = docker/dockerfile:1.2.1

############################
# golang 1.17.2-buster multi-arch
FROM golang@sha256:5b036db95aaf91b8c75be815e2ba0ca0eecbfc3f57952c24c5d8c125970e2634 AS build

ARG BUILD_TAGS=rocksdb,builtin_static
# Download and include snapshot into resulting image by default.
ARG DOWNLOAD_SNAPSHOT=1

# Ensure ca-certficates are up to date
RUN update-ca-certificates

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
# 2. Mount the build cache volume
# 3. Build the binary
# 4. Verify that goshimmer binary is statically linked
RUN --mount=target=. \
    --mount=type=cache,target=/root/.cache/go-build \
    go build \
    -tags="$BUILD_TAGS" \
    -ldflags='-w -s' \
    -o /go/bin/goshimmer

# Enable building the image without downloading the snapshot.
# If built with dummy snapshot then a snapshot needs to be mounted into the resulting image.
RUN if [ $DOWNLOAD_SNAPSHOT -gt 0 ]; then \
    wget -O /tmp/snapshot.bin https://dbfiles-goshimmer.s3.eu-central-1.amazonaws.com/snapshots/nectar/snapshot-latest.bin ;  \
    else  \
    touch /tmp/snapshot.bin ; \
    fi

############################
# Image
############################
# https://github.com/GoogleContainerTools/distroless/tree/master/cc
# using distroless cc image, which includes everything in the base image (glibc, libssl and openssl)
#FROM gcr.io/distroless/cc@sha256:4cad7484b00d98ecb300916b1ab71d6c71babd6860c6c5dd6313be41a8c55adb

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
RUN apt-get install jq -y


EXPOSE 1888/tcp 
# Analysis Server (within Docker network)

EXPOSE 5000/tcp
# TXStream

EXPOSE 8080/tcp
# GoShimmer API

EXPOSE 8081/tcp
# GoShimmer Dashboard

EXPOSE 9000/tcp
# Analysis Dashboard

EXPOSE 9312/tcp
# Prometheus

# Copy configuration
COPY snapshot.bin /snapshot.bin
COPY config.default.json /config.json

# Copy the Pre-built binary file from the previous stage
COPY --from=build /go/bin/goshimmer /run/goshimmer

COPY init ./init

RUN chmod +x init

ENTRYPOINT ["./init"]