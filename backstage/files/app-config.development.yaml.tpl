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
  locations:
{{- toYaml .Values.backend.locations | nindent 4 }}
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
      helpUrl: https://roadie.io/docs/integrations/github-token/
    - name: GITHUB_CLIENT_ID
      internalName: AUTH_GITHUB_CLIENT_ID
      description: Client id for the Github oauth app
      helpUrl: https://roadie.io/docs/integrations/github-client/
    - name: GITHUB_CLIENT_SECRET
      internalName: AUTH_GITHUB_CLIENT_SECRET
      description: Client secret for the Github oauth app
    - name: CIRCLECI_AUTH_TOKEN
      internalName: CIRCLECI_AUTH_TOKEN
      description: Token for the integration with CircleCI
      helpUrl: https://roadie.io/docs/integrations/circleci/
    - name: SENTRY_TOKEN
      internalName: SENTRY_TOKEN
      description: Token for Sentry integration
      helpUrl: https://roadie.io/docs/integrations/sentry/
    - name: ROLLBAR_ACCOUNT_TOKEN
      internalName: ROLLBAR_ACCOUNT_TOKEN
      description: Token for Rollbar
      helpUrl: https://roadie.io/backstage/plugins/rollbar/
    - name: GCP_CLIENT_EMAIL
      internalName: GCP_CLIENT_EMAIL
      description: Google Cloud Platform Client Email
      helpUrl: https://roadie.io/docs/integrations/gcp/
    - name: GCP_PRIVATE_KEY
      internalName: GCP_PRIVATE_KEY
      description: Google Cloud Platform Private Key
    - name: JIRA_API_TOKEN
      internalName: JIRA_API_TOKEN
      description: Jira API Token
      helpUrl: https://roadie.io/docs/integrations/jira/
    - name: JIRA_API_URL
      internalName: JIRA_API_URL
      description: Jira API URL
      helpUrl: https://roadie.io/docs/integrations/jira/
    - name: PAGERDUTY_TOKEN
      internalName: PAGERDUTY_TOKEN
      description: Token for authenticating against the PagerDuty API
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
{{- if .Values.lighthouse.enabled }}
  '/lighthouse':
    target: http://{{ include "lighthouse.serviceName" .  }}
{{- end }}
{{- if .Values.appConfig.proxy }}
  {{- toYaml .Values.appConfig.proxy | nindent 4 }}
{{- end }}

  {{- if .Values.appConfig.jiraProxy.enabled }}
  '/jira/api':
    target:
      $env:
        JIRA_API_URL
    headers:
      Authorization:
        $env:
          JIRA_API_TOKEN
      Accept: 'application/json'
      Content-Type: 'application/json'
      X-Atlassian-Token: 'no-check'
      User-Agent: "Roadie-Backstage"
  {{- end }}
  {{- if .Values.appConfig.pagerduty.enabled }}
  '/pagerduty':
    target: https://api.pagerduty.com
    headers:
      Authorization:
        $env: PAGERDUTY_TOKEN
  {{- end }}

single-sign-on:
  name: vouch
  config:
    cookieName: VouchCookie
    {{- if .Values.singleSignOn.vouch.customUserIdFieldName }}
    customUserIdFieldName: {{ .Values.singleSignOn.vouch.customUserIdFieldName }}
    {{- end }}

