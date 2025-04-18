
## Roadie Broker Chart

This chart sets up secure access to services (like Jenkins) hosted on internal infrastructure from Roadie so that the Backstage plugins running in Roadie's infrastructure can read information without exposing secrets to Roadie.

It is designed to use images with the [Snyk Broker client](https://docs.snyk.io/enterprise-setup/snyk-broker) configured with `accept.json` for different services. Some images have already been created by Roadie for immediate use and can be found here [https://hub.docker.com/r/roadiehq/broker](https://hub.docker.com/r/roadiehq/broker/tags?page=1&ordering=name)

The chart can be installed like this when you are connected to the cluster you want to add it to:
```shell
helm repo add roadie https://charts.roadie.io
helm install <roadie-broker-custom> roadie/roadie-broker -f custom-values.yaml
```

Where `custom-values.yaml` is a file copied from the `./values.yaml` file with your own values inserted and an image specified. 

i.e.
```yaml
broker:
  image: <required>
  token: <required>
  tenantName: <required>
  appName: <required>
  env:
    - name: SOME_SECRET_TOKEN
      value: 1234
```

# Configuration

To enable the Roadie Broker on your infra so that Roadie can connect to you internal services without needing any secrets, add the following to an override `custom-values.yaml` file and pass it to the `helm install` command. 

Available broker images can be found on DockerHub here [https://hub.docker.com/r/roadiehq/broker](https://hub.docker.com/r/roadiehq/broker/tags?page=1&ordering=name). Each image requires certain environment variables that must be passed through like so:

e.g.
```yaml
broker:
  image: "roadiehq/broker:jenkins"
  token: <broker-token>
  tenantName: <your-roadie-tenant-name>
  appName: roadie-jenkins-broker
  logLevel: debug
  env:
    - name: JENKINS_URL
      value: <jenkins-URL>
    - name: JENKINS_USERNAME
      value: test
    - name: JENKINS_PASSWORD
      value: 123
```

You can add debug logging for testing purposes with the following values:

```yaml
broker:
  ...
  logLevel: debug
  logBody: true
```

Connect to the cluster you want to deploy this in and install the chart:

e.g. For a Jenkins client:
```shell
helm repo add roadie https://charts.roadie.io
helm install roadie-jenkins-broker roadie/roadie-broker -f custom-jenkins-values.yaml -n <some-namespace> --create-namespace
```

NB: this cluster must have network access to the service you are trying to connect to. 

# Testing

Generate test charts using `helm template` i.e. for a Broker Jenkins configuration `helm template . --set "broker.image=roadiehq/broker:jenkins,broker.token=test1,broker.tenantName=my-roadie-tenant,broker.env[0].name=JENKINS_USERNAME,broker.env[0].value=tester,broker.env[1].name=JENKINS_PASSWORD,broker.env[1].value=123` etc

