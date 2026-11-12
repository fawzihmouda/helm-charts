{{- define "stack.class.serviceMonitor" -}}
  {{- $rootContext := .rootContext -}}
  {{- $serviceMonitorObject := .object -}}
  {{- $ctx := dict "rootContext" $rootContext "serviceMonitorObject" $serviceMonitorObject -}}
  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($serviceMonitorObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($serviceMonitorObject.annotations | default dict)
  -}}
  {{ $serviceName := "" -}}
  {{ if $serviceMonitorObject.serviceName -}}
    {{ $serviceName = include "stack.lib.common.renderString" (dict "value" $serviceMonitorObject.serviceName "rootContext" $rootContext) -}}
  {{ else if not (empty (dig "service" "name" nil $serviceMonitorObject)) -}}
    {{ $serviceName = include "stack.lib.common.renderString" (dict "value" $serviceMonitorObject.service.name "rootContext" $rootContext) -}}
  {{ else if not $serviceMonitorObject.selector -}}
    {{ $serviceName = (include "stack.lib.service.get" (dict "rootContext" $rootContext) | fromYaml).name -}}
  {{ end -}}
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: {{ $serviceMonitorObject.name }}
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
  jobLabel: {{ include "stack.lib.serviceMonitor.field.jobLabel" (dict "ctx" $ctx) | trim }}
  namespaceSelector:
    matchNames:
      - {{ $rootContext.Release.Namespace }}
  selector:
    {{- if $serviceMonitorObject.selector -}}
      {{- include "stack.lib.common.renderString" (dict "value" ($serviceMonitorObject.selector | toYaml) "rootContext" $rootContext) | nindent 4}}
    {{- else }}
    matchLabels:
      app.kubernetes.io/service: {{ $serviceName }}
      {{- include "stack.lib.metadata.selectorLabels" $rootContext | nindent 6 }}
    {{- end }}
  endpoints: {{- include "stack.lib.common.renderString" (dict "value" (toYaml $serviceMonitorObject.endpoints) "rootContext" $rootContext) | nindent 4 }}
  {{- if not (empty $serviceMonitorObject.targetLabels )}}
  targetLabels:
    {{- toYaml $serviceMonitorObject.targetLabels | nindent 4 }}
  {{- end }}
{{- end }}
