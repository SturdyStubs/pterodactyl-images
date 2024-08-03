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
  /bin/bash /sections/app_public_ip.sh
else
  Error "/sections/app_public_ip.sh does not exist or cannot be found." "1"
fi

####################################
# MODDING ROOT FOLDER EXISTS CHECK #
####################################

if [ -f /sections/modding_root_check.sh ]; then
  Debug "/sections/modding_root_check.sh exists and is found!"
  # Directly run the script without chmod
  /bin/bash /sections/modding_root_check.sh
else
  Error "/sections/modding_root_check.sh does not exist or cannot be found." "1"
fi

exit 0

# echo "Sleeping for 10 seconds"
# sleep 10

################################
# OXIDE -> CARBON SWITCH CHECK #
################################

echo "Detecting if there is a oxide to carbon switch occurring...."
# If the framework isn't oxide or oxide staging
if [[ "${FRAMEWORK}" != "oxide" ]] || [[ "${FRAMEWORK}" != "oxide-staging" ]]; then
    printf "${BLUE}Modding framework is not set to Oxide. Checking if there are left over Oxide files in the server.${NC}"

    # Define a bool for later use
    CARBONSWITCH="FALSE"
    
    # Check if the Oxide.*.dll files exist
    shopt -s nullglob # No idea what this does. Just leave it.
    files=(/home/container/RustDedicated_Data/Managed/Oxide.*.dll)
    if [ ${#files[@]} -gt 0 ]; then
        # FOUND EM!
        echo "Oxide Files Found!"

        if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
            # Framework is carbon now, but oxide files were detected in RustDedicated_Data/Managed folder, which means that there is a switch occurring.
            echo "Carbon installation detected. Marking Carbon Switch as TRUE!"
            CARBONSWITCH="TRUE"
        else
            # Since its not oxide, or carbon, must be vanilla
            printf "${YELLOW}If you see this and your framework isn't vanilla, then contact the developers.${NC}"
        fi
    else
        # Must already be on carbon...
        printf "${GREEN}No Oxide files found NOT SWITCHING FROM OXIDE - continuing startup...${NC}"
    fi
    shopt -u nullglob
fi

# echo -e "IF YOU ARE SEEING THIS, CONTACT THE DEVELOPER TO REMOVE"
# echo "Sleeping for 10 seconds"
# sleep 10

########################
# AUTO UPDATE/VALIDATE #
########################

echo "=============================="
echo "CARBONSWITCH: ${CARBONSWITCH}"
echo "=============================="

# Define the steamCMD Validation function
function SteamCMD_Validate_Download() {
    echo "Inside of SteamCMD_Validate_Download()"
    if [[ "${FRAMEWORK}" == *"aux1"* ]]; then
        Delete_SteamApps_Directory
        echo -e "Validating aux01 server game files..."
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux01 validate +quit
    elif [[ "${FRAMEWORK}" == *"aux2"* ]]; then
        Delete_SteamApps_Directory
        echo -e "Validating aux02 server game files..."
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux02 validate +quit
    elif [[ "${FRAMEWORK}" == *"staging"* ]]; then
        Delete_SteamApps_Directory
        echo -e "Validating staging server game files..."
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta staging validate +quit
    else
        Delete_SteamApps_Directory
        echo -e "Updating game server... Validation On!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate +quit
    fi
}

# Define the no validation function
function no_Validate() {
    if [[ "${FRAMEWORK}" == *"staging"* ]]; then
        Delete_SteamApps_Directory
        echo -e "Updating staging server, not validating..."
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta staging +quit
    elif [[ "${FRAMEWORK}" == *"aux1"* ]]; then
        Delete_SteamApps_Directory
        echo -e "Updating aux01 server, not validating..."
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux01 +quit
    elif [[ "${FRAMEWORK}" == *"aux2"* ]]; then
        Delete_SteamApps_Directory
        echo -e "Updating aux02 server, not validating..."
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux02 +quit
    else
        Delete_SteamApps_Directory
        echo -e "Updating game server... Validation Off!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 +quit
    fi
}

# We need to delete the steamapps directory in order to prevent the following error:
# Error! App '258550' state is 0x486 after update job.
# Ref: https://www.reddit.com/r/playark/comments/3smnog/error_app_376030_state_is_0x486_after_update_job/
function Delete_SteamApps_Directory() {
    echo -e "Deleting SteamApps Folder as a precaution"
    rm -rf /home/container/steamapps
}

# If the switch is occurring from oxide to rust, we want to validate all the steam files first before
# downloading carbon every time. Force validation. This will remove all references to oxide in the files.
if [[ "${CARBONSWITCH}" == "TRUE" ]]; then
    echo -e "Carbon Switch Detected!"
    echo -e "Forcing validation of game server..."
    # Go to this function
    SteamCMD_Validate_Download

# Else, we're going to handle the auto update. If the auto update is set to true, or is null or doesn't exist
elif [[ "${AUTO_UPDATE}" == "1" ]]; then
    # If we're going to validate after updating
    if [ "${VALIDATE}" == "1" ]; then
        # If VALIDATE set to true, validate game server via this function
        SteamCMD_Validate_Download
    else
        # Else don't validate via this function
        no_Validate
    fi
else
    # Else don't update or validate server
    printf "${YELLOW} Not updating server, auto update set to false.${NC}"
fi

# echo "Sleeping for 10 seconds"
# sleep 10

# Replace Startup Variables (Keep this here. Important. Forgot exactly what the command does. But here's GPT's interpretation of it)
# https://capture.dropbox.com/amLrR7iuKdJ3kSY6
# Takes the start up command and converts the {{}} into the appropriate bash syntax?
MODIFIED_STARTUP=$(eval echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo ":/home/container$ ${MODIFIED_STARTUP}"

# echo "Sleeping for 10 seconds"
# sleep 10

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

###############################
# Extensions Download Section #
###############################

# Define the function
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
                # Create Carbon Extensions folder in case they want extensions, but also are changing their modding root
                # Prevents this error: mv: target '/home/container/carbon-poop/extensions/' is not a directory
                echo "Making directory /home/container/${MODDING_ROOT}/extensions/"
                mkdir -p "/home/container/${MODDING_ROOT}/extensions/"
                echo "Moving files..."
                mv -v /home/container/temp/Oxide.Ext.*.dll "/home/container/${MODDING_ROOT}/extensions/"
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
