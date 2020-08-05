This repository contains all of RoadieHQ's public Helm charts.

For example, you can use the chart in the `backstage` directory to install a fully working
Backstage instance into Kubernetes.

Typically, these charts can be installed in a pattern like this:

```shell
helm repo add roadie https://charts.roadie.io
helm install backstage roadie/backstage
```

They may require pre-requisites such as PostgreSQL databases to be set up before running
Helm (backstage does!).
