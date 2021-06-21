
This repository contains all of RoadieHQ's public Helm charts.

> **NOTE: the backstage chart is deprecated. Please use the chart in [the official repo][repo] instead.**

[repo]: https://github.com/backstage/backstage/tree/master/contrib/chart/backstage

## Using the charts

Typically, these charts can be installed in a pattern like this:

```shell
helm repo add roadie https://charts.roadie.io
helm install kubewise roadie/sample-service
```

## Releasing new chart versions

Merging to master will automatically run a GitHub action which packages and releases
new charts.

 1. `git pull --rebase` on the master branch to pick up any commits made by GitHub actions.
 2. Bump the chart version in `Chart.yaml`.
 2. Package the chart with `helm package .`. Be sure to run `helm package` within the chart directory, not in the root diractory.
 3. **Do not** run `helm repo index`,
 5. Review the changes, commit and push to GitHub.
 6. The repo will be indexed automatically upon merge.

## Using new chart versions

Wait for the GitHub action which indexes and publishes the chars to run, then:

```shell
helm repo update
helm upgrade kubewise roadie/sample-service -f values-overrides.yaml
```
