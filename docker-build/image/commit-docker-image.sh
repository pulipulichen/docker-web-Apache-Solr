#!/bin/bash

IMAGE_NAME=pudding/docker-web:docker-web-apache-solr-app-20231101-0062

docker tag docker-web-apache-solr-app ${IMAGE_NAME}
docker push "${IMAGE_NAME}"