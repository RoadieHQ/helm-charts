This repository contains public Helm charts for Roadie.

## Using the charts

Typically, these charts can be installed in a pattern like this:

```shell
helm repo add roadie https://charts.roadie.io
helm install kubewise roadie/kubewise
```

## Releasing new chart versions

Merging to master will automatically run a GitHub action which packages and releases
new charts.

 1. `git pull --rebase` on the master branch to pick up any commits made by GitHub actions.
 2. Bump the chart version in `Chart.yaml`.
 5. Review the changes, commit and push to GitHub.
 6. The packaged charts will be indexed automatically and new Chart versions will become available.

## Using new chart versions

```shell
helm repo update roadie
helm upgrade kubewise roadie/kubewise -f values-overrides.yaml
```

# Testing Charts

Generate test charts using `helm template` i.e. for roadie/roadie-kubernetes-cluster-access you could test a Broker configuration like so `helm template . --set broker.enabled=true,broker.token=test1` etc


