#!/bin/bash

set -u
. ./clusters/k3sup-gce.sh up

# Kubernetes Dashboard
kubectl apply -f addons/dashboard/*.yaml

# MongoDB Enterprise Data Services
kubectl create ns mongodb
helm install -n mongodb mongodb .

