#!/bin/bash

source /helpers/messages.sh

########################
# EXTENSION DOWNLOADER #
########################

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside of /sections/extension_download.sh file!"

Info "Checking Extension Downloads..."

# Check if any of the extensions variables are set to true
if [ "${RUSTEDIT_EXT}" == "1" ] || [ "${DISCORD_EXT}" == "1" ] || [ "${CHAOS_EXT}" == "1" ]; then
    if [[ "${FRAMEWORK}" != "vanilla" ]]; then
        # Make temp directory
        Debug "Making temp directory..."
        mkdir -p /home/container/temp

        # Download RustEdit Extension
        if [ "${RUSTEDIT_EXT}" == "1" ]; then
            Debug "Downloading RustEdit Extension"
            curl -sSL -o /home/container/temp/Oxide.Ext.RustEdit.dll https://github.com/k1lly0u/Oxide.Ext.RustEdit/raw/master/Oxide.Ext.RustEdit.dll
            Success "RustEdit Extention Downloaded!"
        fi

        # Download Discord Extension
        if [ "${DISCORD_EXT}" == "1" ]; then
            Debug "Downloading Discord Extension"
            curl -sSL -o /home/container/temp/Oxide.Ext.Discord.dll https://umod.org/extensions/discord/download
            Success "Discord Extension Downloaded!"
        fi

        # Download Chaos Code Extension
        if [ "${CHAOS_EXT}" == "1" ]; then
            Debug "Downloading Chaos Code Extension"
            curl -sSL -o /home/container/temp/Oxide.Ext.Chaos.dll https://chaoscode.io/oxide/Oxide.Ext.Chaos.dll
            Success "Chaos Code Extension Downloaded!"
        fi

        # Handle Move of files based on framework
        files=(/home/container/temp/Oxide.Ext.*.dll)
        if [ ${#files[@]} -gt 0 ]; then
            Info "Moving Extensions to appropriate folders..."
            
            # If the framework is carbon, move it into the modding root folder
            if [[ ${FRAMEWORK} =~ "carbon" ]]; then
                Debug "Carbon framework detected!"
                # Create Carbon Extensions folder in case they want extensions, but also are changing their modding root
                # Prevents this error: mv: target '/home/container/carbon-poop/extensions/' is not a directory
                Debug "Making directory /home/container/${MODDING_ROOT}/extensions/"
                mkdir -p "/home/container/${MODDING_ROOT}/extensions/"
                Info "Moving files..."
                mv -v /home/container/temp/Oxide.Ext.*.dll "/home/container/${MODDING_ROOT}/extensions/"
            fi
            
            # If framework is oxide
            if [[ ${FRAMEWORK} =~ "oxide" ]]; then
                Debug "Oxide framework detected!"
                mv -v /home/container/temp/Oxide.Ext.*.dll /home/container/RustDedicated_Data/Managed/
            fi

            Success "Move files has completed successfully!"
        else
            Success "No Extensions to Move... Skipping the move..."
        fi

        # Clean up temp folder
        Debug "Cleaning up Temp Directory"
        rm -rf /home/container/temp
        Debug "Cleanup complete!"
        Success "All downloads complete!"
    else
        Error "Framework is vanilla, but you have extension downloads enabled, are you sure that this is what you want?"
    fi
else
    Success "No extensions are enabled. Skipping this part..."
fi