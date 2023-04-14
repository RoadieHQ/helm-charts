
## Roadie K8s read access - service account

This chart sets up read access to your Kubernetes cluster from Roadie so that the Backstage Kubernetes plugin running in Roadie's infrastructure can read information from your cluster running in AWS.

The cluster role cand be installed like this when you are connected to the cluster you want to add it to in your kube config:

```shell
helm repo add roadie https://charts.roadie.io
helm install roadie-kubernetes-broker-access roadie/roadie-kubernetes
```

