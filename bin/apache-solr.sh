#!/bin/bash

PROJECT_NAME=docker-web-Apache-Solr

# =================================================================

getRealpath() {
  path="$1"
  if command -v realpath &> /dev/null; then
    path=`realpath "${path}"`
  else
    path=$(cd "$(dirname "${path}")"; pwd)/"$(basename "${path}")"
  fi
  echo "${path}"
}


# =================================================================

# Step 1: Create the directory if it doesn't exist
mkdir -p /tmp/docker-app

# Step 2: Download the script
curl -o /tmp/docker-app/docker-app-launcher.sh https://pulipulichen.github.io/docker-app-Launcher/docker-app-launcher.sh

# Step 3: Make the script executable
chmod +x /tmp/docker-app/docker-app-launcher.sh

# Step 5: Get the script's full path as the second parameter
SCRIPT_PATH=$(getRealpath "$0")

# Step 6: Get all parameters from this script as the third, fourth, ... parameters
shift 2  # Shift to remove the first two parameters (PROJECT_NAME and SCRIPT_PATH)
PARAMETERS=("$@")
for ((i = 0; i < ${#PARAMETERS[@]}; i++)); do
    PARAMETERS[$i]=$(getRealpath "${PARAMETERS[$i]}")
done

# Step 7: Pass parameters to "~/docker-app/docker-app-launcher.sh"
# /tmp/docker-app/docker-app-launcher.sh "$PROJECT_NAME" "$SCRIPT_PATH" "${PARAMETERS[@]}"
/tmp/docker-app/docker-app-launcher.sh "$PROJECT_NAME" "$SCRIPT_PATH" "${PARAMETERS[@]}"
