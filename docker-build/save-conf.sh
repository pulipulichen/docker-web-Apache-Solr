#!/bin/bash

cp -rf ./docker-web-Apache-Solr/* ./docker-build/conf/; 
rm -f ./docker-build/conf/data/data-temp.csv || true
rm -f ./docker-build/conf/.cloudflare.url || true
rm -f ./docker-build/conf/solrconfig.xml.txt || true