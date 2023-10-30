#!/bin/bash

# ----------------------------------------------------------------

if [ -z "$(ls -A $LOCAL_VOLUMN_PATH)" ]; then
  rsync --ignore-existing -r /docker-build/conf/ "${LOCAL_VOLUMN_PATH}"
fi

if [ ! -e "${LOCAL_VOLUMN_PATH}/solrconfig.xml" ]; then
  ln -s "${LOCAL_VOLUMN_PATH}"solrconfig.xml.txt "${LOCAL_VOLUMN_PATH}"solrconfig.xml
fi

docker-entrypoint.sh solr-foreground -force &
sleep 10

post -c collection "${LOCAL_VOLUMN_PATH}data/data.csv"


# ----------------------------------------------------------------

setupCloudflare() {
  file="/tmp/cloudflared"
  if [ ! -f "$file" ]; then
    wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -O "${file}"
    chmod a+x "${file}"
  fi
}

runCloudflare() {
  port="$1"
  file_path="$2"

  #echo "p ${port} ${file_path}"

  rm -rf "${file_path}"
  #nohup /tmp/.cloudflared --url "http://127.0.0.1:${port}" > "${file_path}" 2>&1 &
  /tmp/cloudflared --url "http://127.0.0.1:${port}" > "${file_path}" 2>&1 &
}

getCloudflarePublicURL() {
  setupCloudflare

  port="$1"

    # File path
  file_path="/tmp/cloudflared.out"

  runCloudflare "${port}" "${file_path}" &

  sleep 3

  # Extracting the URL using grep and awk
  url=$(grep -o 'https://[^ ]*\.trycloudflare\.com' "$file_path" | awk '/https:\/\/[^ ]*\.trycloudflare\.com/{print; exit}')

  echo "$url/solr/collection/browse"
}

getCloudflarePublicURL "${LOCAL_PORT}" > "${LOCAL_VOLUMN_PATH}/.cloudflare.url"

echo "================================================================"
echo "Apache Solr is ready to serve."
echo "================================================================"

# ----------------------------------------------------------------

while true; do
  sleep 10
done