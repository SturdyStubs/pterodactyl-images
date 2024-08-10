#!/bin/bash

source /helpers/colors.sh

function Error() {
	printf "${RED}ERROR: $1 ${NC}"

	# If the second param exists
	if [[ ! -z "$2" ]]; then
		# then we must want to exit the script
		if [[ "$2" == "1" ]]; then
			# Exit with error code
			exit 1
		elif [[ "$2" == "0" ]]; then
			# Exit with no error code
			exit 0
		fi
	fi
}

function Warn() {
	printf "${YELLOW}WARNING: $1 ${NC}"
}

function Info() {
	printf "${BLUE}$1 ${NC}"
}

function Success() {
	printf "${GREEN}SUCCESS: $1 ${NC}"
}

function Debug() {
	if [[ "${EGG_DEBUG}" == "1" ]]; then
		echo $1
	fi
}

##########
# Colors #
##########

function Red() {
	printf "${RED}$1 ${NC}"
}