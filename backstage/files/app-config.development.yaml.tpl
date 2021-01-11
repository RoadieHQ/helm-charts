backend:
  lighthouseHostname: {{ include "lighthouse.serviceName" . | quote }}
  listen:
      port: {{ .Values.appConfig.backend.listen.port | default 7000 }}
  csp:
    script-src:
      - "'self'"
      - "'unsafe-inline'"
  database:
    client: {{ .Values.appConfig.backend.database.client | quote }}
    connection:
      host: {{ include "backend.postgresql.host" . | quote }}
      port: {{ include "backend.postgresql.port" . | quote }}
      user: {{ include "backend.postgresql.user" . | quote }}
      database: {{ .Values.appConfig.backend.database.connection.database | quote }}
      ssl:
        rejectUnauthorized: {{ .Values.appConfig.backend.database.connection.ssl.rejectUnauthorized | quote }}
        ca: {{ include "backstage.backend.postgresCaFilename" . | quote }}

catalog:
{{- if .Values.backend.demoData }}
  locations:
    # Backstage example components
    - type: github
      target: https://github.com/spotify/backstage/blob/master/packages/catalog-model/examples/all-components.yaml
    # Example component for github-actions
    - type: github
      target: https://github.com/spotify/backstage/blob/master/plugins/github-actions/examples/sample.yaml
    # Example component for techdocs
    - type: github
      target: https://github.com/spotify/backstage/blob/master/plugins/techdocs-backend/examples/documented-component/documented-component.yaml
    # Backstage example APIs
    - type: github
      target: https://github.com/spotify/backstage/blob/master/packages/catalog-model/examples/all-apis.yaml
    # Backstage example templates
    - type: github
      target: https://github.com/spotify/backstage/blob/master/plugins/scaffolder-backend/sample-templates/all-templates.yaml
{{- else }}
  locations: []
{{- end }}

{{- if .Values.externalSecrets.enabled }}
secretsSettings:
  ssm:
    path: {{ required "path to SSM secrets .Values.externalSecrets.path is required" .Values.externalSecrets.path }}
    keyId: {{ required "id or alias of the KMS key is required in .Values.externalSecrets.keyId" .Values.externalSecrets.keyId }}
    region: {{ required ".Values.eternalSecrets.defaultRegion is required for accessing SSM parameters" .Values.externalSecrets.defaultRegion }}
  secrets:
    - name: GITHUB_TOKEN
      internalName: GITHUB_TOKEN
      description: Github PAT used for reading entity yaml files
    - name: GITHUB_CLIENT_ID
      internalName: AUTH_GITHUB_CLIENT_ID
      description: Github Client ID
    - name: GITHUB_CLIENT_SECRET
      internalName: AUTH_GITHUB_CLIENT_SECRET
    - name: GOOGLE_CLIENT_ID
      internalName: AUTH_GOOGLE_CLIENT_ID
      description: 'Google Client ID'
    - name: GOOGLE_CLIENT_SECRET
      internalName: AUTH_GOOGLE_CLIENT_SECRET
      description: Google Client Secret
{{- end }}

auth:
  providers:
    microsoft: null

scaffolder:
  azure: null


sentry:
  organization: {{ .Values.appConfig.sentry.organization | quote }}

techdocs:
  generators:
    techdocs: 'local'

{{- if .Values.appConfig.authenticatedProxy }}
authenticatedProxy:
  {{- toYaml .Values.appConfig.authenticatedProxy | nindent 2 }}
{{- end }}

proxy:
  '/lighthouse': http://{{ include "lighthouse.serviceName" . }}
  {{- toYaml .Values.appConfig.proxy | nindent 4 }}

single-sign-on:
  name: vouch
  config:
    cookieName: VouchCookie
