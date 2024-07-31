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

# Grab the public IP address of the node
PUBLIC_IP=$(curl -sS ifconfig.me)

printf "╭──────────────────────────────────────────────────╮\n"
printf "│                 AIO RUST EGG                     │\n"
printf "│            Created By: SturdyStubs               │\n"
printf "├──────────────────────────────────────────────────┤\n"
printf "│    For More Information See The Documentation    │\n"
printf "│        https://tinyurl.com/aiorustegg            │\n"
printf "╰──────────────────────────────────────────────────╯\n"

printf "${BLUE}Starting Egg Now!${NC}"
sleep 2


########################
#  APP PUBLIC IP FIX   #
########################
printf "${BLUE}Setting App Public IP${NC}"
echo "Internal IP: ${INTERNAL_IP}"
echo "Public IP: ${PUBLIC_IP}"
if [ -z ${APP_PUBLIC_IP} ]; then
    echo "Setting APP_PUBLIC_IP address to the public IP address of the node."
    APP_PUBLIC_IP=${PUBLIC_IP}
else
    printf "${YELLOW}You did not leave the APP_PUBLIC_IP variable blank. Lets hope you know what you're doing!${NC}"
fi
printf "${BLUE}App Public IP set to: ${APP_PUBLIC_IP}${NC}"
printf "${GREEN}App Public IP check successful!${NC}"

echo "Modding Framework is set to: ${FRAMEWORK}"

###########################################
# MODDING ROOT FOLDER COMPATIBILITY CHECK #
###########################################

echo "Checking MODDING ROOT DIRECTORY folder compatibility with selected framework"

if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
    DEFAULT_DIR="carbon"
elif [[ "${FRAMEWORK}" =~ "oxide" ]]; then
    DEFAULT_DIR="oxide"
fi

# Check if the MODDING_ROOT directory is DEFAULT_DIR, if not then create new directory with specified name of MODDING_ROOT
if [[ "${FRAMEWORK}" =~ "carbon" || "${FRAMEWORK}" =~ "oxide" ]]; then
    if [[ "${MODDING_ROOT}" != "${DEFAULT_DIR}" ]]; then
        echo "MODDING ROOT DIRECTORY set to '${MODDING_ROOT}' for framework '${FRAMEWORK}'."

        if [[ ! -d "$MODDING_ROOT" ]]; then
            mkdir -p /home/container/${MODDING_ROOT}
            echo "Creating directory named ${MODDING_ROOT}..."
            
            if [[ $? -ne 0 ]]; then
                printf "${RED}ERROR: Failed to create the MODDING ROOT DIRECTORY '${MODDING_ROOT}'. Please check your permissions or the directory path.${NC}\n"
                exit 1
            fi
            
            echo "Successfully created directory named ${MODDING_ROOT}."
        fi
    fi
fi

printf "${GREEN}Compatibility check passed...${NC}"

# Clean Up Files from Oxide to Vanilla/Carbon Switch
if [[ "${FRAMEWORK}" != "oxide" ]] || [[ "${FRAMEWORK}" != "oxide-staging" ]]; then
    printf "${BLUE}Modding framework is not set to Oxide. Checking if there are left over Oxide files in the server.${NC}"
    shopt -s nullglob
    # Check if the Oxide.dll files exist
    files=(/home/container/RustDedicated_Data/Managed/Oxide.*.dll)
    if [ ${#files[@]} -gt 0 ]; then
        echo "Oxide Files Found!"
        if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
            # Check to see if any Oxide extensions need to be moved
            echo "Carbon framework detected! Moving Oxide Extentions if the exist."
            files=(/home/container/RustDedicated_Data/Managed/Oxide.Ext.*.dll)
            if [ ${#files[@]} -gt 0 ]; then
                printf "${BLUE}Oxide extensions located. Moving files to Modding Directory Extensions Folder.${NC}"
                # Create the extensions folder again if it doesn't exist
                mkdir -p /home/container/${MODDING_ROOT}/extensions/
                # Move the files
                mv -v /home/container/RustDedicated_Data/Managed/Oxide.Ext.*.dll /home/container/${MODDING_ROOT}/extensions/
                printf "${GREEN}Move files has completed successfully!${NC}"
            else
                printf "${GREEN}No Oxide Extensions to Move... Skipping the move...${NC}"
            fi
        else
            printf "${YELLOW}${FRAMEWORK} does not support Oxide Extensions. If you see this and your framework isn't vanilla, then contact the developers.${NC}"
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

###############################
# Extensions Download Section #
###############################

function Download_Extensions() {
    printf "${BLUE}Checking Extension Downloads...${NC}"

    # Check if any of the extensions variables are set to true
    if [ "${RUSTEDIT_EXT}" == "1" ] || [ "${DISCORD_EXT}" == "1" ] || [ "${CHAOS_EXT}" == "1" ]; then
        # Make temp directory
        mkdir -p /home/container/temp
        # Download RustEdit Extension
        if [ "${RUSTEDIT_EXT}" == "1" ]; then
            echo -e "Downloading RustEdit Extension"
            curl -sSL -o /home/container/temp/Oxide.Ext.RustEdit.dll https://github.com/k1lly0u/Oxide.Ext.RustEdit/raw/master/Oxide.Ext.RustEdit.dll
            printf "${GREEN}RustEdit Extention Downloaded!${NC}"
        fi

        # Download Discord Extension
        if [ "${DISCORD_EXT}" == "1" ]; then
            echo -e "Downloading Discord Extension"
            curl -sSL -o /home/container/temp/Oxide.Ext.Discord.dll https://umod.org/extensions/discord/download
            printf "${GREEN}Discord Extension Downloaded!${NC}"
        fi

        # Download Chaos Code Extension
        if [ "${CHAOS_EXT}" == "1" ]; then
            echo -e "Downloading Chaos Code Extension"
            curl -sSL -o /home/container/temp/Oxide.Ext.Chaos.dll https://chaoscode.io/oxide/Oxide.Ext.Chaos.dll
            printf "${GREEN}Chaos Code Extension Downloaded!${NC}"
        fi

        # Handle Move of files based on framework
        files=(/home/container/temp/Oxide.Ext.*.dll)
        if [ ${#files[@]} -gt 0 ]; then
            printf "${BLUE}Moving Extensions to appropriate folders...${NC}"
            if [[ ${FRAMEWORK} =~ "carbon" ]]; then
                echo "Carbon framework detected!"
                mv -v /home/container/temp/Oxide.Ext.*.dll /home/container/carbon/extensions/
            fi
            if [[ ${FRAMEWORK} =~ "oxide" ]]; then
                echo "Oxide framework detected!"
                mv -v /home/container/temp/Oxide.Ext.*.dll /home/container/RustDedicated_Data/Managed/
            fi
            printf "${GREEN}Move files has completed successfully!${NC}"
        else
            printf "${GREEN}No Extensions to Move... Skipping the move...${NC}"
        fi

        # Clean up temp folder
        echo "Cleaning up Temp Directory"
        rm -rf /home/container/temp
        printf "${GREEN}Cleanup complete!${NC}"
        printf "${GREEN}All downloads complete!${NC}"
    else
        printf "${GREEN}No extensions are enabled. Skipping this part...${NC}"
    fi
    
}

if [[ ${FRAMEWORK} != "vanilla" ]]; then
    Download_Extensions
else
    printf "${BLUE}Skipping Extension Downloads, Vanilla Framework Detected!${NC}"
fi

# echo -e "IF YOU ARE SEEING THIS, CONTACT THE DEVELOPER TO REMOVE"
# sleep 20

########################
# AUTO UPDATE/VALIDATE #
########################

if [ -z "${AUTO_UPDATE}" ] || [ "${AUTO_UPDATE}" == "1" ]; then
    if [ "${VALIDATE}" == "1" ]; then
        if [ "${FRAMEWORK}" == "oxide-staging" ] || [ "${FRAMEWORK}" == "carbon-staging" ] || [ "${FRAMEWORK}" == "carbon-staging-minimal" ]; then
            echo -e "Validating staging server game files..."
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta staging validate +quit
        elif [ "${FRAMEWORK}" == "carbon-aux1" ] || [ "${FRAMEWORK}" == "carbon-aux1-minimal" ]; then
            echo -e "Validating aux01 server game files..."
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux01 validate +quit
        elif [ "${FRAMEWORK}" == "carbon-aux2" ] || [ "${FRAMEWORK}" == "carbon-aux2-minimal" ]; then
            echo -e "Validating aux02 server game files..."
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux02 validate +quit
        else
            echo -e "Updating game server..."
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate +quit
        fi
    else
        if [ "${FRAMEWORK}" == "oxide-staging" ] || [ "${FRAMEWORK}" == "carbon-staging" ] || [ "${FRAMEWORK}" == "carbon-staging-minimal" ]; then
            echo -e "Updating staging server, not validating..."
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta staging +quit
        elif [ "${FRAMEWORK}" == "carbon-aux1" ] || [ "${FRAMEWORK}" == "carbon-aux1-minimal" ]; then
            echo -e "Updating aux01 server, not validating..."
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux01 +quit
        elif [ "${FRAMEWORK}" == "carbon-aux2" ] || [ "${FRAMEWORK}" == "carbon-aux2-minimal" ]; then
            echo -e "Updating aux02 server, not validating..."
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux02 +quit
        else
            echo -e "Updating game server..."
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 +quit
        fi
    fi
else
    printf "${YELLOW} Not updating server, auto update set to false.${NC}"
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(eval echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Make temp directory
if [[ "${FRAMEWORK}" == *"carbon"* ]]; then
    mkdir -p /home/container/temp
    TEMP_DIR=/home/container/temp
fi

if [[ "$OXIDE" == "1" ]] || [[ "${FRAMEWORK}" == "oxide" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Oxide: https://github.com/OxideMod/Oxide.Rust
        echo "Updating uMod..."
        curl -sSL "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip" > umod.zip
        unzip -o -q umod.zip
        rm umod.zip
        echo "Done updating uMod!\nIf you intend to use a different folder name, you'll need to wait until the server boots and the oxide folder is created to rename it."
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

elif [[ "${FRAMEWORK}" == "oxide-staging" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Oxide: https://github.com/OxideMod/Oxide.Rust
        echo "Updating uMod Staging..."
        curl -sSL "https://downloads.oxidemod.com/artifacts/Oxide.Rust/staging/Oxide.Rust-linux.zip" > umod.zip
        unzip -o -q umod.zip
        rm umod.zip
        echo "Done updating uMod Staging!\nIf you intend to use a different folder name, you'll need to wait until the server boots and the oxide folder is created to rename it."
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi


elif [[ "${FRAMEWORK}" == "carbon" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon.Core/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Minimal.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-edge" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Edge..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Debug.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"
    
elif [[ "${FRAMEWORK}" == "carbon-edge-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Edge Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Minimal.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-staging" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Staging..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Debug.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-staging-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Staging Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Minimal.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-aux1" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Aux1..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Debug.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-aux1-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Aux1 Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Minimal.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-aux2" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Aux2..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Debug.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"

elif [[ "${FRAMEWORK}" == "carbon-aux2-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Aux2 Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Minimal.tar.gz" | tar zx -C "${TEMP_DIR}"
        mv "${TEMP_DIR}/carbon/"* "${MODDING_ROOT}/"
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"
# else Vanilla, do nothing
fi

echo "Removing Temp Directory..."
rm -rf /home/container/temp

# Fix for Rust not starting
export LD_LIBRARY_PATH=$(pwd)/RustDedicated_Data/Plugins/x86_64:$(pwd)

printf "╭──────────────────────────────────────────────────╮\n"
printf "│     Thats it from us! Enjoy your rust server!    │\n"
printf "├──────────────────────────────────────────────────┤\n"
printf "│    For More Information See The Documentation    │\n"
printf "│        https://tinyurl.com/aiorustegg            │\n"
printf "╰──────────────────────────────────────────────────╯\n"

# Run the Server
node /wrapper.js "${MODIFIED_STARTUP}"
