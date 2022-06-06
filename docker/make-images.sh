#!/bin/sh

cd ipv6-base

sudo docker build -t ipv6-base:latest .

cd ..

cd wasp-base

git clone https://github.com/iotaledger/wasp.git
cd wasp
rm Dockerfile
cp ../Dockerfile Dockerfile

sudo docker build -t wasp-base:latest .

cd ../..

#cd goshimmer-base

#DOCKER_BUILDKIT=1 docker build -t goshimmer-base .

#cd ..

#cd ipv6-goshimmer-node

#docker build -t ipv6-goshimmer-node:latest .

#cd ..

cd ipv6-client

sudo docker build -t ipv6-node:latest .

cd ..

cd gateway-base

sudo docker build -t gateway-base:latest .

cd ..

cd ipv6-gateway

sudo docker build -t ipv6-gateway:latest .

cd ..

cd ipv6-router

sudo docker build -t ipv6-router:latest .

cd ..

#cd ipv6-server

#sudo docker build -t ipv6-server:latest .

#cd ..

cd ipv6-rpc

sudo docker build -t ipv6-rpc:latest .

cd ..