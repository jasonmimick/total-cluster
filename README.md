# *total-cluster* <img alt="kind" src="./docs/total-cluster-kitchen-sink.png" width="250x" align=right />

A tool for running enterprise-grade application
stacks powered by MongoDB running in any Kubernetes cluster.

total-cluster is designed to improve the quality of life for technology
professionals, giving them a simple out-of-box cloud-native
Kubernetes environment running securely with MongoDB Enterprise
Data Services. Once installed, total cluster is ready to provide
data services for your apps.

total-cluster should only be used for development and testing; it's
ideally suited for demonstration and proof-of-concept tasks.

**NOTE**: total-cluster is still a work in progress. If you'd like to get involved making total-cluster better, then heck out the [addons](addons/README.md) page!

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

## What is total-cluster?

The total-cluster project is basically 1 main Helm chart along with sets of [addons](addons), [quickups](quickups), and [tools](tools). 

* addons - Additional Helm charts to add more functionality to the cluster. For example, minio or the YCSB load test.
* quickups - Helper scripts to spin up clusters and similar utilities.
* tools - Various other experimental items.

The main Helm chart builds the following:

templates
├── binding.yaml                               # Secret holding user database connection string
├── cloud-manager-config.yaml                  # Cloud Mgr credentials (optional)
├── cluster-backup.yaml                        # db cluster for Ops Mgr backups
├── cluster-cluster1.yaml                      # the db for user to use
├── deployment-mail.yaml                       # simple local smtp for Ops Mgr
├── deployment-ui.yaml                         # Experimental simple Operator ui
├── operator-roles.yaml                        # Standard MDB K8S operator roles
├── operator.yaml                              # MDB operator
├── ops-manager-admin.secret.yaml              # Creds for ops mgr
├── ops-manager.yaml                           # Ops mgr crd instance
└── service-ui.yaml                            # service for experimental ui

The end result of running this chart will be:

1. A 3-node replica set for use by users and apps
2. The MongoDB k8s operator
3. MongoDB Ops Mgr or connection to Cloud Manager
4. A Secret you can use to connect your apps

This means you can starting running your apps with MongoDB in Kubernetes with the push of a button.

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

## GKE

Very simple way to get started. Install the `gcloud` cli and create a Cloud Manager apikey at http://cloud.mongodb.com. Then,

```bash
git clone https://github.com/jasonmimick/total-cluster
cd total-cluster
gcloud container clusters create --zone us-central1-b total-cluster
gcloud container clusters get-credentials total-cluster
# installs to 'default' namespace; change that if you want to
helm install -f extra-lite.values.yaml \
             --set cloudManager.publicApiKey=<PUBLIC_KEY> \
             --set cloudManager.privateApiKey=<PRIVATE_KEY> \
             --set cloudManager.orgId=<CLOUD_MANAGER_ORG_ID> \
             total-cluster .

```

## GCE

Installs an n-node k3s cluster into GCE vms (assumes you have the [gcloud](https://cloud.google.com/sdk/gcloud) cli all setup.

```bash
./clusters/mongodb-k3sup-gcp.sh up
```

Currently, setup to demonstrate a minimal production-readly HA/DR platform. So, there a multiple dedicated Kubernetes worker nodes deployed across mutiple GCP zones.


## Replicated KOTS

Replicated [KOTS](https://kots.io) enables you to manage the app lifecycle of MongoDB Enterprise such as installs, upgrades, rollbacks, troubleshooting, snapshots, etc.

* Install kots as a `kubectl` plugin.
```shell
curl https://kots.io/install | bash
```
You can rerun the above `curl` command to upgrade `kots`.

* Install MongoDB Total Cluster
```shell
kubectl kots install mongodb-enterprise
```

* TODO: Download the license from the repo.
