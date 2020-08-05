# Getting started

## Accessing PostgreSQL

Both the Backstage backend and Lighthouse Audit Service require access to a PostgreSQL
database. These helm charts require that communication with the database happen over SSL.

The location of the PG database can be specified by overriding the `app-config.yaml` which comes
with Backstage with some environment variables.

To do this, set the following Helm values:

```yaml
appConfig:
  backend:
    postgresUser:
    postgresPort:
    postgresDatabase:
    postgresHost: 
    postgresPathToCa:
    postgresPassword:

pg:
  caVolumeMountDir:
```

`appConfig.backend.postgresPathToCa` and `pg.caVolumeMountDir` are properties which are not
required to run Backstage locally and connect it to your local Posgtres instance.

`postgresPathToCa` is used to tell the NodeJS `pg` library where to find the certificate authority (CA)
cert that it can use to validate SSL connections. `pg.caVolumeMountDir` tells Kubernetes where
on each pod to mount the CA cert.

The CA cert must be loaded into a configmap manually so that Kubernetes can find it and mount
it to the pods which require it.

```shell
kubectl create configmap ca-pemstore --from-file=/path/to/ca-certificate.crt
```

### Example for DigitalOcean

First create a managed PostgreSQL database on DigitalOcean, using their console. Note the
connection properties it provides for you.

Download the CA file from DigitalOcean.

Create a `values.yaml` file which we will use to override some default Helm values.

```yaml
appConfig:
  backend: 
    postgresUser: doadmin
    postgresPort: 25061
    postgresDatabase: defaultdb
    postgresHost: private-db-postgresql-lon1-18737-do-user-9374938-0.a.db.ondigitalocean.com
    postgresPathToCa: /etc/config/ca-certificate.crt
    postgresPassword: "<your password>"

pg:
  # This must match the path provided to appConfig.backend.postgresPathToCa. For example, if
  # postgresPathToCa is /etc/config/my-ca.crt then pg.caVolumeMountDir must be /etc/config.
  caVolumeMountDir: /etc/config

```

Now store the `crt` file that you downloaded from DigitalOcean in a configmap so Kubernetes can
moount it onto each pod.

```shell
kubectl create configmap ca-pemstore --from-file=/path/to/ca-certificate.crt
```

## Getting docker images
Docker images are public on docker hub. No credentials are needed to pull them.

## Install dependencies

All HTTP ingress to the cluster must happen over SSL. In order to get SSL certificates for
ingress, we must install [cert-manager](https://cert-manager.io/) into the cluster.

```shell
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.12.0/cert-manager.yaml
```

Nginx is required to act as the ingress. (Note: It is likely possible to skip this part and
use native Kubernetes ingress but I haven't tested that path).

```shell
helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true
```

## Install the app

```shell
helm install backstage ./
```

You will likely need to provide some custom Helm values like this:

```shell
hem install backstage ./ -f custom-values.yaml
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
 5. Add the new component's URL (e.g. gitops.backstage-demo.roadie.io) as an A record in your DNS provider,
    pointing to the external ingress IP of the cluster.
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
```

One challenge is marked as `pending` and stayed in this state for a long time. I found I could
 `curl` the `.well-known` endpoint from my laptop but not from within a pod.

I eventually fixed this by reinstalling `nginx-ingress` with Helm. I was pointed to this idea
by [this page](https://cert-manager.io/docs/faq/acme/) and [this GitHub issue.](https://github.com/jetstack/cert-manager/issues/656#issuecomment-415606297).

```shell
helm uninstall nginx-ingress
helm install nginx-ingress stable/nginx-ingress --set controller.publishService.enabled=true
```

**WARNING:** Reinstalling `nginx-ingress` will change the external IP of the cluster and require
updating your DNS provider with the new A records.
