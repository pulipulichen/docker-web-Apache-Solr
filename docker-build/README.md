# Dockerhub

- https://docs.docker.com/get-started/04_sharing_app/
- `docker image ls | head` 找出合適的名稱，例如「html-webpage-dashboard_app」
- 建立合適的repo https://hub.docker.com/

- 修改commit-docker-image.sh
- 修改udocker.sh
IMAGE_NAME=pudding/docker-web:docker-web-apache-solr-app-20231101-0056

- 修改docker-compose-template.yaml
image: pudding/docker-web:docker-web-apache-solr-app-20231101-0056

- 加入到監控清單 https://github.com/democwise2016/dockerhub-image-refresher/edit/main/docker-image-list.txt