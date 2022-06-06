FROM ipv6-base

# Install Java to run Cooja
RUN apt-get -y install ant openjdk-8-jdk

# Install tools to build msp430 moto firmware
RUN apt-get -y install binutils-msp430 gcc-msp430 msp430mcu gcc-avr avr-libc msp430-libc

# Install wget to download IP list from the Border Router
RUN apt-get -y install wget

# Clone Contiki repository
RUN git clone -b release-2-7 https://github.com/contiki-os/contiki.git 

RUN apt update
RUN apt install build-essential zlib1g-dev libncurses5-dev libgdbm-dev libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev wget libbz2-dev -y

# Copy build script
COPY make-gateway ./make-gateway

# Run build script 
RUN ./make-gateway

# Copy Cooja Project
COPY xia-ipv6-rpl-udp.csc ./xia-ipv6-rpl-udp.csc
