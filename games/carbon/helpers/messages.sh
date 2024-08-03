#!/bin/bash

source /helpers/colors.sh

function Error() {
	printf "${RED}ERROR: $1 ${NC}"
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
	if [[ "${DEBUG}" == "TRUE" ]]; then
		echo $1
	fi
}