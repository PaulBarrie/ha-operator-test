#!/bin/bash

DEFAULT_NUMBER_OF_INSTANCES=5
DEFAULT_NUMBER_OF_REPLICA_PER_INSTANCE=3
DEFAULT_SERVICE_BASE="instance"
INSTANCE_SEPARATOR="_"
CHART_FOLDER=api-ha-test

number_of_instances=$1
number_of_replica_per_instance=$2
fake_app_boot_time=$3
neighbor_base_host=$4


function getNeighborhoodInstances() {
    local instance=$1
    local number_of_instances=$2
    res=""
    for i in $(seq 1 "$number_of_instances")
    do
        if [ "$i" -ne "$instance" ] ; then
          res+="$neighbor_base_host-$i-$CHART_FOLDER$INSTANCE_SEPARATOR"
        fi
    done
    # shellcheck disable=SC2046
    # shellcheck disable=SC2005
    # shellcheck disable=SC2015
    trimmedRes="$([[ "${res:0-1}" = "$INSTANCE_SEPARATOR" ]] && echo "${res:0:-1}" || echo "$res" )"
    echo "$trimmedRes"
}


if [ -z "$number_of_instances" ] ; then
    echo "Usage: $0 number_of_instances number_of_replica_per_instance"
    echo "Take default $DEFAULT_NUMBER_OF_INSTANCES"
    number_of_instances=$DEFAULT_NUMBER_OF_INSTANCES
fi
if [ -z "$number_of_replica_per_instance" ] ; then
    echo "Usage: $0 number_of_instances number_of_replica_per_instance"
    echo "Take default $DEFAULT_NUMBER_OF_REPLICA_PER_INSTANCE"
    number_of_replica_per_instance=$DEFAULT_NUMBER_OF_REPLICA_PER_INSTANCE
fi
if [ -z "$neighbor_base_host" ] ; then
    echo "Usage: $0 number_of_instances number_of_replica_per_instance neighbor_base_host"
    echo "Take default $DEFAULT_SERVICE_BASE"
    neighbor_base_host=$DEFAULT_SERVICE_BASE
fi

for i in $(seq 1 $number_of_instances)
do
    echo "Creating instance $i"
    # shellcheck disable=SC2091
    neighborhood=$(getNeighborhoodInstances "$i" $number_of_instances)

    if [ -z "$fake_boot_time" ]; then
      helm install "instance-$i" "$CHART_FOLDER" \
                 --set replicaCount=$number_of_replica_per_instance \
                 --set "neighborhoodList=$neighborhood" \
                 --set "container.bootTime=$fake_app_boot_time"
    else
       helm install "instance-$i" "$CHART_FOLDER" \
                       --set replicaCount=$number_of_replica_per_instance \
                       --set "neighborhoodList=$neighborhood"
    fi
done

helm ls --all-namespaces
exit 0