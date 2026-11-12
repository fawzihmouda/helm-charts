{{/*
This template serves as a blueprint for Cronjob objects that are created
using the common library.
*/}}
{{- define "stack.class.cronjob" -}}
  {{- $rootContext := .rootContext -}}
  {{- $cronjobObject := .object -}}

  {{- $timeZone := dig "timeZone" "" $cronjobObject -}}

  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($cronjobObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($cronjobObject.annotations | default dict)
  -}}

  {{- $cronJobSettings := $cronjobObject -}}
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: {{ $cronjobObject.name }}
  {{- with $labels }}
  labels:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (include "stack.lib.common.renderString" (dict "value" $value "rootContext" $rootContext) | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $annotations }}
  annotations:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (include "stack.lib.common.renderString" (dict "value" $value "rootContext" $rootContext) | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  namespace: {{ $rootContext.Release.Namespace }}
spec:
  suspend: {{ default false $cronJobSettings.suspend }}
  concurrencyPolicy: {{ default "Forbid" $cronJobSettings.concurrencyPolicy }}
  startingDeadlineSeconds: {{ include "stack.lib.defaultKeepNonNullValue" (dict "value" $cronJobSettings.startingDeadlineSeconds "default" 30) }}
  {{- with $timeZone }}
  timeZone: {{ . }}
  {{- end }}
  schedule: {{ $cronJobSettings.schedule | quote }}
  successfulJobsHistoryLimit: {{ include "stack.lib.defaultKeepNonNullValue" (dict "value" $cronJobSettings.successfulJobsHistory "default" 1) }}
  failedJobsHistoryLimit: {{ include "stack.lib.defaultKeepNonNullValue" (dict "value" $cronJobSettings.failedJobsHistory "default" 1) }}
  jobTemplate:
    spec:
      {{- with $cronJobSettings.activeDeadlineSeconds }}
      activeDeadlineSeconds: {{ . }}
      {{- end }}
      {{- with $cronJobSettings.ttlSecondsAfterFinished }}
      ttlSecondsAfterFinished: {{ . }}
      {{- end }}
      {{- with $cronJobSettings.parallelism }}
      parallelism: {{ . }}
      {{- end }}
      backoffLimit: {{ include "stack.lib.defaultKeepNonNullValue" (dict "value" $cronJobSettings.backoffLimit "default" 6) }}
      template:
        metadata:
          {{- with (include "stack.lib.pod.metadata.annotations" (dict "rootContext" $rootContext "controllerObject" $cronjobObject)) }}
          annotations: {{ . | nindent 12 }}
          {{- end -}}
          {{- with (include "stack.lib.pod.metadata.labels" (dict "rootContext" $rootContext "controllerObject" $cronjobObject)) }}
          labels: {{ . | nindent 12 }}
          {{- end }}
        spec: {{ include "stack.lib.pod.spec" (dict "rootContext" $rootContext "controllerObject" $cronjobObject) | nindent 10 }}
{{- end -}}
