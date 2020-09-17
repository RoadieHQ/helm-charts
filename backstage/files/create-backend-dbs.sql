create database {{ .Values.appConfig.backend.database.connection.database }};
grant all privileges on database {{ .Values.appConfig.backend.database.connection.database }} to {{ .Values.global.postgresql.postgresqlUsername }};

{{ if not (eq .Values.appConfig.backend.database.connection.database .Values.lighthouse.database.connection.database) }}
create database {{ .Values.lighthouse.database.connection.database }};
grant all privileges on database {{ .Values.lighthouse.database.connection.database }} to {{ .Values.global.postgresql.postgresqlUsername }};
{{ end }}