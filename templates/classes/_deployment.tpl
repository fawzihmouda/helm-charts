{{/*
This template serves as a blueprint for Deployment objects that are created
using the common library.
*/}}
{{- define "stack.class.deployment" -}}
  {{- $rootContext := .rootContext -}}
  {{- $deploymentObject := .object -}}

  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($deploymentObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($deploymentObject.annotations | default dict)
  -}}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $deploymentObject.name }}
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
  revisionHistoryLimit: {{ include "stack.lib.defaultKeepNonNullValue" (dict "value" $deploymentObject.revisionHistoryLimit "default" 3) }}
  {{- if hasKey $deploymentObject "replicas" }}
    {{- if not (eq $deploymentObject.replicas nil) }}
  replicas: {{ $deploymentObject.replicas }}
    {{- end }}
  {{- else }}
  replicas: 1
  {{- end }}
  strategy:
    type: {{ $deploymentObject.strategy }}
    {{- with $deploymentObject.rollingUpdate }}
      {{- $hasUnavailable := or (hasKey . "maxUnavailable") (hasKey . "unavailable") }}
      {{- $hasSurge := or (hasKey . "maxSurge") (hasKey . "surge") }}
      {{- if and (eq $deploymentObject.strategy "RollingUpdate") (or $hasUnavailable $hasSurge) }}
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
  selector:
    matchLabels:
      {{- include "stack.lib.controller.metadata.selectorLabels" (dict "rootContext" $rootContext "controllerObject" $deploymentObject) | nindent 6 }}
  template:
    metadata:
      {{- with (include "stack.lib.pod.metadata.annotations" (dict "rootContext" $rootContext "controllerObject" $deploymentObject)) }}
      annotations: {{ . | nindent 8 }}
      {{- end -}}
      {{- with (include "stack.lib.pod.metadata.labels" (dict "rootContext" $rootContext "controllerObject" $deploymentObject)) }}
      labels: {{ . | nindent 8 }}
      {{- end }}
    spec: {{ include "stack.lib.pod.spec" (dict "rootContext" $rootContext "controllerObject" $deploymentObject) | nindent 6 }}
{{- end -}}
