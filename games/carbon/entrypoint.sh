#!/bin/bash

# Display the splash screen
/bin/bash /splash_screen.sh

# Source some files
source /helpers/colors.sh
source /helpers/messages.sh

# Is debug mode enabled? Do you want to see more messages?
if [[ "${EGG_DEBUG}" == "1" ]]; then
    echo "Egg Debug Mode Enabled!"
fi

# Change Directory
cd /home/container

########################
#  APP PUBLIC IP FIX   #
########################

if [ -f /sections/app_public_ip.sh ]; then
  Debug "/sections/app_public_ip.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/app_public_ip.sh
else
  Error "/sections/app_public_ip.sh does not exist or cannot be found." "1"
fi

####################################
# MODDING ROOT FOLDER EXISTS CHECK #
####################################

if [ -f /sections/modding_root_check.sh ]; then
  Debug "/sections/modding_root_check.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/modding_root_check.sh
else
  Error "/sections/modding_root_check.sh does not exist or cannot be found." "1"
fi

################################
# OXIDE -> CARBON SWITCH CHECK #
################################

if [ -f /sections/oxide_carbon_switch.sh ]; then
  Debug "/sections/oxide_carbon_switch.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/oxide_carbon_switch.sh
else
  Error "/sections/oxide_carbon_switch.sh does not exist or cannot be found." "1"
fi

###################################
# HANDLE AUTO UPDATE / VALIDATION #
###################################

if [ -f /sections/auto_update_validate.sh ]; then
  Debug "/sections/auto_update_validate.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/auto_update_validate.sh
else
  Error "/sections/auto_update_validate.sh does not exist or cannot be found." "1"
fi

#############################
# REPLACE STARTUP VARIABLES #
#############################

if [ -f /sections/replace_startup_variables.sh ]; then
  Debug "/sections/replace_startup_variables.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/replace_startup_variables.sh
else
  Error "/sections/replace_startup_variables.sh does not exist or cannot be found." "1"
fi

exit 0

# This function will move the updated managed, native, and tools folders from /carbon into the modding root folder
# This way we don't have to create a temp directory and delete it we're just going to use the /carbon folder as the
# "temp" directory, since it already exists. We also don't want to have repeating code throughout our script,
# and the code is literally going to be the same for each branch of carbon.
function Update_Carbon_Modding_Root() {
    echo "Inside the Update_Carbon_Modding_Root Function"

    # Check what the framework is and define the default root
    if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
        DEFAULT_ROOT="carbon"
    elif [[ "${FRAMEWORK}" =~ "oxide" ]]; then
        DEFAULT_ROOT="oxide"
    fi
    echo "Default Dir: ${DEFAULT_ROOT}"

    # If the modding root doesn't equal the default root, then we must be using a custom modding root. Move the updated files. Handle this for carbon & Oxide
    if [[ "${MODDING_ROOT}" != "${DEFAULT_ROOT}" ]] && [[ "${FRAMEWORK}" =~ "carbon" ]]; then
        echo "Modding root does not match default root - Carbon"
        echo "Creating new directories inside ${MODDING_ROOT} - managed, native, tools"
        # Create Directories
        mkdir -p "/home/container/${MODDING_ROOT}/managed/"
        mkdir -p "/home/container/${MODDING_ROOT}/native/"
        mkdir -p "/home/container/${MODDING_ROOT}/tools/"
        echo "Moving files..."
        # Move shit
        mv -f "/home/container/carbon/managed/"* "/home/container/${MODDING_ROOT}/managed/"
        mv -f "/home/container/carbon/native/"* "/home/container/${MODDING_ROOT}/native/"
        mv -f "/home/container/carbon/tools/"* "/home/container/${MODDING_ROOT}/tools/"
    elif [[ "${MODDING_ROOT}" != "${DEFAULT_ROOT}" ]] && [[ "${FRAMEWORK}" =~ "oxide" ]]; then
        echo "Modding root does not match default root - Oxide"
        # Move shit
        mv -f "/home/container/oxide/"* "/home/container/${MODDING_ROOT}/"
    else
        # Modding folder is the default
        echo "Modding root is the same as default root. Skipping..."
    fi

    echo "Moves complete!"

    # echo "Sleeping for 15 seconds"
    # sleep 15
}

# This is necessary for carbon to run. Put it in a function to reduce repeat code.
function Doorstop_Startup_Carbon() {
    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"
}

#####################
# UPDATE FRAMEWORKS #
#####################

#########
# Oxide #
#########
if [[ "$OXIDE" == "1" ]] || [[ "${FRAMEWORK}" == "oxide" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Oxide: https://github.com/OxideMod/Oxide.Rust
        echo "Updating uMod..."
        curl -sSL "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip" > umod.zip
        unzip -o -q umod.zip
        rm umod.zip
        echo "Done updating uMod!"
        echo "If you intend to use a different folder name, you'll need to wait until the server boots and the oxide folder is created to rename it."
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
        echo "Done updating uMod!"
        echo "If you intend to use a different folder name, you'll need to wait until the server boots and the oxide folder is created to rename it."
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

##########
# Carbon #
##########
elif [[ "${FRAMEWORK}" == "carbon" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon.Core/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon

elif [[ "${FRAMEWORK}" == "carbon-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Minimal.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon

elif [[ "${FRAMEWORK}" == "carbon-edge" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Edge..."
        echo "Modding Root: ${MODDING_ROOT}"
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Debug.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon
    
elif [[ "${FRAMEWORK}" == "carbon-edge-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Edge Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Minimal.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon

elif [[ "${FRAMEWORK}" == "carbon-staging" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Staging..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Debug.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon

elif [[ "${FRAMEWORK}" == "carbon-staging-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Staging Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Minimal.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon

elif [[ "${FRAMEWORK}" == "carbon-aux1" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Aux1..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Debug.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon

elif [[ "${FRAMEWORK}" == "carbon-aux1-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Aux1 Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Minimal.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon

elif [[ "${FRAMEWORK}" == "carbon-aux2" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Aux2..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Debug.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon

elif [[ "${FRAMEWORK}" == "carbon-aux2-minimal" ]]; then
    if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
        # Carbon: https://github.com/CarbonCommunity/Carbon.Core
        echo "Updating Carbon Aux2 Minimal..."
        curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Minimal.tar.gz" | tar zx
        # echo "Sleeping for 15 seconds"
        # sleep 15
        Update_Carbon_Modding_Root
        echo "Done updating Carbon!"
    else
        printf "${RED}Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!${NC}"
    fi

    Doorstop_Startup_Carbon
# else Vanilla, do nothing
fi

########################
# EXTENSION DOWNLOADER #
########################
if [ -f /sections/extension_download.sh ]; then
  Debug "/sections/extension_download.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/extension_download.sh
else
  Error "/sections/extension_download.sh does not exist or cannot be found." "1"
fi

# If the framework isn't vanilla
if [[ ${FRAMEWORK} != "vanilla" ]]; then
    Download_Extensions
else
    printf "${BLUE}Skipping Extension Downloads, Vanilla Framework Detected!${NC}"
fi

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
