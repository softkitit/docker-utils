#!/usr/bin/env bash

#https://www.elastic.co/guide/en/elasticsearch/reference/7.5/docker.html

sysctl -w vm.max_map_count=262144
sudo echo "vm.max_map_count=262144" >> /etc/sysctl.conf
