<p align="center">
    <img alt="kind" src="./docs/total-cluster-kitchen-sink.png" width="250x" />
</p>

# *total-cluster* 

A tool for running an enterprise-grade application
stack powered by MongoDB running in any Kubernetes cluster.

total-cluster is designed to improve the quality of life for technology 
professionals, giving them a simple out-of-box cloud-native
Kubernetes environement running security with MongoDB Enterprise
Data Service.

total-cluster should only be used for development and testing; it's 
ideally suited for proof-of-concent.

**NOTE**: total-cluster is still a work in progress.

# total-cluster

Total Cluster: 
![alt text][logo]

[logo]: ./docs/total-cluster-kitchen-sink.png "Total Cluster" 100x


## Get started

To install all base components and start
a MongoDB database:

```
helm install mongodb mongodb-k8s
kubectl port-forward mongodb-ops-manager-0 8080:8080
```

You can connect to the database with the `uri` found
in the binding secret.


## GCE

Installs an n-node k3s cluster into GCE vms.

./mongodb-k3sup-gcp.sh

