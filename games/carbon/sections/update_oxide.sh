#!/bin/bash

source /helpers/messages.sh

################
# UPDATE OXIDE #
################

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside /sections/update_oxide.sh file!"

Debug "Trying to update Oxide..."

if [[ "${FRAMEWORK_UPDATE}" == "1" ]]; then
	if [[ "${FRAMEWORK}" == "oxide" ]]; then
	    # Oxide: https://github.com/OxideMod/Oxide.Rust
	    echo "Updating uMod..."
	    curl -sSL "https://github.com/OxideMod/Oxide.Rust/releases/latest/download/Oxide.Rust-linux.zip" > umod.zip
	    unzip -o -q umod.zip
	    rm umod.zip
	    Check_Modding_Root_Folder
	    echo "Done updating uMod!"
	    echo "If you intend to use a different folder name, you'll need to wait until the server boots and the oxide folder is created to rename it."
	elif [[ "${FRAMEWORK}" == "oxide-staging" ]]; then
	    # Oxide: https://github.com/OxideMod/Oxide.Rust
	    echo "Updating uMod Staging..."
	    curl -sSL "https://downloads.oxidemod.com/artifacts/Oxide.Rust/staging/Oxide.Rust-linux.zip" > umod.zip
	    unzip -o -q umod.zip
	    rm umod.zip
	    Check_Modding_Root_Folder
	    echo "Done updating uMod!"
	    echo "If you intend to use a different folder name, you'll need to wait until the server boots and the oxide folder is created to rename it."
	else
		Debug "Framework is set to ${FRAMEWORK}, skipping Oxide Update!"
	fi
else
	Error "Skipping framework auto update! Did you mean to do this? If not set the Framework Update variable to true!"
fi

