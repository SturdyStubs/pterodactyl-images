#!/bin/bash
# Initial install script with optional DepotDownloader method
# Server Files: /mnt/server

set -euo pipefail

SRCDS_APPID=258550

# Resolve download method (supports both DOWNLOAD_METHOD and download_method)
DOWNLOAD_METHOD="${DOWNLOAD_METHOD:-${download_method:-SteamCMD}}"
METHOD_LC="$(echo "${DOWNLOAD_METHOD}" | tr '[:upper:]' '[:lower:]')"

# Resolve branch from FRAMEWORK
# public | aux01 | aux02 | staging (default: public)
FRAMEWORK="${FRAMEWORK:-public}"
case "$(echo "${FRAMEWORK}" | tr '[:upper:]' '[:lower:]')" in
  *aux1*)    BRANCH="aux01" ;;
  *aux2*)    BRANCH="aux02" ;;
  *staging*) BRANCH="staging" ;;
  *)         BRANCH="public" ;;
esac

## just in case someone removed the defaults.
if [ "${STEAM_USER:-}" == "" ]; then
    echo -e "steam user is not set."
    echo -e "Using anonymous user."
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "user set to ${STEAM_USER}"
fi

# Ensure unzip exists (needed for DepotDownloader)
if ! command -v unzip >/dev/null 2>&1; then
  echo "Installing unzip..."
  apt-get update && apt-get install -y unzip
fi

install_depotdownloader() {
  local dd_dir="/mnt/server/DepotDownloader"
  local zip="/tmp/DepotDownloader.zip"
  # Pinned release; override with DEPOTDOWNLOADER_URL if needed
  local url="${DEPOTDOWNLOADER_URL:-https://github.com/SteamRE/DepotDownloader/releases/download/DepotDownloader_3.4.0/DepotDownloader-linux-x64.zip}"

  if [ -x "${dd_dir}/DepotDownloader" ]; then
    echo "DepotDownloader already installed."
    return 0
  fi

  echo "Downloading DepotDownloader..."
  mkdir -p "${dd_dir}"
  curl -sSL -o "${zip}" "${url}"
  unzip -o "${zip}" -d "${dd_dir}"
  chmod +x "${dd_dir}/DepotDownloader" || true
  rm -f "${zip}"
}

## download and install steamcmd (for libs and/or SteamCMD method)
cd /tmp
mkdir -p /mnt/server/steamcmd
curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xzvf steamcmd.tar.gz -C /mnt/server/steamcmd
mkdir -p /mnt/server/steamapps # Fix steamcmd disk write error when this folder is missing
cd /mnt/server/steamcmd

# SteamCMD fails otherwise for some reason, even running as root.
# This is changed at the end of the install process anyways.
chown -R root:root /mnt
export HOME=/mnt/server

# If DepotDownloader method selected, install and use it for server files
if [ "${METHOD_LC}" = "depotdownloader" ] || [ "${METHOD_LC}" = "dd" ]; then
  echo "Using DepotDownloader to download server files (anonymous)..."
  install_depotdownloader
  /mnt/server/DepotDownloader/DepotDownloader -app "${SRCDS_APPID}" -dir /mnt/server -branch "${BRANCH}" -validate
else
  echo "Using SteamCMD to download server files (anonymous/default)..."
  ./steamcmd.sh +force_install_dir /mnt/server +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} +app_update ${SRCDS_APPID} ${EXTRA_FLAGS} validate +quit
fi

## set up 32 bit libraries
mkdir -p /mnt/server/.steam/sdk32
cp -v linux32/steamclient.so ../.steam/sdk32/steamclient.so

## set up 64 bit libraries
mkdir -p /mnt/server/.steam/sdk64
cp -v linux64/steamclient.so ../.steam/sdk64/steamclient.so

