FROM solr:8.7.0

USER root

RUN apt-get update
RUN apt-get install -y curl wget nano rsync mlocate vim
RUN updatedb
RUN apt-get install -y pip
RUN pip install pyexcel==0.7.0 pyexcel-ods==0.6.0 pandas==2.1.2 requests==2.31.0

#RUN sed -i '/jessie-updates/d' /etc/apt/sources.list

# RUN apt-get update
# RUN apt-get install -y wget nano curl wget rsync

#RUN mkdir -p /docker-build/
#RUN chown solr:solr -R /docker-build/

ENV LOCAL_VOLUMN_PATH=/var/solr/data/collection/conf/
#ENV SHARED_PATH=/opt/solr-9.4.0/
ENV LOCAL_PORT=8983

#RUN mv /opt/solr-9.4.0 /opt/solr-9.4.0-original
#RUN chown solr:solr -R /opt/solr-9.4.0-original

#RUN mkdir -p /opt/solr-9.4.0
#RUN chown solr:solr -R /opt/solr-9.4.0

ENTRYPOINT []
CMD ["bash", "/startup.sh"]

#USER solr

RUN mkdir -p /var/solr/data/collection/conf
RUN echo "name=collection" > /var/solr/data/collection/core.properties
RUN mkdir -p /docker-build/conf
COPY ./docker-build/jetty.xml /opt/solr-8.7.0/server/etc/jetty.xml
COPY ./docker-build/conf /docker-build/conf
RUN chmod -R 777 "/docker-build/conf/"
COPY ./docker-build/console.sh /console.sh
COPY ./docker-build/startup.sh /startup.sh

# CMD ["solr-foreground", "-force"]
RUN echo "20231101-0056"