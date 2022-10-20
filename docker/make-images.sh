#!/bin/sh

cd base

sudo docker build -t base:latest .

cd ..

cd wasp-base

#git clone -b stardust-vm-nodeconn --single-branch https://github.com/iotaledger/wasp.git
git clone https://github.com/iotaledger/wasp.git
git checkout -b develop a2b2c94d4dea8e2322bc81b6961f608d37441773
cp Dockerfile wasp/Dockerfile
cd wasp

sudo docker build -t wasp-base:latest .

cd ..

sudo rm -rf wasp

cd ..

cd goshimmer

git clone https://github.com/lmoe/goshimmer.git

cp Dockerfile goshimmer/Dockerfile
cp goshimmer.config.json goshimmer/config.default.json
cp snapshot.bin goshimmer/snapshot.bin
cp init goshimmer/init

cd goshimmer

sudo DOCKER_BUILDKIT=1 docker build -t goshimmer:corenode .

cd ..

sudo rm -rf goshimmer

cd ..

cd wasp

sudo docker build -t node:latest .

cd ..

cd gateway-base

sudo docker build -t gateway-base:latest .

cd ..

cd gateway

sudo docker build -t gateway:latest .

cd ..

cd router

sudo docker build -t router:latest .

cd ..

cd rpc

sudo docker build -t rpc:latest .

cd ..