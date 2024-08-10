#!/bin/bash

################################
# STEAMCMD DOWNLOAD GAME FILES #
################################

source /helpers/messages.sh

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside /helpers/steamcmd.sh file!"

Info "Sourcing SteamCMD Script..."

# We need to delete the steamapps directory in order to prevent the following error:
# Error! App '258550' state is 0x486 after update job.
# Ref: https://www.reddit.com/r/playark/comments/3smnog/error_app_376030_state_is_0x486_after_update_job/
function Delete_SteamApps_Directory() {
    Debug "Deleting SteamApps Folder as a precaution..."
    rm -rf /home/container/steamapps
}

# Validate when downloading
function SteamCMD_Validate() {
	Debug "Inside Function: SteamCMD_Validate()"

    if [[ "${FRAMEWORK}" == *"aux1"* ]]; then
        Delete_SteamApps_Directory
        Info "Downloading Aux1 Files - Validation On!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux01 validate +quit
    elif [[ "${FRAMEWORK}" == *"aux2"* ]]; then
        Delete_SteamApps_Directory
        Info "Downloading Aux2 Files - Validation On!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux02 validate +quit
    elif [[ "${FRAMEWORK}" == *"staging"* ]]; then
        Delete_SteamApps_Directory
        Info "Downloading Staging Files - Validation On!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta staging validate +quit
    else
        Delete_SteamApps_Directory
        Info "Downloading Default Files - Validation On!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 validate +quit
    fi
}

# Don't validate while downloading
function SteamCMD_No_Validation() {
	Debug "Inside Function: SteamCMD_No_Validation()"

    if [[ "${FRAMEWORK}" == *"aux1"* ]]; then
        Info "Downloading Aux1 Files - Validation Off!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux01 +quit
    elif [[ "${FRAMEWORK}" == *"aux2"* ]]; then
        Info "Downloading Aux2 Files - Validation Off!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta aux02 +quit
    elif [[ "${FRAMEWORK}" == *"staging"* ]]; then
        Info "Downloading Staging Files - Validation Off!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 -beta staging +quit
    else
        Info "Downloading Default Files - Validation Off!"
        ./steamcmd/steamcmd.sh +force_install_dir /home/container +login anonymous +app_update 258550 +quit
    fi
}

# Validate when downloading
function DepotDownloader_Validate() {
	Debug "Inside Function: SteamCMD_Validate()"

    if [[ "${FRAMEWORK}" == *"aux1"* ]]; then
        Delete_SteamApps_Directory
        Info "Downloading Aux1 Files - Validation On!"
        ./DepotDownloader -dir /home/container -app 258550 -depot 258552 -depot 258554 -beta aux01 -validate -username "anonymous" -password ""
    elif [[ "${FRAMEWORK}" == *"aux2"* ]]; then
        Delete_SteamApps_Directory
        Info "Downloading Aux2 Files - Validation On!"
        ./DepotDownloader -dir /home/container -app 258550 -depot 258552 -depot 258554 -beta aux02 -validate -username "anonymous" -password ""
    elif [[ "${FRAMEWORK}" == *"staging"* ]]; then
        Delete_SteamApps_Directory
        Info "Downloading Staging Files - Validation On!"
        ./DepotDownloader -dir /home/container -app 258550 -depot 258552 -depot 258554 -beta staging -validate -username "anonymous" -password ""
    else
        Delete_SteamApps_Directory
        Info "Downloading Default Files - Validation On!"
        ./DepotDownloader -dir /home/container -app 258550 -depot 258552 -depot 258554 -validate -username "anonymous" -password ""
    fi
}

# Don't validate while downloading
function DepotDownloader_No_Validation() {
	Debug "Inside Function: SteamCMD_No_Validation()"

    if [[ "${FRAMEWORK}" == *"aux1"* ]]; then
        Delete_SteamApps_Directory
        Info "Downloading Aux1 Files - Validation On!"
        ./DepotDownloader -dir /home/container -app 258550 -depot 258552 -depot 258554 -beta aux01 -username "anonymous" -password ""
    elif [[ "${FRAMEWORK}" == *"aux2"* ]]; then
        Delete_SteamApps_Directory
        Info "Downloading Aux2 Files - Validation On!"
        ./DepotDownloader -dir /home/container -app 258550 -depot 258552 -depot 258554 -beta aux02 -username "anonymous" -password ""
    elif [[ "${FRAMEWORK}" == *"staging"* ]]; then
        Delete_SteamApps_Directory
        Info "Downloading Staging Files - Validation On!"
        ./DepotDownloader -dir /home/container -app 258550 -depot 258552 -depot 258554 -beta staging -username "anonymous" -password ""
    else
        Delete_SteamApps_Directory
        Info "Downloading Default Files - Validation On!"
        ./DepotDownloader -dir /home/container -app 258550 -depot 258552 -depot 258554 -username "anonymous" -password ""
    fi
}
