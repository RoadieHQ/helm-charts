
## Roadie K8s read access 

This chart sets up read access to your Kubernetes cluster from Roadie so that the Backstage Kubernetes plugin running in Roadie's infrastructure can read information from your cluster running in AWS.

You can optionally set this up to work through [the Broker](https://roadie.io/docs/integrations/broker/) by overriding the `broker.enabled` value and adding your tenant's name i.e. `https://<tenant-name>.roadie.so` 

The chart can be installed like this when you are connected to the cluster you want to add it to:
```shell
helm repo add roadie https://charts.roadie.io
helm install roadie-kubernetes-cluster-access roadie/roadie-kubernetes
```

# Test

To enable the Roadie Broker on your infra so that Roadie can connect to you Kubernetes clusters without needing any secrets, add the following to an override `test-values.yaml` file and pass it to the `helm install` command. 
```yaml
broker:
  enabled: true
  token: <some-secret-string>
  tenantName: <your-roadie-tenant-name>
  serviceAccount:
    name: roadie-test-broker
  deployment:
    name: roadie-test-broker
```

Connect to the cluster you want to expose to Roadie and install this chart:
```shell
helm install roadie-kubernetes-cluster-access ./roadie-kubernetes-cluster-access -f test-values.yaml -n <some-namespace> --create-namespace
```


