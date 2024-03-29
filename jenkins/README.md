
## Roadie Jenkins

This chart sets up access to your Jenkins instance from Roadie so that the Backstage Jenkins plugin running in Roadie's infrastructure can read information instance.

The chart can be installed like this when you are connected to the cluster you want to add it to:
```shell
helm repo add roadie https://charts.roadie.io
helm install jenkins roadie/jenkins -f custom-jenkins-values.yaml
```

Where `custom-jenkins-values.yaml` is a file copied from the ./values.yaml file with your own values inserted. 

# Testing

Generate test charts using `helm template` i.e. for the Broker configuration `helm template . --set "broker.token=test1,broker.tenantName=my-roadie-tenant,broker.env[0].name=JENKINS_USERNAME,broker.env[0].value=tester,broker.env[1].name=JENKINS_PASSWORD,broker.env[1].value=123"` etc

# Broker Configuration

To enable the Roadie Broker on your infra so that Roadie can connect to you Jenkins server without needing any secrets, add the following to an override `custom-jenkins-values.yaml` file and pass it to the `helm install` command. 
```yaml
broker:
  enabled: true
  token: <some-secret-string>
  tenantName: <your-roadie-tenant-name>
  serviceAccount:
    name: roadie-jenkins-broker
  deployment:
    name: roadie-jenkins-broker
  env:
    - name: JENKINS_USERNAME
      value: <username>
    - name: JENKINS_PASSWORD
      value: <password>
```

Connect to the cluster you want to expose to Roadie and install this chart:
```shell
helm repo add roadie https://charts.roadie.io
helm install jenkins roadie/jenkins -f custom-jenkins-values.yaml -n <some-namespace> --create-namespace
```


