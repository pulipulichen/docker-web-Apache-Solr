#!/bin/bash

# 使用說明
# - 對外port必須是8000
# - 如用到目錄，必須事前建立
# - 目錄路徑必須是完整路徑

PROJECT_NAME=docker-web-Apache-Solr
IMAGE_NAME=pudding/docker-web:docker-web-apache-solr-app-20231031-0351
LOCAL_VOLUMN_PATH=/var/solr/data/collection/conf
LOCAL_PORT=8983
RUN_IN_BACKGROUND=false

echo "Image: ${IMAGE_NAME}"

mkdir -p "/content/${PROJECT_NAME}"

udocker --allow-root rm $(udocker --allow-root ps -m -s | awk 'NR>1 {print $1}')

if [ "$RUN_IN_BACKGROUND" = true ]; then
    echo "Run container in background.."
    nohup udocker --allow-root run -p "${LOCAL_PORT}:${LOCAL_PORT}" --volume="/content/${PROJECT_NAME}:${LOCAL_VOLUMN_PATH}" ${IMAGE_NAME} > .nohup.out 2>&1 &
else
    echo "Run container in foreground.."
    udocker --allow-root run -p "${LOCAL_PORT}:${LOCAL_PORT}" --volume="/content/${PROJECT_NAME}:${LOCAL_VOLUMN_PATH}" ${IMAGE_NAME}
fi
