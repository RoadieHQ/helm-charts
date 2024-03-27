
## Roadie Jenkins

This chart sets up access to your Jenkins instance from Roadie so that the Backstage Jenkins plugin running in Roadie's infrastructure can read information instance.

You can optionally set this up to work through [the Broker](https://roadie.io/docs/integrations/broker/) by overriding the `broker.enabled` value and adding your tenant's name i.e. `https://<tenant-name>.roadie.so` 

The chart can be installed like this when you are connected to the cluster you want to add it to:
```shell
helm repo add roadie https://charts.roadie.io
helm install jenkins roadie/jenkins
```

# Testing

Generate test charts using `helm template` i.e. for the Broker configuration `helm template . --set broker.enabled=true,broker.token=test1` etc

# Broker Configuration

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
helm repo add roadie https://charts.roadie.io
helm install jenkins roadie/jenkins -f test-values.yaml -n <some-namespace> --create-namespace
```


