#!/bin/bash

source /helpers/messages.sh

####################################
# MODDING ROOT FOLDER EXISTS CHECK #
####################################

Info "Modding Framework is set to: ${FRAMEWORK}"
# We're going to create the modding root directory if the framework is either carbon or oxide, regardless of if the modding root is the default root or not.
if [[ "${FRAMEWORK}" =~ "carbon" || "${FRAMEWORK}" =~ "oxide" ]]; then
    echo "MODDING ROOT DIRECTORY set to '${MODDING_ROOT}' for framework '${FRAMEWORK}'."

    # Check if the modding root contains oxide when using carbon or carbon when using oxide
    if [[ "${FRAMEWORK}" =~ "carbon" ]] && [[ "${MODDING_ROOT}" =~ "oxide" ]]; then
        Error "${RED}ERROR: The modding root '${MODDING_ROOT}' contains the word oxide, but yet you're using the '${FRAMEWORK}'. Please change the name to something that doesn't contain the word oxide.${NC}\n"
        exit 1
    elif [[ "${FRAMEWORK}" =~ "oxide" ]] && [[ "${MODDING_ROOT}" =~ "carbon" ]]; then
        Error "${RED}ERROR: The modding root '${MODDING_ROOT}' contains the word carbon, but yet you're using the '${FRAMEWORK}'. Please change the name to something that doesn't contain the word carbon.${NC}\n"
        exit 1
    fi

    # If the modding root doesn't exist
    if [[ ! -d "$MODDING_ROOT" ]]; then
        # Create it
        Info "Creating directory named ${MODDING_ROOT}..."
        mkdir -p /home/container/${MODDING_ROOT}
        
        # If the last command of mkdir fails, then error out and exit the script, shit will fail if it continues. Theres no point to continue if this is fucked.
        if [[ $? -ne 0 ]]; then
            Error "${RED}ERROR: Failed to create the MODDING ROOT DIRECTORY '${MODDING_ROOT}'. Please check your permissions or the directory path.${NC}\n"
            exit 1
        fi
        
        # Output success
        Success "Successfully created directory named ${MODDING_ROOT}."
    else
        Warn "${MODDING_ROOT} already exists!"
    fi
fi

Success "${GREEN}Modding Root Folder Exists Check Complete!${NC}"