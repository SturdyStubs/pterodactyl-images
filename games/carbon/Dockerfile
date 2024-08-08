#
# Copyright (c) 2021 Pterodactyl
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

FROM        --platform=$TARGETOS/$TARGETARCH debian:12.6-slim

LABEL       author="SturdyStubs" maintainer="BippyMiester"

LABEL       org.opencontainers.image.source="https://github.com/SturdyStubs/pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

WORKDIR		/

# Install Dependancies
RUN         dpkg --add-architecture i386 \
            && apt update \
            && apt upgrade -y \
            && apt install -y lib32gcc-s1 lib32stdc++6 unzip curl iproute2 tzdata libgdiplus libsdl2-2.0-0:i386

# Install NodeJS
ENV 		NODE_VERSION=16.13.0
RUN 		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
ENV 		NVM_DIR=/root/.nvm
RUN 		. "$NVM_DIR/nvm.sh" && nvm install ${NODE_VERSION}
RUN 		. "$NVM_DIR/nvm.sh" && nvm use v${NODE_VERSION}
RUN 		. "$NVM_DIR/nvm.sh" && nvm alias default v${NODE_VERSION}
ENV 		PATH="/root/.nvm/versions/node/v${NODE_VERSION}/bin/:${PATH}"

# Handle NPM Installs
RUN			mkdir /node_modules \
            && npm install --prefix / ws \
            && useradd -d /home/container -m container

USER        container
ENV         USER=container HOME=/home/container

WORKDIR     /home/container

COPY        ./wrapper.js /wrapper.js
COPY        ./entrypoint.sh /entrypoint.sh
COPY        --chmod=0755 ./splash_screen.sh /splash_screen.sh
COPY        --chmod=0755 ./end_screen.sh /end_screen.sh

COPY        --chmod=0755 ./sections /sections
COPY        --chmod=0755 ./helpers /helpers

CMD         [ "/bin/bash", "/entrypoint.sh" ]
