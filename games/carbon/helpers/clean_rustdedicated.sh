#!/bin/bash

source /helpers/messages.sh

#######################################################
# CLEAN RUSTDEDICATED_DATA FOLDER OF OXIDE EXTENSIONS #
#######################################################

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside of /helpers/clean_rustdedicated.sh file!"

function Clean_RustDedicated() {

	Debug "Inside function: Clean_RustDedicated()"

	RUSTEDIT="/home/container/RustDedicated_Data/Managed/Oxide.RustEdit.dll"
	CHAOS="/home/container/RustDedicated_Data/Managed/Oxide.Chaos.dll"
	DISCORD="/home/container/RustDedicated_Data/Managed/Oxide.Discord.dll"
	DEST_DIR="/home/container/${MODDING_ROOT}/extensions/"

	if [[ "${FRAMEWORK}" =~ "carbon" ]]; then
		Debug "Carbon Framework Detected!"
		Info "Moving Oxide Extensions to Carbon Directory..."

		# Check if the destination directory exists; if not, create it
		if [[ ! -d "$DEST_DIR" ]]; then
		  Warn "Destination directory does not exist. Creating: $DEST_DIR"
		  mkdir -p "$DEST_DIR"
		fi

		Debug "RUSTEDIT: ${RUSTEDIT}"
		Debug "CHAOS: ${CHAOS}"
		Debug "DISCORD: ${DISCORD}"
		Debug "DEST_DIR: ${DEST_DIR}"

		Debug "Testing"

		# Check if Rust Edit Extension is installed
		if [[ -f "$RUSTEDIT" ]]; then
			Info "Found Rust Edit Extension! Moving it now..."
			# Move it
			mv -v "$RUSTEDIT" "$DEST_DIR"
			Success "Rust Edit Extension Moved!"
		else
			Debug "Can not find RUSTEDIT: ${RUSTEDIT}"
		fi

		Debug "Testing2"

		# Check if Chaos Code Extension is installed
		if [[ -f "$CHAOS" ]]; then
			Info "Found Chaos Code Extension! Moving it now..."
			# Move it
			mv -v "$CHAOS" "$DEST_DIR"
			Success "Chaos Code Extension Moved!"
		else
			Debug "Can not find CHAOS: ${CHAOS}"
		fi

		Debug "Testing3"

		# Check if Discord Extension is installed
		if [[ -f "$DISCORD" ]]; then
			Info "Found Discord Extension! Moving it now..."
			# Move it
			mv -v "$DISCORD" "$DEST_DIR"
			Success "Discord Extension Moved!"
		else
			Debug "Can not find DISCORD: ${DISCORD}"
		fi

		Debug "Testing4"

	elif [[ "${FRAMEWORK}" == "vanilla" ]]; then
		Debug "Vanilla framework detected!"
		Info "Moving Oxide Extensions to the trash..."

		# Check if Rust Edit Extension is installed
		if [[ -f "$RUSTEDIT" ]]; then
			Info "Found Rust Edit Extension! Moving it now..."
			# Move it
			rm -rf "$RUSTEDIT" "$DEST_DIR"
			Success "Rust Edit Extension Moved!"
		fi

		# Check if Chaos Code Extension is installed
		if [[ -f "$CHAOS" ]]; then
			Info "Found Chaos Code Extension! Moving it now..."
			# Move it
			rm -rf "$CHAOS" "$DEST_DIR"
			Success "Chaos Code Extension Moved!"
		fi

		# Check if Discord Extension is installed
		if [[ -f "$DISCORD" ]]; then
			Info "Found Discord Extension! Moving it now..."
			# Move it
			rm -rf "$DISCORD" "$DEST_DIR"
			Success "Discord Extension Moved!"
		fi
	fi
}