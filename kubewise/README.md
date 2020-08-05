The KubeWise Helm chart is available in the KubeWise repo.

https://github.com/RoadieHQ/kubewise

There are a number of packaged KubeWise charts in the root directory of this repository,
rather than within this directory, as might be expected. This is because the repo was migrated
over from a previous helm chart repo which didn't have a subdirectory structure. It is likely
fine to move them as long as the `index.yaml` is updated. With that said, it would be a good
idea to consolidate the method of publishing Helm charts, move the KubeWise helm chart
into this directory, and publish a new KubeWise version, before making changes to the `index.yaml`.
