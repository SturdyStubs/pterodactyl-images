#!/bin/bash

# Define ANSI escape codes for colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m\n'

cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`

printf "╭───────────────────────────────────────────────╮\n"
printf "│                 AIO RUST EGG                  │\n"
printf "│            Created By: SturdyStubs            │\n"
printf "├───────────────────────────────────────────────┤\n"
printf "│    For More Information See The Documentation │\n"
printf "│        https://tinyurl.com/aiorustegg         │\n"
printf "╰───────────────────────────────────────────────╯\n"


printf "${BLUE}Starting Egg Now!${NC}"
sleep 2

echo "Checking MODDING_ROOT folder compatibility with selected framework"
# Check if carbon framework is being used, and if it is, make sure that the MODDING_ROOT contains the word carbon
if [[ "${FRAMEWORK}" =~ "carbon" ]] && [[ ! "${MODDING_ROOT}" =~ "carbon" ]]; then
    printf "${RED}ERROR: Your framework is ${FRAMEWORK} but your MODDING_ROOT folder does not contain the word \"carbon\". Please change the MODDING_ROOT variable to contain the word \"carbon\" for compatibility reasons.${NC}"
    exit 1
fi

# Do the same for oxide
if [[ "${FRAMEWORK}" =~ "oxide" ]] && [[ ! "${MODDING_ROOT}" =~ "oxide" ]]; then
    printf "${RED}ERROR: Your framework is ${FRAMEWORK} but your MODDING_ROOT folder does not contain the word \"oxide\". Please change the MODDING_ROOT variable to contain the word \"oxide\" for compatibility reasons.${NC}"
    exit 1
fi

printf "${GREEN}Compatibility check passed...${NC}"

# Checking Carbon Root Directory Issues
if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
    echo "Carbon framework detected!"
    echo "Checking the carbon root directory structure..."
    if [ -d ${MODDING_ROOT} ]; then
        printf "${BLUE}${MODDING_ROOT} folder already exists... Skipping this part.${NC}"
    else
        if [ ! -d "carbon" ] && [ "${MODDING_ROOT}" != "carbon" ]; then
            printf "${RED}Carbon default root directory folder does not exist. Please change your Modding Root Directory folder name to \"carbon\", and restart your server.${NC}"
            exit 1
        elif [ ! -d "carbon" ] && [ "${MODDING_ROOT}" == "carbon" ]; then
            print "${YELLOW}${MODDING_ROOT} is set as the MODDING_ROOT folder, however it doesn't exist. It will be created after server validation.${NC}"
        else
            echo "${MODDING_ROOT} folder does not exist. Creating new folder..."
            mkdir -p /home/container/${MODDING_ROOT}
            echo "Copying files and folders from default carbon directory."
            cp -r /home/container/carbon/* ${MODDING_ROOT}
            printf "${GREEN}Files copied. Moving on...${NC}"
        fi
    fi
fi

# Clean Up Files from Oxide to Vanilla/Carbon Switch
if [[ "${FRAMEWORK}" != "oxide" ]]; then
    # Remove files in RustDedicated/Managed if not using Oxide
    echo "Modding Framework is set to: ${FRAMEWORK}"
    echo "Checking if there are left over Oxide files in RustDedicated_Data/Managed"
    mkdir -p /home/container/carbon/extensions/
    shopt -s nullglob
    # Check if the Oxide.dll files exist
    files=(/home/container/RustDedicated_Data/Managed/Oxide.*.dll)
    if [ ${#files[@]} -gt 0 ]; then
        echo "Oxide Files Found! Cleaning Up"
        if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
            # Check to see if any Oxide extensions need to be moved
            files=(/home/container/RustDedicated_Data/Managed/Oxide.Ext.*.dll)
            if [ ${#files[@]} -gt 0 ]; then
                echo "Moving Oxide Extensions to Carbon/Extensions folder..."
                mv -v /home/container/RustDedicated_Data/Managed/Oxide.Ext.*.dll /home/container/${MODDING_ROOT}/extensions/
                printf "${GREEN}Move files has completed successfully!${NC}"
            else
                printf "${GREEN}No Oxide Extensions to Move... Skipping the move...${NC}"
            fi
        else
            echo "${FRAMEWORK} does not support Oxide Extensions. Possibly because the framework is vanilla. If you see this and your framework isn't vanilla, then contact the developers."
        fi
        # Clean up the rust dedicated managed folder
        echo "Cleaning up RustDedicated_Data/Managed folder..."
        rm -rf RustDedicated_Data/Managed/*
        echo "Removing Oxide Compiler..."
        rm -rf Oxide.Compiler
        printf "${GREEN}Oxide files have been cleaned up!${NC}"
    else
        printf "${GREEN}No Oxide files found to remove - continuing startup...${NC}"
    fi
    shopt -u nullglob
fi

#echo -e "IF YOU ARE SEEING THIS, CONTACT THE DEVELOPER TO REMOVE"
#sleep 20

# if auto_update is not set or to 1 update
 if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then
	./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate +quit
else
    echo -e "Not updating game server as auto update was set to 0. Starting Server"
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(eval echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

if [[ "$OXIDE" == "1" ]] || [[ "${FRAMEWORK}" == "oxide" ]]; then
    # Oxide: https://github.com/OxideMod/Oxide.Rust
    echo "Updating uMod..."
    curl -sSL "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip" > umod.zip
    unzip -o -q umod.zip
    rm umod.zip
    echo "Done updating uMod!"

elif [[ "${FRAMEWORK}" == "carbon" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon.Core/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-minimal" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon Minimal..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Minimal.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-edge" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon Edge..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Debug.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"
    
elif [[ "${FRAMEWORK}" == "carbon-edge-minimal" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon Edge Minimal..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Minimal.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-staging" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon Staging..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Debug.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-staging-minimal" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon Staging Minimal..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Minimal.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-aux1" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon Aux1..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Debug.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-aux1-minimal" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon Aux1 Minimal..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Minimal.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-aux2" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon Aux2..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Debug.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-aux2-minimal" ]]; then
    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
    echo "Updating Carbon Aux2 Minimal..."
    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Minimal.tar.gz" | tar zx
    echo "Done updating Carbon!"

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

# else Vanilla, do nothing
fi

# Fix for Rust not starting
export LD_LIBRARY_PATH=$(pwd)/RustDedicated_Data/Plugins/x86_64:$(pwd)

# Run the Server
node /wrapper.js "${MODIFIED_STARTUP}"