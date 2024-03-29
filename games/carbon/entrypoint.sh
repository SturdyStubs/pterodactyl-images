#!/bin/bash
cd /home/container

# Make internal Docker IP address available to processes.
export INTERNAL_IP=`ip route get 1 | awk '{print $(NF-2);exit}'`

# Check to see if the framework is carbon
if [[ "${FRAMEWORK}" == "carbon" ]]; then
    echo "Carbon framework detected!"
    echo "Checking the carbon root directory"
    if [ -d ${MODDING_ROOT} ]; then
        echo "${MODDING_ROOT} folder already exists... Skipping this part."
    else
        if [ ! -d "carbon" ]; then
            echo "Carbon default root directory folder does not exist. Please change your Modding Root Directory folder name to \"carbon\", and restart your server."
            exit 0
        fi
        echo "${MODDING_ROOT} folder does not exist. Creating new folder..."
        mkdir -p /home/container/${MODDING_ROOT}
        echo "Copying files and folders from default carbon directory."
        cp -r /home/container/carbon/* ${MODDING_ROOT}
        echo "Files copied"
    fi
fi

# Check the framework. If its not oxide, then we must be using carbon or vanilla.
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
        # Check to see if any Oxide extensions need to be moved
        files=(/home/container/RustDedicated_Data/Managed/Oxide.Ext.*.dll)
        if [ ${#files[@]} -gt 0 ]; then
            echo "Moving Oxide Extensions to Carbon/Extensions folder..."
            mv -v /home/container/RustDedicated_Data/Managed/Oxide.Ext.*.dll /home/container/carbon/extensions/
        else
            echo "No Oxide Extensions to Move... Skipping the move..."
        fi
        # Clean up the rust dedicated managed folder
        echo "Cleaning up RustDedicated_Data/Managed folder..."
        rm -rfv RustDedicated_Data/Managed/*
        rm -rfv Oxide.Compiler
    else
        echo "No Oxide files found to remove - continuing startup..."
    fi
    shopt -u nullglob
fi

echo -e "IF YOU ARE SEEING THIS, CONTACT THE DEVELOPER TO REMOVE"
sleep 20

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