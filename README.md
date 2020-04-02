# *total-cluster* <img alt="kind" src="./docs/total-cluster-kitchen-sink.png" width="250x" align=right />

A tool for running an enterprise-grade application
stack powered by MongoDB running in any Kubernetes cluster.

total-cluster is designed to improve the quality of life for technology
professionals, giving them a simple out-of-box cloud-native
Kubernetes environement running securely with MongoDB Enterprise
Data Service. Once installed, total cluster is ready to provide
data services for your apps.

total-cluster should only be used for development and testing; it's
ideally suited for demonstration and proof-of-concept tasks.

**NOTE**: total-cluster is still a work in progress.

## Get started

To install all base components and start
a MongoDB database:

```bash
helm install mongodb .
kubectl port-forward mongodb-ops-manager-0 8080:8080
```


You can connect to the database with the `uri` found
in the binding secret.


## Setups

* extra-lite.values.yaml
    - MongoDB Kubernetes Operator
    - MongoDB Cloud Manager connection
    - Local 3-node MongoDB replica set
    
* lite.values.yaml
    - MongoDB Kubernetes Operator
    - MongoDB Ops Manager
      - 3-node app db
    - Local 3-node MongoDB replica set

* standard.values.yaml
    - MongoDB Kubernetes Operator
    - MongoDB Ops Manager
      - 3-node app db
    - Local 3-node MongoDB replica set
    - Node affinity for Ops Manager and dbs
    - DB pod spec overrides
    - Local Mail server
*

## GCE

Installs an n-node k3s cluster into GCE vms.

```bash
./mongodb-k3sup-gcp.sh
```
