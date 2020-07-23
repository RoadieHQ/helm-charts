# Getting started

## Getting docker images
Set up the cluster to work with the Digital Ocean registry.

[Instructions](https://www.digitalocean.com/docs/images/container-registry/quickstart/#use-images-in-your-registry-with-kubernetes)

The name of the container registry in my DO account is: `larder`.

```shell
doctl registry kubernetes-manifest | kubectl apply -f -
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "registry-larder"}]}'
```

## Accessing PostgreSQL

Ensure that there is a posgres database running where the lighthouse app expects it to be.
Ensure that DO connection security allows a connection from the kubernetes cluster.

Make the DB certificate authority available to the pods which need it.

First download the CA file from DigitalOcean (it's available where the database is created).

```shell
k create configmap ca-pemstore --from-file=/Users/davidtuite/Downloads/ca-certificate.crt
```

## Install dependencies

```shell
# Install the certificate manager for suppliying letsencrypt certificates.
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
# Install nginx-ingress
helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true
```

## Install the app

```
helm install backstage ./
```

# Adding new components

A semi-frequent activity is adding new components to the cluster. For example, when Weaveworks
released their GitOps Backstage plugin, I wanted to make it available in the demo for people
to try out.

There are usually a few steps

 1. Add a deployment for the new container in `templates/deployment.yaml`.
 2. Add values for the service in `values.yaml`.
 3. Add a service for the new component in `templates/service.yaml`.
 4. Add ingress rules for the new component in the `values.yaml`.
 5. Add the new component's URL (e.g. gitops.backstage-demo.roadie.io) to DNS in the NS1 interface.
 6. Upgrade everything with helm: `helm upgrade backstage ./`.
 7. Ensure a certificate is generated for the new URL.


# Troubleshooting

## SSL Challenge not succeeding for new hostnane

I just added the GitOps component and I couldn't get a certificate to be generated for it
so it could be accessed.

The smells were

 1. non-ready `backstage-tls` certificate
 2. non-ready `backstage-tls` secret

```shell
» k get certificates
NAME            READY   SECRET          AGE
backstage-tls   False   backstage-tls   8m6s
```

I debugged this by describing the HTTP acme challenges.

```shell
k get challenges -o wide
NAME                                             STATE     DOMAIN                                REASON                                                                                                                                                                                                                                                                                                                                                                                                     AGE
backstage-tls-2934582588-2220160209-1297212253   valid     lighthouse.backstage-demo.roadie.io                                                                                                                                                                                                                                                                                                                                                                                                              13m
backstage-tls-2934582588-2220160209-2098817713   pending   gitops.backstage-demo.roadie.io       Waiting for http-01 challenge propagation: failed to perform self check GET request 'http://gitops.backstage-demo.roadie.io/.well-known/acme-challenge/Yl68GfAzL5f4-CkSJs_Hm0_PcngkkwjzKRXhCMp3SU8': Get http://gitops.backstage-demo.roadie.io/.well-known/acme-challenge/Yl68GfAzL5f4-CkSJs_Hm0_PcngkkwjzKRXhCMp3SU8: dial tcp: lookup gitops.backstage-demo.roadie.io on 10.245.0.10:53: no such host   13m
backstage-tls-2934582588-2220160209-3026955619   valid     backstage-demo.roadie.io                                                                                                                                                                                                                                                                                                                                                                                                                         13m
backstage-tls-2934582588-2220160209-3265927229   valid     backend.backstage-demo.roadie.io
```

The `pending` challenge stayed pending for a long time. I found I could `curl` the `.well-known`
endpoint from my laptop but not from within a pod.

I eventually fixed this by reinstalling `nginx-ingress` with Helm. I was pointed to this idea
by [this page](https://cert-manager.io/docs/faq/acme/) and [this GitHub issue.](https://github.com/jetstack/cert-manager/issues/656#issuecomment-415606297).

```shell
helm uninstall nginx-ingress
helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true
```

**WARNING:** Reinstalling `nginx-ingress` will change the external IP of the cluster and require
updating NS1 with the new A records.
