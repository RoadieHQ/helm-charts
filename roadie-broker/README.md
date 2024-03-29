
## Roadie Broker Chart

This chart sets up access to services hosted on internal infrastructure from Roadie so that the Backstage plugins running in Roadie's infrastructure can read information securely.

The chart can be installed like this when you are connected to the cluster you want to add it to:
```shell
helm repo add roadie https://charts.roadie.io
helm install broker-example roadie/broker-chart -f custom-values.yaml
```

Where `custom-values.yaml` is a file copied from the `./values.yaml` file with your own values inserted and an image specified. 

# Testing

Generate test charts using `helm template` i.e. for a Broker Jenkins configuration `helm template . --set "broker.image=roadiehq/broker:jenkins,broker.token=test1,broker.tenantName=my-roadie-tenant,broker.env[0].name=JENKINS_USERNAME,broker.env[0].value=tester,broker.env[1].name=JENKINS_PASSWORD,broker.env[1].value=123` etc

# Broker Configuration

To enable the Roadie Broker on your infra so that Roadie can connect to you internal services without needing any secrets, add the following to an override `custom-values.yaml` file and pass it to the `helm install` command. 
```yaml
broker:
  image: "roadiehq/broker:jenkins"
  token: <some-secret-string>
  tenantName: <your-roadie-tenant-name>
  env:
    - name: JENKINS_USERNAME
      value: test
    - name: JENKINS_PASSWORD
      value: 123
```

Connect to the cluster you want to expose to Roadie and install this chart:
```shell
helm repo add roadie https://charts.roadie.io
helm install jenkins roadie/jenkins -f custom-jenkins-values.yaml -n <some-namespace> --create-namespace
```


