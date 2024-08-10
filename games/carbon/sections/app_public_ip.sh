#!/bin/bash

source /helpers/messages.sh

########################
#  APP PUBLIC IP FIX   #
########################

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside /sections/app_public_ip.sh file!"

Info "Setting App Public IP"

# Make internal Docker IP address available to processes.
Debug "Making interal Docker IP address available to processes..."
export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`

# Grab the public IP address of the node
Debug "Grabbing the public IP address of the node"
PUBLIC_IP=$(curl -sS ifconfig.me)

Debug "Internal IP: ${INTERNAL_IP}"
Debug "Public IP: ${PUBLIC_IP}"

# If there is no app public ip set then set it to the public IP address of the node
if [ -z ${APP_PUBLIC_IP} ]; then
    Info "Setting APP_PUBLIC_IP address to the public IP address (${PUBLIC_IP}) of the node."
    APP_PUBLIC_IP=${PUBLIC_IP}
# Otherwise the person did set the app public IP, so warn them that this could be dangerous.
else
    Warn "You did not leave the APP_PUBLIC_IP variable blank. Lets hope you know what you're doing!"
fi

# Display what the App Public IP is set to
Info "App Public IP set to: ${APP_PUBLIC_IP}"

Success "App Public IP check successful!"