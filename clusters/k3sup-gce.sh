#!/bin/bash

set -u
set -x
echo "Installing MongoDB Enterprise Data Services Cluster"
echo "Powered by Google Compute Engine"
echo "mongodb-k3s sandbox demonstration kit"
echo "For research & development purposes only."
echo "Settings:"
ORG="mongodb-k3s"
NEW_TAG=$( curl -s https://frightanic.com/goodies_content/docker-names.php | tr '_' '-' )
NEW_CLUSTER_TAG="${ORG}-${NEW_TAG}"
CLUSTER_TAG=${CLUSTER_TAG:-${NEW_CLUSTER_TAG}}
DB_WORKER_INSTANCE_TYPE=${DB_WORKER_INSTANCE_TYPE:-n1-standard-1}
OPS_MANAGER_DB_WORKER_INSTANCE_TYPE=${OPS_MANAGER_DB_WORKER_INSTANCE_TYPE:-n1-standard-8}
ZONE_A=${ZONE_A:-us-central1-b}
ZONE_B=${ZONE_B:-us-central1-c}
MMS_NODES_TAG="${CLUSTER_TAG}-ops-manager"
NUM_DB_WORKER_NODES_ZONE_A=3
NUM_DB_WORKER_NODES_ZONE_B=2
MMS_NODES_ZONE_A=2
MMS_NODES_ZONE_B=2

up() {
    (
    set -x

    echo "Creating MASTER node"
    gcloud compute instances create "${CLUSTER_TAG}-master" \
        --machine-type "${DB_WORKER_INSTANCE_TYPE}" \
        --zone="${ZONE_A}" --tags "${ORG}","${CLUSTER_TAG}","${CLUSTER_TAG}-master"
    

    echo "Creating ${NUM_DB_WORKER_NODES_ZONE_A} workers in ${ZONE_A}"
    echo "---------------------------------------------------------"
    for i in $(seq 1 ${NUM_DB_WORKER_NODES_ZONE_A}); do
      gcloud compute instances create \
          "${CLUSTER_TAG}-worker-a-${i}" \
          --machine-type "${DB_WORKER_INSTANCE_TYPE}" \
          --zone="${ZONE_A}" \
          --tags "${ORG}","${CLUSTER_TAG}","${CLUSTER_TAG}-worker","${CLUSTER_TAG}-worker-a"
    done

    echo "Creating ${NUM_DB_WORKER_NODES_ZONE_B} workers in ${ZONE_B}"
    echo "---------------------------------------------------------"
    for i in $(seq 1 ${NUM_DB_WORKER_NODES_ZONE_B}); do
      gcloud compute instances create \
          "${CLUSTER_TAG}-worker-b-${i}" \
          --machine-type "${DB_WORKER_INSTANCE_TYPE}" \
          --zone="${ZONE_B}" \
          --tags "${ORG}","${CLUSTER_TAG}","${CLUSTER_TAG}-worker","${CLUSTER_TAG}-worker-b"
    done


    echo "Creating ${MMS_NODES_ZONE_A} Ops Manager nodes in ${ZONE_A}"
    echo "---------------------------------------------------------"
    for i in $(seq 1 ${NUM_OPS_MANAGER_NODES}); do
    gcloud compute instances create "${MMS_NODES_TAG}-a-${i}" \
        --machine-type "${OPS_MANAGER_DB_WORKER_INSTANCE_TYPE}" \
        --zone="${ZONE_A}" \
        --tags "${ORG}","${CLUSTER_TAG}","${MMS_NODES_TAG}","${MMS_NODES_TAG}-a"
    done

    echo "Creating ${MMS_NODES_ZONE_B} Ops Manager nodes in ${ZONE_B}"
    echo "---------------------------------------------------------"
    for i in $(seq 1 ${MMS_NODES_ZONE_B}); do
    gcloud compute instances create "${MMS_NODES_TAG}-b-${i}" \
        --machine-type "${OPS_MANAGER_DB_WORKER_INSTANCE_TYPE}" \
        --zone="${ZONE_B}" \
        --tags "${ORG}","${CLUSTER_TAG}","${MMS_NODES_TAG}","${MMS_NODES_TAG}-b"
    done


    echo "Creating 1 Ops Manager Backup Daemon in ${ZONE_B}"
    echo "---------------------------------------------------------"
    gcloud compute instances create "${MMS_NODES_TAG}-backup-daemon" \
        --machine-type "${OPS_MANAGER_DB_WORKER_INSTANCE_TYPE}" \
        --zone="${ZONE_B}" \
        --tags "${ORG}","${CLUSTER_TAG}","${MMS_NODES_TAG}","${MMS_NODES_TAG}-${ZONE_B}","${MMS_NODES_TAG}-backup-daemon"

    gcloud compute config-ssh
    )

    primary_server_ip=$(gcloud compute instances list \
    --filter=tags.items="${CLUSTER_TAG}-master" \
    --format="get(networkInterfaces[0].accessConfigs.natIP)")

    (
    set -x
    k3sup install --ip "${primary_server_ip}" \
                  --context "${CLUSTER_TAG}" \
                  --ssh-key ~/.ssh/google_compute_engine \
                  --user $(whoami)

    gcloud compute firewall-rules create "${CLUSTER_TAG}" \
                  --allow=tcp:6443 \
                  --target-tags="${CLUSTER_TAG}"

    echo "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm"
    echo "k3sup for: $(gcloud compute instances list --filter=tags.items="${CLUSTER_TAG}-worker" --format="get(name)")"
    echo "wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"

    gcloud compute instances list \
        --filter=tags.items="${CLUSTER_TAG}-worker" \
        --format="get(networkInterfaces[0].accessConfigs.natIP)" | \
            xargs -L1 k3sup join \
            --server-ip $primary_server_ip \
            --ssh-key ~/.ssh/google_compute_engine \
            --user $(whoami) \
            --ip

    echo "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm"
    echo "k3sup for: $(gcloud compute instances list \
         --filter=tags.items="${MMS_NODES_TAG}" \
         --format="get(name)")"
    echo "wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww"

    gcloud compute instances list \
        --filter=tags.items="${MMS_NODES_TAG}" \
        --format="get(networkInterfaces[0].accessConfigs.natIP)" | \
            xargs -L1 k3sup join \
            --server-ip $primary_server_ip \
            --ssh-key ~/.ssh/google_compute_engine \
            --user $(whoami) \
            --ip
    )

    echo "mmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmmm: sleep 5 seconds."
    sleep 5
    export KUBECONFIG=`pwd`/kubeconfig
    kubectl get nodes

    echo "Adding labels to nodes. This controls how MongoDB components are deployed."
    echo "---------------------------------------------------------"
    echo "MongoDB Cluster Kubernetes Worker Nodes (${NUM_DB_WORKER_NODES_ZONE_A}) in ZONE_A=${ZONE_A}"
    for i in $(seq 1 ${NUM_DB_WORKER_NODES_ZONE_A}); do
      kubectl label node "${CLUSTER_TAG}-worker-a-${i}" kubernetes.io/role=mongodb-node
    done
    echo "MongoDB Cluster Kubernetes Worker Nodes (${NUM_DB_WORKER_NODES_ZONE_B}) in ZONE_B=${ZONE_B}"
    for i in $(seq 1 ${NUM_DB_WORKER_NODES_ZONE_B}); do
      kubectl label node "${CLUSTER_TAG}-worker-b-${i}" kubernetes.io/role=mongodb-node
    done

    echo "MongoDB Ops Manager Kubernetes Worker Nodes (${MMS_NODES_ZONE_A}) in ZONE_A=${ZONE_A}"
    for i in $(seq 1 ${MMS_NODES_ZONE_A}); do
      kubectl label node "${MMS_NODES_TAG}-a-${i}" kubernetes.io/role=mongodb-ops-manager
    done
    echo "MongoDB Ops Manager Kubernetes Worker Nodes (${MMS_NODES_ZONE_B}) in ZONE_B=${ZONE_B}"
    for i in $(seq 1 ${MMS_NODES_ZONE_B}); do
      kubectl label node "${MMS_NODES_TAG}-b-${i}" kubernetes.io/role=mongodb-ops-manager
    done

    echo " MongoDB Ops Manager Backup Daemon Kubernetes Worker Node in- ZONE_B=${ZONE_B}"
    kubectl label node ${MMS_NODES_TAG}-backup-daemon kubernetes.io/role=mongodb-ops-manager-backup-daemon
    echo "---------------------------------------------------------"

}

down() {
    CLUSTER_TAG="${1}"
    MMS_NODES_TAG="${CLUSTER_TAG}-ops-manager"
    (
    set -x
    gcloud compute instances list \
        --filter=tags.items="${CLUSTER_TAG}-worker" --format="get(name)" | \
            xargs gcloud compute instances delete \
              --zone "${ZONE}" -q --delete-disks all 
    gcloud compute instances list \
        --filter=tags.items="${MMS_NODES_TAG}-${ZONE}" --format="get(name)" | \
            xargs gcloud compute instances delete \
              --zone "${ZONE}" -q --delete-disks all 
    gcloud compute instances list \
        --filter=tags.items="${MMS_NODES_TAG}-${ZONE_DR}" --format="get(name)" | \
            xargs gcloud compute instances delete \
              --zone "${ZONE_DR}" -q --delete-disks all 
    gcloud compute instances list \
        --filter=tags.items="${CLUSTER_TAG}-master" --format="get(name)" | \
            xargs gcloud compute instances delete \
              --zone "${ZONE}" -q --delete-disks all 

    gcloud compute firewall-rules delete "${CLUSTER_TAG}" -q
    )
}

list() {
    (
    set -x
    gcloud compute instances list \
        --filter=tags.items="${ORG}"
    )
}

usage() {
    echo "Bootstrap or tear down a mongodb-k8s cluster running k3s on GCE"
    echo "k3sup-gcp up"
    echo "   Provisions k3s cluster. Sets CLUSTER_TAG env variable. " 
    echo ""
    echo "k3sup down <CLUSTER_TAG>"
    echo "   Tears down cluster, requires CLUSTER_TAG argument."
}

case "${1:-usage}" in
  list)
    shift
    list "$@"
    ;;
  up)
    shift
    up "$@"
    ;;
  down)
    shift
    down "$@"
    ;;
  *)
    usage
    exit 1
    ;;
esac
