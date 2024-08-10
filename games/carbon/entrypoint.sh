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

<<<<<<< HEAD
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
 if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ] && [ "${VALIDATE}" == "0" ]; then
	./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 +quit
elif
    [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ] && [ "${VALIDATE}" == "1" ]; then
	./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate +quit
else
    echo -e "Auto update set to false. Not validating game files or updating game."
    echo -e "${BLUE}Starting server..."
=======
if [ -f /sections/app_public_ip.sh ]; then
  Debug "/sections/app_public_ip.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/app_public_ip.sh
else
  Error "/sections/app_public_ip.sh does not exist or cannot be found." "1"
>>>>>>> 33fb0a38dcde3494f5d004fae40484c072f9be98
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

####################################
# UPDATE OXIDE / CARBON FRAMEWORKS #
####################################

# We need to grab the modding_root_update function out of this helper file first
if [ -f /helpers/modding_root_update.sh ]; then
  Debug "/helpers/modding_root_update.sh exists and is found!"
  # Directly run the script without chmod
  source /helpers/modding_root_update.sh
else
  Error "/helpers/modding_root_update.sh does not exist or cannot be found." "1"
fi

# Update Oxide First
# It will continue on automatically if oxide is not the framework being used!
if [ -f /sections/update_oxide.sh ]; then
  Debug "/sections/update_oxide.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/update_oxide.sh
else
  Error "/sections/update_oxide.sh does not exist or cannot be found." "1"
fi

# Update Carbon Next
if [ -f /sections/update_carbon.sh ]; then
  Debug "/sections/update_carbon.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/update_carbon.sh
else
  Error "/sections/update_carbon.sh does not exist or cannot be found." "1"
fi

########################
# EXTENSION DOWNLOADER #
########################

# If the framework isn't vanilla
if [[ ${FRAMEWORK} != "vanilla" ]]; then
    # Handle the extension downloads
    if [ -f /sections/extension_download.sh ]; then
      Debug "/sections/extension_download.sh exists and is found!"
      # Directly run the script without chmod
      source /sections/extension_download.sh
    else
      Error "/sections/extension_download.sh does not exist or cannot be found." "1"
    fi
else # The framework is vanilla
    Info "Skipping Extension Downloads, Vanilla Framework Detected!"
fi

# Fix for Rust not starting
Debug "Defining the Library Path..."
export LD_LIBRARY_PATH=$(pwd)/RustDedicated_Data/Plugins/x86_64:$(pwd)

# Display Ending Splash Screen
/bin/bash /end_screen.sh

# Run the Server
node /wrapper.js "${MODIFIED_STARTUP}"