{{/*
Expand the name of the chart.
*/}}
{{- define "dify.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "dify.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "dify.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "dify.labels" -}}
helm.sh/chart: {{ include "dify.chart" . }}
{{ include "dify.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "dify.selectorLabels" -}}
app.kubernetes.io/name: {{ include "dify.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Global labels
*/}}
{{- define "dify.global.labels" -}}
{{- if .Values.global.labels }}
{{- toYaml .Values.global.labels }}
{{- end -}}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "dify.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "dify.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "dify.baseUrl" -}}
{{ if .Values.global.enableTLS }}https://{{ else }}http://{{ end }}{{.Values.global.host}}{{ if .Values.global.port }}:{{.Values.global.port}}{{ end }}
{{- end }}

{{/*
dify environments
commonEnvs are for all containers
commonBackendEnvs are for api and worker containers
*/}}
{{- define "dify.commonEnvs" -}}
- name: EDITION
  value: {{ .Values.global.edition }}
{{- range tuple "CONSOLE_API_URL" "CONSOLE_WEB_URL" "SERVICE_API_URL" "APP_API_URL" "APP_WEB_URL" }}
- name: {{ . }}
  value: {{ include "dify.baseUrl" $ }}
{{- end }}
{{- end }}


{{- define "dify.commonBackendEnvs" -}}
- name: STORAGE_TYPE
  value: {{ .Values.global.storageType }}
{{- if .Values.redis.embedded }}
- name: CELERY_BROKER_URL
  value: redis://:{{ .Values.redis.auth.password }}@{{ include "dify.fullname" . }}-redis-master:6379/1
- name: REDIS_PORT
  value: "6379"
- name: REDIS_HOST
  value: {{ include "dify.fullname" . }}-redis-master
- name: REDIS_DB
  value: "1"
- name: REDIS_PASSWORD
  value: {{ .Values.redis.auth.password }}
{{- end }}
{{- if .Values.postgresql.embedded }}
- name: DB_USERNAME
  value: postgres
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "dify.fullname" . }}-postgresql
      key: postgres-password
- name: DB_HOST
  value: {{ include "dify.fullname" . }}-postgresql
- name: DB_PORT
  value: "5432"
- name: DB_DATABASE
  value: {{ .Values.postgresql.auth.database }}
{{- end }}

{{- if .Values.minio.embedded }}
- name: S3_ENDPOINT
  value: http://{{ include "dify.fullname" . }}-minio:{{ .Values.minio.service.port }}
- name: S3_BUCKET_NAME
  value: "difyai"
- name: S3_ACCESS_KEY
  value: {{ .Values.minio.auth.rootUser }}
- name: S3_SECRET_KEY
  value: {{ .Values.minio.auth.rootPassword }}
{{- end }}

{{- if .Values.plugin_daemon.enabled }}
- name: PLUGIN_DAEMON_URL
  value: "http://{{ include "dify.fullname" . }}-plugin-daemon:{{ .Values.plugin_daemon.service.port }}"
- name: MARKETPLACE_API_URL
  value: 'https://marketplace.dify.ai'
- name: PLUGIN_DAEMON_KEY
{{- if .Values.plugin_daemon.serverKeySecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.plugin_daemon.serverKeySecret }}
      key: plugin-daemon-key
{{- else if .Values.plugin_daemon.serverKey }}
  value: {{ .Values.plugin_daemon.serverKey | quote }}
{{- else }}
{{- end }}
- name: PLUGIN_DIFY_INNER_API_KEY
{{- if .Values.plugin_daemon.difyInnerApiKeySecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.plugin_daemon.difyInnerApiKeySecret }}
      key: plugin-dify-inner-api-key
{{- else if .Values.plugin_daemon.difyInnerApiKey }}
  value: {{ .Values.plugin_daemon.difyInnerApiKey | quote }}
{{- else }}
{{- end }}

{{- end }}

{{- if .Values.sandbox.enabled }}
- name: CODE_EXECUTION_ENDPOINT
  value: "http://{{ include "dify.fullname" . }}-sandbox:{{ .Values.sandbox.service.port }}"
- name: CODE_EXECUTION_API_KEY
{{- if .Values.sandbox.apiKeySecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.sandbox.apiKeySecret }}
      key: sandbox-api-key
{{- else if .Values.sandbox.apiKey }}
  value: {{ .Values.sandbox.apiKey | quote }}
{{- else }}
  value: "dify-sandbox"
{{- end }}
{{- end }}

{{- if .Values.weaviate.enabled }}
- name: VECTOR_STORE
  value: "weaviate"
- name: WEAVIATE_ENDPOINT
  value: "http://{{ include "dify.fullname" . }}-weaviate:8080"
- name: WEAVIATE_API_KEY
  value: "WVF5YThaHlkYwhGUSmCRgsX3tD5ngdN8pkih"
{{- end }}
{{- end }}

{{- define "dify.pluginDaemonEnvs" -}}
- name: STORAGE_TYPE
  value: {{ .Values.global.storageType }}
{{- if .Values.redis.embedded }}
- name: CELERY_BROKER_URL
  value: redis://:{{ .Values.redis.auth.password }}@{{ include "dify.fullname" . }}-redis-master:6379/1
- name: REDIS_PORT
  value: "6379"
- name: REDIS_HOST
  value: {{ include "dify.fullname" . }}-redis-master
- name: REDIS_DB
  value: "1"
- name: REDIS_PASSWORD
  value: {{ .Values.redis.auth.password }}
{{- end }}
{{- if .Values.postgresql.embedded }}
- name: DB_USERNAME
  value: postgres
- name: DB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ include "dify.fullname" . }}-postgresql
      key: postgres-password
- name: DB_HOST
  value: {{ include "dify.fullname" . }}-postgresql
- name: DB_PORT
  value: "5432"
- name: DB_DATABASE
  value: "dify_plugin"
{{- end }}

{{- if .Values.minio.embedded }}
- name: S3_ENDPOINT
  value: http://{{ include "dify.fullname" . }}-minio:{{ .Values.minio.service.port }}
- name: S3_BUCKET_NAME
  value: "difyai"
- name: S3_ACCESS_KEY
  value: {{ .Values.minio.auth.rootUser }}
- name: S3_SECRET_KEY
  value: {{ .Values.minio.auth.rootPassword }}
{{- end }}

{{- if .Values.plugin_daemon.enabled }}
- name: PLUGIN_DAEMON_URL
  value: "http://{{ include "dify.fullname" . }}-plugin-daemon:{{ .Values.plugin_daemon.service.port }}"
- name: MARKETPLACE_API_URL
  value: 'https://marketplace.dify.ai'
- name: PLUGIN_DAEMON_KEY
{{- if .Values.plugin_daemon.serverKeySecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.plugin_daemon.serverKeySecret }}
      key: plugin-daemon-key
{{- else if .Values.plugin_daemon.serverKey }}
  value: {{ .Values.plugin_daemon.serverKey | quote }}
{{- else }}
{{- end }}
- name: PLUGIN_DIFY_INNER_API_KEY
{{- if .Values.plugin_daemon.difyInnerApiKeySecret }}
  valueFrom:
    secretKeyRef:
      name: {{ .Values.plugin_daemon.difyInnerApiKeySecret }}
      key: plugin-dify-inner-api-key
{{- else if .Values.plugin_daemon.difyInnerApiKey }}
  value: {{ .Values.plugin_daemon.difyInnerApiKey | quote }}
{{- else }}
{{- end }}

{{- end }}
{{- end }}