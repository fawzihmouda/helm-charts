{{/*
This template serves as the blueprint for the DaemonSet objects that are created
within the common library.
*/}}
{{- define "stack.class.daemonset" -}}
  {{- $rootContext := .rootContext -}}
  {{- $daemonsetObject := .object -}}

  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($daemonsetObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($daemonsetObject.annotations | default dict)
  -}}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: {{ $daemonsetObject.name }}
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
  revisionHistoryLimit: {{ include "stack.lib.defaultKeepNonNullValue" (dict "value" $daemonsetObject.revisionHistoryLimit "default" 3) }}
  {{- if $daemonsetObject.strategy }}
  updateStrategy:
    type: {{ $daemonsetObject.strategy }}
    {{- with $daemonsetObject.rollingUpdate }}
      {{- $hasUnavailable := or (hasKey . "maxUnavailable") (hasKey . "unavailable") }}
      {{- $hasSurge := or (hasKey . "maxSurge") (hasKey . "surge") }}
      {{- if and (eq $daemonsetObject.strategy "RollingUpdate") (or $hasUnavailable $hasSurge) }}
    rollingUpdate:
        {{- if $hasUnavailable }}
          {{- if hasKey . "maxUnavailable" }}
      maxUnavailable: {{ .maxUnavailable }}
          {{- else }}
      maxUnavailable: {{ .unavailable }}
          {{- end }}
        {{- end }}
        {{- if $hasSurge }}
          {{- if hasKey . "maxSurge" }}
      maxSurge: {{ .maxSurge }}
          {{- else }}
      maxSurge: {{ .surge }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "stack.lib.controller.metadata.selectorLabels" (dict "rootContext" $rootContext "controllerObject" $daemonsetObject) | nindent 6 }}
  template:
    metadata:
      annotations: {{ include "stack.lib.pod.metadata.annotations" (dict "rootContext" $rootContext "controllerObject" $daemonsetObject) | nindent 8 }}
      labels: {{ include "stack.lib.pod.metadata.labels" (dict "rootContext" $rootContext "controllerObject" $daemonsetObject) | nindent 8 }}
    spec: {{ include "stack.lib.pod.spec" (dict "rootContext" $rootContext "controllerObject" $daemonsetObject) | nindent 6 }}
{{- end }}
