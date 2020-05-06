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

**TODO** add info to create apikey cloud.mongodb.com

You can connect to the database with the `uri` found
in the binding secret.


## Setups

There are various levels of 'sophisication' you can choose for your total cluster, each level adds more locally deployed data platform components.

The minimalist setup is **_extra-lite_**. 

This uses [MongoDB Cloud Manager](http://http://docs.cloudmanager.mongodb.com/) an enterprise db devops tool, and the  [MongoDB Kubernetes](https://docs.mongodb.com/kubernetes-operator/master/) operator.

* [extra-lite.values.yaml](extra-lite.values.yaml)
    - MongoDB Kubernetes Operator
    - MongoDB Cloud Manager connection
    - Local 3-node MongoDB replica set
    
The **_lite_** setup switches to a minimalist local (MongoDB Ops Manager) deployment. This setup does not support Ops Manager backups out-of-the-box. (But you can always add it yourself, now or later.)

* [lite.values.yaml](lite.values.yaml)
    - MongoDB Kubernetes Operator
    - MongoDB Ops Manager
      - 3-node app db
    - Local 3-node MongoDB replica set

The first almost prod-ready option is the **_standard_** package. This adds local Ops Manager backups, HA Ops Manager backing datastores. When properly configured this option can support air-gapped environments.

_Note:_ The [values.yaml](values.yaml) file is a copy of [standard.values.yaml](./standard.values.yaml) and therefore is the default option for total-cluster.

* [standard.values.yaml](./standard.values.yaml)
    - MongoDB Kubernetes Operator
    - MongoDB Ops Manager
      - 3-node app db
    - Local 3-node MongoDB replica set
    - Node affinity for Ops Manager and dbs
    - DB pod spec overrides
    - Local Mail server


Needed next levels:

Add Atlas Service Broker & Service Catalog.
Add support for locally defined "plans" to support Enterprise database-as-a-service requirements.

## GCE

Installs an n-node k3s cluster into GCE vms (assumes you have the [gcloud](https://cloud.google.com/sdk/gcloud) cli all setup.

```bash
./clusters/mongodb-k3sup-gcp.sh up
```

Currently, setup to demonstrate a minimal production-readly HA/DR platform. So, there a multiple dedicated Kubernetes worker nodes deployed across mutiple GCP zones.


## Replicated KOTS


