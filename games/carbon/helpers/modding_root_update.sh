#!/bin/bash

source /helpers/messages.sh

#######################
# MODDING ROOT UPDATE #
#######################

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside /helpers/modding_root_update.sh file!"

# This function will move the updated managed, native, and tools folders from /carbon into the modding root folder
# This way we don't have to create a temp directory and delete it we're just going to use the /carbon folder as the
# "temp" directory, since it already exists. We also don't want to have repeating code throughout our script,
# and the code is literally going to be the same for each branch of carbon.
function Check_Modding_Root_Folder() {
    Debug "Inside the function: Check_Modding_Root_Folder()"
    Info "Checking Modding Root Folder to see if moves are required or not..."

    # Check what the framework is and define the default root
    if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
        DEFAULT_ROOT="carbon"
    elif [[ "${FRAMEWORK}" =~ "oxide" ]]; then
        DEFAULT_ROOT="oxide"
    fi
    
    Debug "Default Dir: ${DEFAULT_ROOT}"

    # If the modding root doesn't equal the default root, then we must be using a custom modding root. Move the updated files. Handle this for carbon & Oxide
    if [[ "${MODDING_ROOT}" != "${DEFAULT_ROOT}" ]] && [[ "${FRAMEWORK}" =~ "carbon" ]]; then
        Warn "Modding root does not match default root - Carbon"
        Info "Creating new directories inside ${MODDING_ROOT} - managed, native, tools"
        # Create Directories
        mkdir -p "/home/container/${MODDING_ROOT}/managed/"
        mkdir -p "/home/container/${MODDING_ROOT}/native/"
        mkdir -p "/home/container/${MODDING_ROOT}/tools/"
        echo "Moving files..."
        # Move shit
        mv -f "/home/container/carbon/managed/"* "/home/container/${MODDING_ROOT}/managed/"
        mv -f "/home/container/carbon/native/"* "/home/container/${MODDING_ROOT}/native/"
        mv -f "/home/container/carbon/tools/"* "/home/container/${MODDING_ROOT}/tools/"
        Success "Moves complete!"
    elif [[ "${MODDING_ROOT}" != "${DEFAULT_ROOT}" ]] && [[ "${FRAMEWORK}" =~ "oxide" ]]; then
        Warn "Modding root does not match default root - Oxide"
        # Move shit
        mv -f "/home/container/oxide/"* "/home/container/${MODDING_ROOT}/"
        Success "Moves complete!"
    else
        # Modding folder is the default
        Success "Modding root is the same as default root. Skipping..."
    fi

}