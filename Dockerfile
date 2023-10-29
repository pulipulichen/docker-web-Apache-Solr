FROM solr:8.7.0

USER root

RUN apt-get update
RUN apt-get install -y curl wget nano rsync mlocate
RUN updatedb

#RUN sed -i '/jessie-updates/d' /etc/apt/sources.list

# RUN apt-get update
# RUN apt-get install -y wget nano curl wget rsync

RUN mkdir -p /docker-build/
RUN chown solr:solr -R /docker-build/

#ENV LOCAL_VOLUMN_PATH=/opt/solr-9.4.0/
#ENV SHARED_PATH=/opt/solr-9.4.0/
ENV LOCAL_PORT=8983

#RUN mv /opt/solr-9.4.0 /opt/solr-9.4.0-original
#RUN chown solr:solr -R /opt/solr-9.4.0-original

#RUN mkdir -p /opt/solr-9.4.0
#RUN chown solr:solr -R /opt/solr-9.4.0

#ENTRYPOINT []
#CMD ["bash", "/startup.sh"]

#USER solr

# RUN mkdir -p /app/
# COPY ./docker-build/app /docker-build/app
COPY ./docker-build/console.sh /console.sh
COPY ./docker-build/startup.sh /startup.sh

CMD ["solr-foreground", "-force"]