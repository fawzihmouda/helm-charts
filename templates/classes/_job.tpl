{{/*
This template serves as the blueprint for the job objects that are created
within the common library.
*/}}
{{- define "stack.class.job" -}}
  {{- $rootContext := .rootContext -}}
  {{- $jobObject := .object -}}

  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($jobObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($jobObject.annotations | default dict)
  -}}

  {{- $jobSettings := $jobObject -}}
---
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ $jobObject.name }}
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
  suspend: {{ default false $jobSettings.suspend }}
  {{- with $jobSettings.activeDeadlineSeconds }}
  activeDeadlineSeconds: {{ . }}
  {{- end }}
  {{- with $jobSettings.ttlSecondsAfterFinished }}
  ttlSecondsAfterFinished: {{ . }}
  {{- end }}
  {{- with $jobSettings.parallelism }}
  parallelism: {{ . }}
  {{- end }}
  {{- with $jobSettings.completions }}
  completions: {{ . }}
  {{- end }}
  {{- with $jobSettings.completionMode }}
  completionMode: {{ . }}
  {{- end }}
  backoffLimit: {{ include "stack.lib.defaultKeepNonNullValue" (dict "value" $jobSettings.backoffLimit "default" 6) }}
  template:
    metadata:
      {{- with (include "stack.lib.pod.metadata.annotations" (dict "rootContext" $rootContext "controllerObject" $jobObject)) }}
      annotations: {{ . | nindent 8 }}
      {{- end -}}
      {{- with (include "stack.lib.pod.metadata.labels" (dict "rootContext" $rootContext "controllerObject" $jobObject)) }}
      labels: {{ . | nindent 8 }}
      {{- end }}
    spec: {{ include "stack.lib.pod.spec" (dict "rootContext" $rootContext "controllerObject" $jobObject) | nindent 6 }}
{{- end -}}
