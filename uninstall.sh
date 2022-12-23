#!/bin/bash

nb_of_instances=$1

if [ -z "$nb_of_instances" ] ; then
    echo "Usage: $0 number_of_instances"
    exit 1
fi

for i in $(seq 1 "$nb_of_instances")
do
    echo "Deleting instance $i"
    helm uninstall "instance-$i"
done

helm ls --all-namespaces
