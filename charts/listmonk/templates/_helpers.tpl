{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "listmonk.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "listmonk.fullname" -}}
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
{{- define "listmonk.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "listmonk.labels" -}}
helm.sh/chart: {{ include "listmonk.chart" . }}
{{ include "listmonk.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "listmonk.selectorLabels" -}}
app.kubernetes.io/name: {{ include "listmonk.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "listmonk.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "listmonk.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "call-nested" }}
{{- $dot := index . 0 }}
{{- $subchart := index . 1 }}
{{- $template := index . 2 }}
{{- include $template (dict "Chart" (dict "Name" $subchart) "Values" (index $dot.Values $subchart) "Release" $dot.Release "Capabilities" $dot.Capabilities) }}
{{- end }}

{{- define "listmonk.postgresName" -}}
{{- $name := include "call-nested" (list . "postgresql" "postgresql.fullname") -}}
{{- printf "%s" $name -}}
{{- end -}}

{{- define "listmonk.dbEnv" -}}
- name: LISTMONK_db__host
  value: {{ include "listmonk.postgresName" . }}
- name: LISTMONK_db__user
  value: {{ .Values.postgresql.postgresqlUsername }}
- name: LISTMONK_db__password
  valueFrom:
    secretKeyRef:
      name: {{ include "listmonk.postgresName" . }}
      key: postgresql-password
- name: LISTMONK_db__database
  value: {{ .Values.postgresql.postgresqlDatabase }}
{{- end -}}