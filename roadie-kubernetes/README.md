
## Roadie K8s read access role

This chart sets up read access to your Kubernetes cluster from Roadie so that the Backstage Kubernetes plugin running in Roadie's infrastructure can read information from your cluster running in AWS.

The cluster role cand be installed like this when you are connected to the cluster you want to add it to in `kubectl`:

```shell
helm repo add roadie https://charts.roadie.io
helm install roadie-kubernetes-cluster-access roadie/roadie-kubernetes
```

