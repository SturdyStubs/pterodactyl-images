FROM node:latest

LABEL author="Isaac A." maintainer="isaac@isaacs.site"

LABEL org.opencontainers.image.source="https://github.com/pterodactyl/yolks"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive

# Install required dependencies for i386 architecture
RUN dpkg --add-architecture i386 \
    && apt update \
    && apt upgrade -y \
    && apt install -y lib32gcc-s1 lib32stdc++6 unzip curl iproute2 tzdata libgdiplus libsdl2-2.0-0:i386

# Install Node.js and npm
RUN apt install -y nodejs \
    && mkdir /node_modules \
    && npm install --prefix / ws

# Create a non-root user for running the application
RUN useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container

WORKDIR /home/container

COPY ./entrypoint.sh /entrypoint.sh
COPY ./wrapper.js /wrapper.js

CMD [ "/bin/bash", "/entrypoint.sh" ]

