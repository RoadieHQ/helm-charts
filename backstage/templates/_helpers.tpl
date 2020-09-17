{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "backstage.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "backstage.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "backstage.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common App labels
*/}}
{{- define "backstage.app.labels" -}}
app.kubernetes.io/name: {{ include "backstage.name" . }}-app
helm.sh/chart: {{ include "backstage.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Common Backend labels
*/}}
{{- define "backstage.backend.labels" -}}
app.kubernetes.io/name: {{ include "backstage.name" . }}-backend
helm.sh/chart: {{ include "backstage.chart" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Create the name of the service account to use for the app
*/}}
{{- define "backstage.app.serviceAccountName" -}}
{{- if .Values.app.serviceAccount.create -}}
    {{ default "default" .Values.app.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.app.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use for the backend
*/}}
{{- define "backstage.backend.serviceAccountName" -}}
{{- if .Values.backend.serviceAccount.create -}}
    {{ default default .Values.backend.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.backend.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Path to the CA certificate file in the backend
*/}}
{{- define "backstage.backend.postgresCaFilename" -}}
{{ .Values.global.caVolumeMountDir }}/tls.crt
{{- end -}}
{{/*

Path to the CA certificate file in lighthouse
*/}}
{{- define "backstage.lighthouse.postgresCaFilename" -}}
{{ .Values.global.caVolumeMountDir }}/tls.crt
{{- end -}}

{{/*
Generate ca for postgresql
*/}}
{{- define "backstage.postgresql.generateCA" -}}
{{- $ca := .ca | default (genCA .Values.postgresql.fullnameOverride 365) -}}
{{- $_ := set . "ca" $ca -}}
tls.crt: {{ $ca.Cert | b64enc }}
tls.key: {{ $ca.Key | b64enc }}
{{- end -}}

{{/*
Generate certificates for postgresql
*/}}
{{- define "generateCerts" -}}
{{- $altNames := list ( printf "%s.%s" ( .Values.postgresql.fullnameOverride ) .Release.Namespace ) ( printf "%s.%s.svc" ( .Values.postgresql.fullnameOverride ) .Release.Namespace ) -}}
{{- $ca := .ca | default (genCA .Values.postgresql.fullnameOverride 365) -}}
{{- $_ := set . "ca" $ca -}}
{{- $cert := genSignedCert ( .Values.postgresql.fullnameOverride ) nil $altNames 365 $ca -}}
tls.crt: {{ $cert.Cert | b64enc }}
tls.key: {{ $cert.Key | b64enc }}
{{- end -}}

{{/*
Generate a password for the postgres user used for the connections from the backend and lighthouse
*/}}
{{- define "postgresql.generateUserPassword" -}}
{{- $pgPassword := .pgPassword | default ( randAlphaNum 12 ) -}}
{{- $_ := set . "pgPassword" $pgPassword -}}
{{ $pgPassword}}
{{- end -}}

{{/*
Name of the backend service
*/}}
{{- define "backend.serviceName" -}}
{{ include "backstage.fullname" . }}-backend
{{- end -}}

{{/*
Name of the frontend service
*/}}
{{- define "frontend.serviceName" -}}
{{ include "backstage.fullname" . }}-frontend
{{- end -}}

{{/*
Name of the lighthouse backend service
*/}}
{{- define "lighthouse.serviceName" -}}
{{ include "backstage.fullname" . }}-lighthouse
{{- end -}}
