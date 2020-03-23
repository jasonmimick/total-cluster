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

After a bit, `kubectl get all` should look like:
```bash
kga                                                
NAME                                      READY   STATUS    RESTARTS   AGE
pod/mongodb-operator-65f9455545-xqcd2     1/1     Running   0          6h4m
pod/mongodb-ui-5c45bfd7fb-tkwjr           1/1     Running   0          6h4m
pod/mongodb-0                             1/1     Running   0          5h55m
pod/mongodb-ops-manager-backup-0          1/1     Running   0          5h54m
pod/mongodb-ops-manager-backup-1          1/1     Running   0          5h54m
pod/mongodb-1                             1/1     Running   0          5h54m
pod/mongodb-2                             1/1     Running   0          5h54m
pod/mongodb-ops-manager-db-1              1/1     Running   0          6h3m
pod/mongodb-ops-manager-db-0              1/1     Running   0          6h4m
pod/mongodb-ops-manager-db-2              1/1     Running   0          6h2m
pod/mongodb-mail-678d49d55d-spzgh         1/1     Running   0          5m30s
pod/mongodb-ops-manager-0                 1/1     Running   0          4m40s
pod/mongodb-ops-manager-backup-daemon-0   1/1     Running   0          2m19s

NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)     AGE
service/kubernetes                   ClusterIP   10.43.0.1       <none>        443/TCP     6h13m
service/mongodb-ui                   ClusterIP   10.43.248.150   <none>        6000/TCP    6h4m
service/mongodb-ops-manager-db-svc   ClusterIP   None            <none>        27017/TCP   6h4m
service/mongodb-ops-manager-svc      ClusterIP   None            <none>        8080/TCP    6h2m
service/mongodb                      ClusterIP   None            <none>        27017/TCP   5h55m
service/mongodb-ops-manager-backup   ClusterIP   None            <none>        27017/TCP   5h54m
service/mongodb-mail                 ClusterIP   10.43.52.146    <none>        25/TCP      5m30s

NAME                               READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mongodb-operator   1/1     1            1           6h4m
deployment.apps/mongodb-ui         1/1     1            1           6h4m
deployment.apps/mongodb-mail       1/1     1            1           5m30s

NAME                                          DESIRED   CURRENT   READY   AGE
replicaset.apps/mongodb-operator-65f9455545   1         1         1       6h4m
replicaset.apps/mongodb-ui-5c45bfd7fb         1         1         1       6h4m
replicaset.apps/mongodb-mail-678d49d55d       1         1         1       5m30s

NAME                                                 READY   AGE
statefulset.apps/mongodb-ops-manager-backup          2/2     5h54m
statefulset.apps/mongodb                             3/3     5h55m
statefulset.apps/mongodb-ops-manager-db              3/3     6h4m
statefulset.apps/mongodb-ops-manager                 1/1     6h2m
statefulset.apps/mongodb-ops-manager-backup-daemon   1/1     5h56m
```

You can connect to the database with the `uri` found
in the binding secret.

```bash
 k describe secret mongodb-db-binding                                           5041  17:42:35  
Name:         mongodb-db-binding
Namespace:    default
Labels:       product=mongodb-k8s
Annotations:  
Type:         Opaque

Data
====
uri:  62 bytes
```

## GCE

Installs an n-node k3s cluster into GCE vms.

```bash
./mongodb-k3sup-gcp.sh
```
