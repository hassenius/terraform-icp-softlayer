#!/bin/bash

## First compile a list of all nodes in the cluster with ip addresses
declare -a clusterips
IFS=', ' read -r -a clusterips <<< $(cat ${WORKDIR}/clusterlist.txt)

for ((i=0; i<${#clusterips[*]}; i++));
do
  # Allow all traffic from the clusterips
  sudo iptables -I INPUT -p all -s ${clusterips[i]} -j ACCEPT 
done
