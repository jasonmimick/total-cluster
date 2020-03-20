#!/bin/bash
set -u
set -x
for zone in "us-central1-b" "us-central1-c"; do
  gcloud compute instances list --format="get(name,zone)" | \
  grep ${zone} | cut -f1 | \
  xargs gcloud compute instances delete -q --zone ${zone} --delete-disks all 
done


