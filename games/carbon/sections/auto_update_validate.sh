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

##############################################
# SET DEFAULT DOWNLOAD METHOD IF NOT DEFINED #
##############################################

if [ -z "${DOWNLOAD_METHOD}" ]; then
    Warn "DOWNLOAD_METHOD variable not found. Update your egg at https://github.com/SturdyStubs/AIO.Egg. Defaulting to SteamCMD..."
    DOWNLOAD_METHOD="SteamCMD"
else
    echo "DOWNLOAD_METHOD is set to '${DOWNLOAD_METHOD}'."
fi

#######################################
# CHECK AND INSTALL DEPOTDOWNLOADER IF NEEDED #
#######################################

if [[ "${DOWNLOAD_METHOD}" == "Depot Downloader" ]]; then
    # Check if ./DepotDownloader already exists
    if [ -f /home/container/DepotDownloader ]; then
        echo "DepotDownloader found. Skipping installation."
    else
        echo "DepotDownloader not found. Installing DepotDownloader..."
        # Create a temporary directory for download
        cd /tmp
        # Download DepotDownloader from the provided URL
        curl -sSL -o DepotDownloader.zip https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_2.6.0/DepotDownloader-linux-x64.zip
        # Unzip the DepotDownloader package to /home/container
        unzip DepotDownloader.zip -d /home/container
        # Navigate to the DepotDownloader directory
        rm -rf /tmp/*
        chmod +x /home/container/DepotDownloader
        echo "DepotDownloader installation completed successfully."
    fi
else
    echo "Depot Downloader method not selected. Skipping installation."
fi

#######################################################
# CLEAN RUSTDEDICATED_DATA FOLDER OF OXIDE EXTENSIONS #
#######################################################

if [ -f /helpers/clean_rustdedicated.sh ]; then
  Debug "/helpers/clean_rustdedicated.sh exists and is found!"
  # Directly run the script without chmod
  source /helpers/clean_rustdedicated.sh
else
  Error "/helpers/clean_rustdedicated.sh does not exist or cannot be found." "1"
fi

###################################
# HANDLE AUTO UPDATE / VALIDATION #
###################################

source /helpers/messages.sh

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside /sections/auto_update_validate.sh file!"

echo "Handling Auto Update and Validation..."

# If the switch is occurring from oxide to rust, we want to validate all the steam files first before
# downloading carbon every time. Force validation. This will remove all references to oxide in the files.
if [[ "${DOWNLOAD_METHOD}" == "SteamCMD" ]]; then
    if [[ "${CARBONSWITCH}" == "TRUE" ]]; then
        Info "Carbon Switch Detected!"
        Info "Forcing validation of game server..."
        # Go to this function
        SteamCMD_Validate
        Clean_RustDedicated
    elif [[ "${FRAMEWORK}" =~ "vanilla"]]; then
        Info "Vanilla or Vanilla-Staging framework detected!"
        Info "Forcing validation of game server..."
        SteamCMD_Validate
        Clean_RustDedicated
    elif [[ "${AUTO_UPDATE}" == "1" ]]; then
        # Else, we're going to handle the auto update. If the auto update is set to true, or is null or doesn't exist
        # Check if we're going to validate after updating
        if [ "${VALIDATE}" == "1" ]; then
            # If VALIDATE set to true, validate game server via this function
            SteamCMD_Validate
        else
            # Else don't validate via this function
            SteamCMD_No_Validation
        fi
    fi
else
    # Else don't update or validate server
    Warn "Not updating server, auto update set to false."
fi

if [[ "${DOWNLOAD_METHOD}" == "Depot Downloader" ]]; then
    if [[ "${CARBONSWITCH}" == "TRUE" ]]; then
        Info "Carbon Switch Detected!"
        Info "Forcing validation of game server..."
        # Go to this function
        DepotDownloader_Validate
        Clean_RustDedicated
    elif [[ "${FRAMEWORK}" =~ "vanilla"]]; then
        Info "Vanilla or Vanilla-Staging framework detected!"
        Info "Forcing validation of game server..."
        DepotDownloader_Validate
        Clean_RustDedicated
    elif [[ "${AUTO_UPDATE}" == "1" ]]; then
        # Else, we're going to handle the auto update. If the auto update is set to true, or is null or doesn't exist
        # Check if we're going to validate after updating
        if [ "${VALIDATE}" == "1" ]; then
            # If VALIDATE set to true, validate game server via this function
            DepotDownloader_Validate
        else
            # Else don't validate via this function
            DepotDownloader_No_Validation
        fi
    fi
else
    # Else don't update or validate server
    Warn "Not updating server, auto update set to false."
fi
