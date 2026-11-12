{{- define "stack.lib.metadata.globalLabels" -}}
  {{- with .Values.global.labels }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := include "stack.lib.common.renderString" (dict "value" $v "rootContext" $) }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end -}}
