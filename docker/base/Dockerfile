FROM ubuntu:focal

RUN apt-get update

# Prepare environment
RUN apt-get -y install locales
RUN locale-gen en_US.UTF-8 
ENV LANG en_US.UTF-8  
ENV LANGUAGE en_US:en  
ENV LC_ALL en_US.UTF-8

RUN apt-get update && \
    apt-get install -yq tzdata && \
    ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Install required packages
RUN apt-get install -y git g++ make openssl libssl-dev
RUN apt-get install -y libprotobuf-dev protobuf-compiler
RUN apt-get install -y swig
RUN apt-get install -y netcat
RUN apt-get install -y rsyslog


# Install tools
RUN apt-get install -y net-tools
RUN apt-get install -y iputils-ping
RUN apt-get install -y traceroute
RUN apt-get install -y iptables
RUN apt-get install -y bc
RUN apt-get install jq -y
