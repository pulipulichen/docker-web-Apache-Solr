FROM solr:9.4.0

#RUN sed -i '/jessie-updates/d' /etc/apt/sources.list

# RUN apt-get update
# RUN apt-get install -y wget nano curl wget rsync

# RUN mkdir -p /docker-build/
# RUN mkdir -p /app/
# COPY ./docker-build/app /docker-build/app
# COPY ./docker-build/startup.sh /startup.sh

ENV LOCAL_VOLUMN_PATH=/opt/solr-9.4.0/
ENV SHARED_PATH=/opt/solr-9.4.0/
ENV LOCAL_PORT=8983

# ENTRYPOINT []
# CMD ["bash", "/startup.sh"]