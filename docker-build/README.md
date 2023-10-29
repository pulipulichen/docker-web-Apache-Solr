# Dockerhub

- https://docs.docker.com/get-started/04_sharing_app/
- `docker image ls | head` 找出合適的名稱，例如「html-webpage-dashboard_app」
- 建立合適的repo https://hub.docker.com/
- `docker tag docker-web-wiki-app pudding/docker-web:pwiki-20231029-0339`
- `docker push pudding/docker-web:pwiki-20231029-0339`
- 修改docker-compose.yaml `image: pudding/docker-web:pwiki-20231029-0339`
- 加入到監控清單 https://github.com/democwise2016/dockerhub-image-refresher/edit/main/docker-image-list.txt