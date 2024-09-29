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

##################
# LOG FILE CHECK #
##################

if [ -f /sections/log_file.sh ]; then
  Debug "/sections/log_file.sh exists and is found!"
  # Directly run the script without chmod
  source /sections/log_file.sh
else
  Error "/sections/log_file.sh does not exist or cannot be found." "1"
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