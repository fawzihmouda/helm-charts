{{/* Common labels shared across objects */}}
{{- define "stack.lib.metadata.allLabels" -}}
helm.sh/chart: {{ include "stack.lib.chart.names.chart" . }}
{{ include "stack.lib.metadata.selectorLabels" . }}
  {{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{ include "stack.lib.metadata.globalLabels" . }}
{{- end -}}
