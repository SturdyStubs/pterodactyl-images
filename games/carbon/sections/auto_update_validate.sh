#!/bin/bash

################################
# STEAMCMD DOWNLOAD GAME FILES #
################################
# We need to source this file first before we do any auto update or validation logic

if [ -f /helpers/steamcmd.sh ]; then
  Debug "/helpers/steamcmd.sh exists and is found!"
  # Directly run the script without chmod
  source /helpers/steamcmd.sh
else
  Error "/helpers/steamcmd.sh does not exist or cannot be found." "1"
fi

###################################
# HANDLE AUTO UPDATE / VALIDATION #
###################################

source /helpers/messages.sh

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside /sections/auto_update_validate.sh file!"

Info "Handling Auto Update and Validation..."

# If the switch is occurring from oxide to rust, we want to validate all the steam files first before
# downloading carbon every time. Force validation. This will remove all references to oxide in the files.
if [[ "${CARBONSWITCH}" == "TRUE" ]]; then
    Info "Carbon Switch Detected!"
    Info "Forcing validation of game server..."
    # Go to this function
    SteamCMD_Validate
elif [[ "${FRAMEWORK}" == "vanilla" ]]; then
    Info "Vanilla framework detected!"
    Info "Forcing validation of game server..."
    SteamCMD_Validate
elif [[ "${AUTO_UPDATE}" == "1" ]]; then # Else, we're going to handle the auto update. If the auto update is set to true, or is null or doesn't exist
    
    # Check if we're going to validate after updating
    if [ "${VALIDATE}" == "1" ]; then
        # If VALIDATE set to true, validate game server via this function
        SteamCMD_Validate
    else
        # Else don't validate via this function
        SteamCMD_No_Validation
    fi
else
    # Else don't update or validate server
    Warn "Not updating server, auto update set to false."
fi