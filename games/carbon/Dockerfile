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

####
# Multi-stage build to minimize final image size
####

# Builder stage: compile LD_PRELOAD shim
FROM debian:bookworm-slim AS builder
ENV         DEBIAN_FRONTEND=noninteractive
RUN         apt-get update \
            && apt-get install -y --no-install-recommends gcc libc6-dev ca-certificates \
            && rm -rf /var/lib/apt/lists/*
COPY        ./shims /shims
RUN         mkdir -p /out \
            && gcc -shared -fPIC -O2 -o /out/libkeepstdio.so /shims/keepstdio.c -ldl \
            && strip /out/libkeepstdio.so

# Final stage
FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="SturdyStubs" maintainer="BippyMiester"
LABEL       org.opencontainers.image.source="https://github.com/SturdyStubs/pterodactyl-images"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies (no dev toolchain)
RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get install -y --no-install-recommends \
                ca-certificates \
                curl \
                iproute2 \
                tzdata \
                libgdiplus \
                util-linux \
                libsdl2-2.0-0:i386 \
                lib32gcc-s1 \
                lib32stdc++6 \
                gnupg \
            && rm -rf /var/lib/apt/lists/*

# Install Node.js 20.x via NodeSource (clean up after)
RUN         set -eux; \
            curl -fsSL https://deb.nodesource.com/setup_20.x -o /tmp/nodesource_setup.sh; \
            bash /tmp/nodesource_setup.sh; \
            apt-get update; \
            apt-get install -y --no-install-recommends nodejs; \
            rm -f /tmp/nodesource_setup.sh; \
            apt-get purge -y --auto-remove gnupg; \
            rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy LD_PRELOAD shim from builder
COPY        --from=builder /out/libkeepstdio.so /usr/local/lib/libkeepstdio.so

# Install ws via npm into /node_modules without using --prefix to avoid npm tracker issues
RUN         set -eux; \
            mkdir -p /node_modules /tmp/ws; \
            cd /tmp/ws; \
            npm init -y > /dev/null 2>&1; \
            npm install --omit=dev --no-audit --no-fund --loglevel=error ws; \
            mv node_modules/ws /node_modules/; \
            cd /; \
            rm -rf /tmp/ws; \
            npm cache clean --force

# Define user environment
RUN         useradd -d /home/container -m container
USER        container
ENV         USER=container HOME=/home/container

# Workdir inside the container
WORKDIR     /home/container

# Copy runtime files
COPY        ./wrapper.js /wrapper.js
COPY        ./entrypoint.js /entrypoint.js
COPY        ./js /js

CMD         [ "node", "/entrypoint.js" ]
