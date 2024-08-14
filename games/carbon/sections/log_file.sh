#!/bin/bash

source /helpers/messages.sh

Debug "-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
Debug "Inside /sections/log_file.sh file!"

##################
# LOG FILE CHECK #
##################

if [ -z "${LOG_FILE}" ] || { [ "${LOG_FILE}" != "0" ] || [ "${LOG_FILE}" != "1" ]; }; then
    Warn "LOG_FILE variable not found. Update your egg at https://github.com/SturdyStubs/AIO.Egg. Disabling file logging..."
    LOG_FILE="0"
fi