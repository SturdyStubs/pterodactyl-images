#!/bin/bash

source /helpers/messages.sh

#######################################################
# CLEAN RUSTDEDICATED_DATA FOLDER OF OXIDE EXTENSIONS #
#######################################################

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside of /helpers/clean_rustdedicated.sh file!"

function Clean_RustDedicated() {

	Debug "Inside function: Clean_RustDedicated()"

	RUSTEDIT="/home/container/RustDedicated_Data/Managed/Oxide.Ext.RustEdit.dll"
	CHAOS="/home/container/RustDedicated_Data/Managed/Oxide.Ext.Chaos.dll"
	DISCORD="/home/container/RustDedicated_Data/Managed/Oxide.Ext.Discord.dll"
	OXIDEREF="/home/container/RustDedicated_Data/Managed/Oxide.References.dll.config"
	DEST_DIR="/home/container/${MODDING_ROOT}/extensions/"

	Debug "RUSTEDIT: ${RUSTEDIT}"
	Debug "CHAOS: ${CHAOS}"
	Debug "DISCORD: ${DISCORD}"
	Debug "OXIDEREF: ${OXIDEREF}"
	Debug "DEST_DIR: ${DEST_DIR}"

	if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
		Debug "Carbon Framework Detected!"
		Info "Moving Oxide Extensions to Carbon Directory..."

		# Check if the destination directory exists; if not, create it
		if [[ ! -d "$DEST_DIR" ]]; then
		  Warn "Destination directory does not exist. Creating: $DEST_DIR"
		  mkdir -p "$DEST_DIR"
		fi

		# Check if Rust Edit Extension is installed
		if [[ -f "$RUSTEDIT" ]]; then
			Info "Found Rust Edit Extension! Moving it now..."
			# Move it
			mv -v "$RUSTEDIT" "$DEST_DIR"
			Success "Rust Edit Extension Moved!"
		else
			Debug "Can not find RUSTEDIT: ${RUSTEDIT}"
		fi

		# Check if Chaos Code Extension is installed
		if [[ -f "$CHAOS" ]]; then
			Info "Found Chaos Code Extension! Moving it now..."
			# Move it
			mv -v "$CHAOS" "$DEST_DIR"
			Success "Chaos Code Extension Moved!"
		else
			Debug "Can not find CHAOS: ${CHAOS}"
		fi

		# Check if Discord Extension is installed
		if [[ -f "$DISCORD" ]]; then
			Info "Found Discord Extension! Moving it now..."
			# Move it
			mv -v "$DISCORD" "$DEST_DIR"
			Success "Discord Extension Moved!"
		else
			Debug "Can not find DISCORD: ${DISCORD}"
		fi

	elif [[ "${FRAMEWORK}" == "vanilla" ]]; then
		Debug "Vanilla framework detected!"

		shopt -s nullglob # This ensures that if no files match the pattern, the result is an empty list rather than the pattern itself.
    
	    # Get all the Oxide.*.dll files - Can return empty is no files exist.
	    files=(/home/container/RustDedicated_Data/Managed/Oxide.*.dll)

	    # Check if the Oxide.*.dll files exist
	    Info "Checking for Oxide Files in RustDedicated_Data/Managed..."
	    if [ ${#files[@]} -gt 0 ]; then
	        # FOUND EM!
	        Info "Oxide Files Found!"

	        Info "Moving Oxide Files to the trash..."
	        # Remove all files that match the Oxide.*.dll pattern
    		rm -v /home/container/RustDedicated_Data/Managed/Oxide.*.dll

	        Success "Removed all Oxide files from RustDedicated_Data/Managed"
	    else
	        # No Files Found
	        Success "No Oxide Files Found!"
	    fi
	    shopt -u nullglob # Restore Default Globbing Behavior
	fi

	# Check if Oxide Reference Config is installed
	if [[ -f "$OXIDEREF" ]]; then
		Info "Found Oxide Reference Config! Moving it to the trash now..."
		# Move it
		rm -rf "$OXIDEREF"
		Success "Oxide Reference Config Trashed!"
	else
		Debug "Can not find OXIDEREF: ${OXIDEREF}"
	fi
}