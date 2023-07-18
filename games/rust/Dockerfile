FROM --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL author="Isaac A." maintainer="isaac@isaacs.site"

LABEL org.opencontainers.image.source="https://github.com/pterodactyl/yolks"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive

# Enable multiarch support
RUN dpkg --add-architecture i386

# Update and install required packages
RUN apt update && apt upgrade -y \
    && apt install -y lib32gcc-s1 lib32stdc++6 unzip curl iproute2 tzdata libgdiplus libsdl2-2.0-0:i386 jq sed wget

# Install Node.js
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - \
    && apt install -y nodejs

# Create a directory for Node.js modules
RUN mkdir /node_modules

# Install 'ws' module
RUN npm install --prefix /node_modules ws

# Create the 'container' user and set the working directory
RUN useradd -d /home/container -m container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Copy the necessary files
COPY ./entrypoint.sh /entrypoint.sh
COPY ./wrapper.js /wrapper.js

# Set the default command
CMD ["/bin/bash", "/entrypoint.sh"]
