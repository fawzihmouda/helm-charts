{{/*
This template serves as the blueprint for the StatefulSet objects that are created
within the common library.
*/}}
{{- define "stack.class.statefulset" -}}
  {{- $rootContext := .rootContext -}}
  {{- $statefulsetObject := .object -}}

  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($statefulsetObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($statefulsetObject.annotations | default dict)
  -}}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ $statefulsetObject.name }}
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
  revisionHistoryLimit: {{ include "stack.lib.defaultKeepNonNullValue" (dict "value" $statefulsetObject.revisionHistoryLimit "default" 3) }}
  replicas: {{ $statefulsetObject.replicas }}
  podManagementPolicy: {{ dig "podManagementPolicy" "OrderedReady" $statefulsetObject }}
  updateStrategy:
    type: {{ $statefulsetObject.strategy }}
    {{- with $statefulsetObject.rollingUpdate }}
      {{- if and (eq $statefulsetObject.strategy "RollingUpdate") (or (hasKey . "partition") (hasKey . "maxUnavailable")) }}
    rollingUpdate:
        {{- if hasKey . "partition" }}
      partition: {{ .partition }}
        {{- end }}
        {{- if hasKey . "maxUnavailable" }}
      maxUnavailable: {{ .maxUnavailable }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- with (dig "startOrdinal" nil $statefulsetObject) }}
  ordinals:
    start: {{ . }}
  {{- end }}
  selector:
    matchLabels:
      {{- include "stack.lib.controller.metadata.selectorLabels" (dict "rootContext" $rootContext "controllerObject" $statefulsetObject) | nindent 6 }}
  {{- $serviceName := include "stack.lib.chart.names.fullname" $rootContext }}
  {{- with $statefulsetObject.serviceName }}
    {{- $serviceName = include "stack.lib.common.renderString" (dict "value" . "rootContext" $rootContext) }}
  {{- end }}
  serviceName: {{ $serviceName }}
  {{- with $statefulsetObject.persistentVolumeClaimRetentionPolicy }}
  persistentVolumeClaimRetentionPolicy:  {{ . | toYaml | nindent 4 }}
  {{- end }}
  template:
    metadata:
      {{- with (include "stack.lib.pod.metadata.annotations" (dict "rootContext" $rootContext "controllerObject" $statefulsetObject)) }}
      annotations: {{ . | nindent 8 }}
      {{- end -}}
      {{- with (include "stack.lib.pod.metadata.labels" (dict "rootContext" $rootContext "controllerObject" $statefulsetObject)) }}
      labels: {{ . | nindent 8 }}
      {{- end }}
    spec: {{ include "stack.lib.pod.spec" (dict "rootContext" $rootContext "controllerObject" $statefulsetObject) | nindent 6 }}
  {{- with (include "stack.lib.statefulset.volumeclaimtemplates" (dict "rootContext" $rootContext "statefulsetObject" $statefulsetObject)) }}
  volumeClaimTemplates: {{ . | nindent 4 }}
  {{- end }}
{{- end }}
