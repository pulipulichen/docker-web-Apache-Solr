#!/bin/bash

# 使用說明
# - 對外port必須是8000
# - 如用到目錄，必須事前建立
# - 目錄路徑必須是完整路徑

PROJECT_NAME=docker-web-wiki
IMAGE_NAME=pudding/docker-web:pwiki-20231029-0339
LOCAL_VOLUMN_PATH=/var/www/html/
LOCAL_PORT=80

mkdir -p "/content/${PROJECT_NAME}"
nohup udocker --allow-root run -p "8000:${LOCAL_PORT}" --volume="/content/${PROJECT_NAME}:${LOCAL_VOLUMN_PATH}" ${IMAGE_NAME} > .nohup.out 2>&1 &


