{{/* Selector labels shared across objects */}}
{{- define "stack.lib.metadata.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stack.lib.chart.names.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}
