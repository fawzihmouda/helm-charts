{{- define "stack.class.podMonitor" -}}
  {{- $rootContext := .rootContext -}}
  {{- $podMonitorObject := .object -}}
  {{- $ctx := dict "rootContext" $rootContext "podMonitorObject" $podMonitorObject -}}
  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($podMonitorObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($podMonitorObject.annotations | default dict)
  -}}

  {{- $controllerObject := include "stack.lib.controller.get" (dict "rootContext" $rootContext) | fromYaml -}}
---
apiVersion: monitoring.coreos.com/v1
kind: PodMonitor
metadata:
  name: {{ $podMonitorObject.name }}
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
  jobLabel: {{ include "stack.lib.podMonitor.field.jobLabel" (dict "ctx" $ctx) | trim }}
  namespaceSelector:
    matchNames:
      - {{ $rootContext.Release.Namespace }}
  selector:
    {{- if hasKey $podMonitorObject "selector" -}}
      {{- include "stack.lib.common.renderString" (dict "value" ($podMonitorObject.selector | toYaml) "rootContext" $rootContext) | nindent 4}}
    {{- else }}
    matchLabels:
      {{- include "stack.lib.controller.metadata.selectorLabels" (dict "rootContext" $rootContext "controllerObject" $controllerObject) | nindent 6 }}
    {{- end }}
  podMetricsEndpoints: {{- include "stack.lib.common.renderString" (dict "value" (toYaml $podMonitorObject.podMetricsEndpoints) "rootContext" $rootContext) | nindent 4 }}
  {{- if not (empty $podMonitorObject.podTargetLabels) }}
  podTargetLabels:
    {{- toYaml $podMonitorObject.podTargetLabels | nindent 4 }}
  {{- end }}
{{- end }}
