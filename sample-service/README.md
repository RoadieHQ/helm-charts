The sample service is a small HTTP API which is used for testing various integrations.

This repo contains a simple Helm chart for deploying the sample service on Kubernetes.

The code for the sample service can be found at [RoadiqHQ/sample-service](https://github.com/roadiehq/sample-service).

# Deployment

```shell
helm repo add roadie https://charts.roadie.io
helm install sample-service roadie/sample-service
```

# Upgrade

```shell
# update the helm repos
helm repo update
# check to see if the version is there
helm search repo roadie
# update
helm upgrade sample-service roadie/sample-service --version <your new version> --debug
```
