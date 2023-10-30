#!/bin/bash

cp -rf ./docker-web-Apache-Solr/* ./docker-build/conf/; 
rm -f ./docker-build/conf/.cloudflare.url
rm -f ./docker-build/conf/solrconfig.xml.txt