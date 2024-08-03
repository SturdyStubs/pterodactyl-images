########################
#  APP PUBLIC IP FIX   #
########################

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`

# Grab the public IP address of the node
PUBLIC_IP=$(curl -sS ifconfig.me)

printf "${BLUE}Setting App Public IP${NC}"
echo "Internal IP: ${INTERNAL_IP}"
echo "Public IP: ${PUBLIC_IP}"
# If there is no app public ip set then set it to the public IP address of the node
if [ -z ${APP_PUBLIC_IP} ]; then
    echo "Setting APP_PUBLIC_IP address to the public IP address of the node."
    APP_PUBLIC_IP=${PUBLIC_IP}
# Otherwise the person did set the app public IP, so warn them that this could be dangerous.
else
    printf "${YELLOW}You did not leave the APP_PUBLIC_IP variable blank. Lets hope you know what you're doing!${NC}"
fi
# Display what the App Public IP is set to
printf "${BLUE}App Public IP set to: ${APP_PUBLIC_IP}${NC}"
printf "${GREEN}App Public IP check successful!${NC}"