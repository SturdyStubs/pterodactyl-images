#!/bin/bash

source /helpers/messages.sh

#################
# UPDATE CARBON #
#################

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside /sections/update_carbon.sh file!"

Debug "Trying to update Carbon..."

# This is necessary for carbon to run. Put it in a function to reduce repeat code.
function Doorstop_Startup_Carbon() {
    export DOORSTOP_ENABLED=1
    export DOORSTOP_TARGET_ASSEMBLY="$(pwd)/${MODDING_ROOT}/managed/Carbon.Preloader.dll"
    MODIFIED_STARTUP="LD_PRELOAD=$(pwd)/libdoorstop.so ${MODIFIED_STARTUP}"
}

if [[ "$FRAMEWORK_UPDATE" == "1" ]]; then
	if [[ "${FRAMEWORK}" == "carbon" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon.Core/releases/download/production_build/Carbon.Linux.Release.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon

	elif [[ "${FRAMEWORK}" == "carbon-release" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Release..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_release_build/Carbon.Linux.Release.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon

	elif [[ "${FRAMEWORK}" == "carbon-minimal" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Minimal..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/production_build/Carbon.Linux.Minimal.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon

	elif [[ "${FRAMEWORK}" == "carbon-edge" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Edge..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Debug.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon
	    
	elif [[ "${FRAMEWORK}" == "carbon-edge-minimal" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Edge Minimal..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/edge_build/Carbon.Linux.Minimal.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon

	elif [[ "${FRAMEWORK}" == "carbon-staging" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Staging..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Debug.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon

	elif [[ "${FRAMEWORK}" == "carbon-staging-minimal" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Staging Minimal..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_staging_build/Carbon.Linux.Minimal.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon

	elif [[ "${FRAMEWORK}" == "carbon-aux1" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Aux1..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Debug.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon

	elif [[ "${FRAMEWORK}" == "carbon-aux1-minimal" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Aux1 Minimal..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux01_build/Carbon.Linux.Minimal.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon

	elif [[ "${FRAMEWORK}" == "carbon-aux2" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Aux2..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Debug.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon

	elif [[ "${FRAMEWORK}" == "carbon-aux2-minimal" ]]; then
	    # Carbon: https://github.com/CarbonCommunity/Carbon.Core
	    Info "Updating Carbon Aux2 Minimal..."
	    curl -sSL "https://github.com/CarbonCommunity/Carbon/releases/download/rustbeta_aux02_build/Carbon.Linux.Minimal.tar.gz" | tar zx
	    Check_Modding_Root_Folder
	    Success "Done updating Carbon!"
	    Doorstop_Startup_Carbon
	fi
else
	Error "Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!"
fi