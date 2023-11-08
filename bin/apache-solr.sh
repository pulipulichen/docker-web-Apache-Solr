#!/bin/bash

PROJECT_NAME=docker-web-Apache-Solr

# =================================================================
# 宣告函數

openURL() {
  url="$1"
  echo "${url}"

  if command -v xdg-open &> /dev/null; then
    xdg-open "${url}" &
  elif command -v open &> /dev/null; then
    open "${url}" &
  fi
}

getRealpath() {
  path="$1"
  if command -v realpath &> /dev/null; then
    path=`realpath "${path}"`
  else
    path=$(cd "$(dirname "${path}")"; pwd)/"$(basename "${path}")"
  fi
  echo "${path}"
}

# ------------------
# 確認環境

# Get the directory path of the script
SCRIPT_PATH=$(getRealpath "$0")
# echo "v ${SCRIPT_PATH}"
# SCRIPT_PATH=$(getRealpath "${SCRIPT_PATH}")

# echo "PWD: ${SCRIPT_PATH}"

# ------------------

if ! command -v git &> /dev/null
then
  echo "git could not be found"

  openURL https://git-scm.com/downloads &

  exit 1
fi

if ! command -v docker-compose &> /dev/null
then
  echo "docker-compose could not be found"

  openURL https://docs.docker.com/compose/install/ &

  exit 1
fi

# ---------------
# 安裝或更新專案

if [ -d "/tmp/${PROJECT_NAME}" ];
then
  cd "/tmp/${PROJECT_NAME}"

  git reset --hard
  git pull --force
else
	# echo "$DIR directory does not exist."
  cd /tmp
  git clone "https://github.com/pulipulichen/${PROJECT_NAME}.git"
  cd "/tmp/${PROJECT_NAME}"
fi

# -----------------
# 確認看看要不要做docker-compose build

mkdir -p "/tmp/${PROJECT_NAME}.cache"

cmp --silent "/tmp/${PROJECT_NAME}/Dockerfile" "/tmp/${PROJECT_NAME}.cache/Dockerfile" && cmp --silent "/tmp/${PROJECT_NAME}/package.json" "/tmp/${PROJECT_NAME}.cache/package.json" || docker-compose build

cp "/tmp/${PROJECT_NAME}/Dockerfile" "/tmp/${PROJECT_NAME}.cache/"
cp "/tmp/${PROJECT_NAME}/package.json" "/tmp/${PROJECT_NAME}.cache/"

# =================
# 從docker-compose-template.yml來判斷參數

INPUT_FILE="false"
if [ -f "/tmp/${PROJECT_NAME}/docker-build/image/docker-compose-template.yml" ]; then
  if grep -q "\[INPUT\]" "/tmp/${PROJECT_NAME}/docker-build/image/docker-compose-template.yml"; then
    INPUT_FILE="true"
  fi
fi

# --------

# Using grep and awk to extract the public port from the docker-compose.yml file
PUBLIC_PORT="false"
# Step 2: Read the public port from the docker-compose.yml file
DOCKER_COMPOSE_FILE="/tmp/${PROJECT_NAME}/docker-compose.yml"

# Check if the default Docker Compose file exists
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
  # If the file doesn't exist, set an alternative file path
  DOCKER_COMPOSE_FILE="/tmp/${PROJECT_NAME}/docker-build/image/docker-compose-template.yml"
fi

if [ -f "$DOCKER_COMPOSE_FILE" ]; then
  PUBLIC_PORT=$(awk '/ports:/{flag=1} flag && /- "[0-9]+:[0-9]+"/{split($2, port, ":"); gsub(/"/, "", port[1]); print port[1]; flag=0}' "$DOCKER_COMPOSE_FILE")
fi

#echo "P: ${PUBLIC_PORT}"

# =================
# 讓Docker能順利運作的設定
# Linux跟Mac需要

if [ -z "$DOCKER_HOST" ]; then
    
    if [[ "$(uname)" == "Darwin" ]]; then
      echo "Running on macOS"
    else
      echo "DOCKER_HOST is not set, setting it to 'unix:///run/user/1000/docker.sock'"
      export DOCKER_HOST="unix:///run/user/1000/docker.sock"
    fi
else
    echo "DOCKER_HOST is set to '$DOCKER_HOST'"
fi

# -------------------
# 檢查有沒有輸入檔案參數

var="$1"
useParams="true"
WORK_DIR=`pwd`
if [ "$INPUT_FILE" != "false" ]; then
  if [ ! -f "$var" ]; then
    # echo "$1 does not exist."
    # exit
    if command -v kdialog &> /dev/null; then
      var=$(kdialog --getopenfilename --multiple ~/ 'Files')
      
    elif command -v osascript &> /dev/null; then
      selected_file="$(osascript -l JavaScript -e 'a=Application.currentApplication();a.includeStandardAdditions=true;a.chooseFile({withPrompt:"Please select a file to process:"}).toString()')"

      # Storing the selected file path in the "var" variable
      var="$selected_file"

    fi
    var=`echo "${var}" | xargs`
    useParams="false"
  fi
fi

# =================================================================
# 宣告函數

getCloudflarePublicURL() {
  dirname=$(dirname "$SCRIPT_PATH")
  cloudflare_file="${dirname}/${PROJECT_NAME}/.cloudflare.url"

  # echo "c ${cloudflare_file}"

  # Wait until the file exists
  while [ ! -f "$cloudflare_file" ]; do
    # echo "not exists ${cloudflare_file}"
    sleep 1  # Check every 1 second
  done

  echo $(<"$cloudflare_file")
}

# ----------------------------------------------------------------

setDockerComposeYML() {
  file="$1"
  #echo "input: ${file}"

  filename=$(basename "$file")
  dirname=$(dirname "$file")


  template=$(<"/tmp/${PROJECT_NAME}/docker-build/image/docker-compose-template.yml")
  #echo "$template"

  template="${template/\[SOURCE\]/$dirname}"
  template="${template/\[INPUT\]/$filename}"

  echo "$template" > "/tmp/${PROJECT_NAME}/docker-compose.yml"
}

# ========

waitForConntaction() {
  port="$1"
  sleep 3
  while true; do
    if curl -sSf "http://127.0.0.1:$port" >/dev/null 2>&1; then
      echo "Connection successful."
      break
    else
      #echo "Connection failed. Retrying in 5 seconds..."
      sleep 5
    fi
  done
}

runDockerCompose() {
  must_sudo="false"
  if [[ "$(uname)" == "Darwin" ]]; then
    if ! chown -R $(whoami) ~/.docker; then
      sudo chown -R $(whoami) ~/.docker
      must_sudo="true"
      exit 0
    fi
  fi

  #echo "m ${must_sudo}"

  if [ "$PUBLIC_PORT" == "false" ]; then
    if [ "$must_sudo" == "false" ]; then
      docker-compose down
      if ! docker-compose up --build; then
        echo "Error occurred. Trying with sudo..."
        sudo docker-compose down
        sudo docker-compose up --build
      fi
    else
      sudo docker-compose down
      sudo docker-compose up --build
    fi
    exit 0
  else
    # Set up a trap to catch Ctrl+C and call the cleanup function
    trap 'cleanup' INT

    if [ "$must_sudo" == "false" ]; then
      docker-compose down
      if ! docker-compose up --build -d; then
        echo "Error occurred. Trying with sudo..."
        sudo docker-compose down
        sudo docker-compose up --build -d
      fi
    else
      sudo docker-compose down
      sudo docker-compose up --build -d
    fi

    waitForConntaction $PUBLIC_PORT

    cloudflare_url=$(getCloudflarePublicURL)
    # cloudflare_url=$(<"${SCRIPT_PATH}/${PROJECT_NAME}/.cloudflare.url")

    sleep 10
    #/tmp/.cloudflared --url "http://127.0.0.1:$PUBLIC_PORT" > /tmp/.cloudflared.out 

    echo "================================================================"
    echo "You can link the website via following URL:"
    echo ""

    # openURL "http://127.0.0.1:$PUBLIC_PORT"
    # echo "${cloudflare_url}"
    openURL "${cloudflare_url}"
    echo "http://127.0.0.1:$PUBLIC_PORT"
    
    echo ""
    # Keep the script running to keep the container running
    # until the user decides to stop it
    echo "Press Ctrl+C to stop the Docker container and exit."
    echo "================================================================"

    # Wait indefinitely, simulating a long-running process
    # This is just to keep the script running until the user interrupts it
    # You might replace this with an actual running process that should keep the script alive
    while true; do
      sleep 1
    done
  fi
}

# Function to handle clean-up on script exit or Ctrl+C
cleanup() {
  echo "Stopping the Docker container..."
  docker-compose down
  exit 1
}

# -----------------
# 執行指令

if [ "$INPUT_FILE" != "false" ]; then
  if [ "${useParams}" == "true" ]; then
    # echo "use parameters"
    for var in "$@"
    do
      cd "${WORK_DIR}"
      

      var=getRealpath "${var}"
      cd "/tmp/${PROJECT_NAME}"
      setDockerComposeYML "${var}"

      runDockerCompose
    done
  else
    if [ ! -f "${var}" ]; then
      echo "$var does not exist."
    else
      setDockerComposeYML "${var}"

      runDockerCompose
    fi
  fi
else
  cd "/tmp/${PROJECT_NAME}"

  # echo "PWD: ${SCRIPT_PATH}"
  setDockerComposeYML "${SCRIPT_PATH}"

  # cat "/tmp/${PROJECT_NAME}/docker-compose.yml"
  # exit 0
  runDockerCompose
fi
