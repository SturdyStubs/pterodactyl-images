#!/bin/bash

source /helpers/messages.sh

################################
# OXIDE -> CARBON SWITCH CHECK #
################################

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside /sections/oxide_carbon_switch.sh file!"

Info "Detecting if there is a oxide to carbon switch occurring...."

# If the framework isn't oxide or oxide staging
if [[ "${FRAMEWORK}" != "oxide" ]] || [[ "${FRAMEWORK}" != "oxide-staging" ]]; then
    # Define a bool for later use
    CARBONSWITCH="FALSE"
    
    shopt -s nullglob # No idea what this does. Just leave it.
    
    # Get all the Oxide.*.dll files - Can return empty is no files exist.
    files=(/home/container/RustDedicated_Data/Managed/Oxide.*.dll)

    # Check if the Oxide.*.dll files exist
    Info "Modding framework is not set to Oxide. Checking if there are left over Oxide files in the server."
    if [ ${#files[@]} -gt 0 ]; then
        # FOUND EM!
        Info "Oxide Files Found!"

        if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
            # Framework is carbon now, but oxide files were detected in RustDedicated_Data/Managed folder, which means that there is a switch occurring.
            Success "Carbon installation detected. Marking Carbon Switch as TRUE!"
            CARBONSWITCH="TRUE"
        else
            # Since its not oxide, or carbon, must be vanilla
            Error "If you see this and your framework isn't vanilla, then contact the developers."
        fi
    else
        # Must already be on carbon...
        Success "No Oxide files found NOT SWITCHING FROM OXIDE - continuing startup..."
    fi
    shopt -u nullglob
fi

Debug "=============================="
Debug "CARBONSWITCH: ${CARBONSWITCH}"
Debug "=============================="