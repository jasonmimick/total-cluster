diamanti-mongodb-ycsb-tests
---

These notes describe the tests and demonstrations from the MongoDB Diamanti blog post.

The following with run 2 YCSB workloads on MongoDB deployed
into a Diamanti Kubernetes Cluster along with both local
operator-managed MongoDB clusters or cloud-based Atlas MongoDB
clusters.

Inital setup
---
The following requires:

* k8s cluster
* kubectl 
* helm (tested helm V3)
* Service Catalog - for Atlas

```bash
kubectl create ns catalog
helm install catalog svc-cat/catalog --namespace catalog --version 0.3.0-beta.2
```

Create a MongoDB Cloud Manager apikey at http://cloud.mongodb.com

Local MongoDB Databases
---

The main 'total-cluster' chart installs the MongoDB Operator, a MongoDB Cloud Mgr connection,
and finally a locally running MongoDB 3-node replica set.

Perform all commands from the chart directory:

```
cd total-cluster
```

Update the `extra-lite.yaml` with your Cloud Manager apikey information.

We'll install the database systems as a Helm
release. The name of this release is *IMPORTANT*!
It is used directly as the name of the Project and the database cluster in
MongoDB Cloud Manager. For this example, we're calling the 
Helm release 'mongodb-test', so we'll get a project and a cluster in Cloud Manager
called 'mongodb-test'.

Use a new namespace for this test - we're calling
the namespace "local-test".


```
kubectl create ns local-test
kubectl config set-context --current --namespace local-test
helm install mongodb-test .
```

This will create a cluster called, "mongodb-test".
The chart will also create a Secret called "mongodb-test-db-binding" which you can use
to connect your app to this new cluster.

### Running Workloads

Each test consist of a 'load' and a 'run' phase and is installed with another Helm chart.

Run each test by switching to the `charts/ycsb` directory
and installing a Helm release for each phase.

```bash
cd charts/ycsb
```

First, run workload A:

```bash
helm install -f workload-a.yaml --set action=load --set binding=mongodb-test-db-binding ycsb-a-load .
```

wait till complete, then run:

```bash
helm install -f workload-a.yaml --set action=run --set binding=mongodb-test-db-binding ycsb-a-run .
```

You can view your database clusters in Cloud Manager.
Consult the details of your mongodb.mongodb.com CRD instance thusly,

```bash
kubectl describe mongodb mongodb-test
```
Check Cloud Manager projects here:
https://cloud.mongodb.com/v2#/org/5e43408aff7a254a660908d5/projects

MongoDB Atlas hosted MongoDB Database
---

TODO - update details for Atlas --

MongoDB Atlas databases can be used directly from your Kubernetes environment as well.
This uses the Atlas Service Broker to create a cluster for you.

This test requires Service Catalog in your Kubernetes 
cluster. Install it with:

```bash
helm repo add svc-cat https://svc-catalog-charts.storage.googleapis.com
kubectl create ns catalog
helm install catalog svc-cat/catalog --namespace catalog --version 0.3.0-beta.2
```

For best results, give your Service Catalog a minute or two to get started up.

Perform all commands from the chart directory:

```
cd total-cluster/charts
```

Install the base chart. This will install the MongoDB Atlas 
Open Service Broker, A MongoDB Atlas Connection, provision 2 
MongoDB Atlas databases, create 2 secrets with binding information
to the new MongoDB Atlas Databases. The instance settings for
these databases can be found here: 


```
helm install atlas-broker atlas-broker
```

```
helm install atlas-cluster atlas-cluster
```
Each test consist of a 'load' and a 'run' phase.
Run each phase for each test by installing a Helm release:


```bash
cd ycsb            # /mongodb-k8s-atlas/ycsb 
helm install -f workload-a.yaml --set action=load --set binding=atlas-db-small ycsb-workload-a-load .
```
wait till complete, then run:
```
helm install -f workload-a.yaml --set action=run --set binding=atlas-db-small ycsb-workload-a-run .
```

and likewise,

```bash
cd ycsb            # /mongodb-k8s-atlas/ycsb 
helm install -f workload-b.yaml --set action=load --set binding=atlas-db-large ycsb-workload-b-load .

helm install -f workload-b.yaml --set action=run --set binding=atlas-db-large ycsb-workload-b-run .
```

