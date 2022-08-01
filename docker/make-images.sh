#!/bin/sh

cd ipv6-base

sudo docker build -t ipv6-base:latest .

cd ..

cd wasp-base

git clone https://github.com/iotaledger/wasp.git
cp Dockerfile wasp/Dockerfile
cd wasp

sudo docker build -t wasp-base:latest .

cd ..

rm -rf wasp

cd ..

#cd goshimmer-base

#DOCKER_BUILDKIT=1 docker build -t goshimmer-base .

#cd ..

cd goshimmer

git clone https://github.com/lmoe/goshimmer.git

cp Dockerfile goshimmer/Dockerfile
cp goshimmer.config.json goshimmer/config.default.json
cp snapshot.bin goshimmer/snapshot.bin
cp init goshimmer/init

cd goshimmer

DOCKER_BUILDKIT=1 docker build -t goshimmer:corenode .

cd ..

rm -rf goshimmer

cd ..

#cd ipv6-goshimmer-node

#docker build -t ipv6-goshimmer-node:latest .

#cd ..

cd ipv6-client

sudo docker build -t node:latest .

cd ..

cd gateway-base

sudo docker build -t gateway-base:latest .

cd ..

cd ipv6-gateway

sudo docker build -t gateway:latest .

cd ..

cd ipv6-router

sudo docker build -t router:latest .

cd ..

#cd ipv6-server

#sudo docker build -t ipv6-server:latest .

#cd ..

cd ipv6-rpc

sudo docker build -t rpc:latest .

cd ..