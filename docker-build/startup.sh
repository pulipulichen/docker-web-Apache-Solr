#!/bin/bash

# ----------------------------------------------------------------

waitForConntaction() {
  port="$1"
  sleep 3
  while true; do
    echo "http://127.0.0.1:$port"
    if curl -sSf "http://127.0.0.1:$port" >/dev/null 2>&1; then
      echo "Connection successful."
      break
    else
      #echo "Connection failed. Retrying in 5 seconds..."
      sleep 5
    fi
  done
}

# ----------------------------------------------------------------

rm -f "${LOCAL_VOLUMN_PATH}/.docker-web.ready*"

INITED="true"
if [ -z "$(ls -A $LOCAL_VOLUMN_PATH)" ]; then
  rm -rf /var/solr/data/collection/data
  rsync --ignore-existing -r /docker-build/conf/ "${LOCAL_VOLUMN_PATH}"
  INITED="false"
fi

if [ -f "${LOCAL_VOLUMN_PATH}solrconfig.xml.txt" ]; then
  cp -f "${LOCAL_VOLUMN_PATH}solrconfig.xml.txt" "${LOCAL_VOLUMN_PATH}solrconfig.xml"
fi

# if [ ! -e "${LOCAL_VOLUMN_PATH}/solrconfig.xml" ]; then
#   ln -s "${LOCAL_VOLUMN_PATH}"solrconfig.xml.txt "${LOCAL_VOLUMN_PATH}"solrconfig.xml
# fi

#docker-entrypoint.sh solr-foreground -force -Dsolr.clustering.enabled=true &
solr start -force -f -Dsolr.clustering.enabled=true &

#echo "BEFORE ================================================================="
waitForConntaction "${LOCAL_PORT}"
#echo "AFTER ================================================================="

sleep 10

DATA_PATH="${LOCAL_VOLUMN_PATH}data.csv"
DATA_TEMP_PATH="${LOCAL_VOLUMN_PATH}data-temp.csv"
rm -f "${DATA_TEMP_PATH}"

python3 "/docker-build/python/init_data.py"

if [ -f "$DATA_TEMP_PATH" ]; then
  DATA_PATH="${DATA_TEMP_PATH}"
fi

python3 "/docker-build/python/prepend_id.py" "${DATA_PATH}"
python3 "/docker-build/python/remove_not_in_id.py" "${DATA_PATH}"
if [ ! -f "$file" ]; then
  post -c collection "${DATA_PATH}"
  cp -rf "${LOCAL_VOLUMN_PATH}" /tmp/
else
  if diff -r "${LOCAL_VOLUMN_PATH}" "/tmp/conf" &> /dev/null; then
    echo "Folders are identical"
  else
    post -c collection "${DATA_PATH}"
    cp -rf "${LOCAL_VOLUMN_PATH}" /tmp/
  fi
fi

if [ "$INITED" != "true" ]; then
  sleep 30
fi

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

echo `date` > "${LOCAL_VOLUMN_PATH}/.docker-web.ready"

# ----------------------------------------------------------------

while true; do
  sleep 10
done