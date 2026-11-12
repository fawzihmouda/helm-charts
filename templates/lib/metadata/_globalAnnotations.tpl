{{/* Common annotations shared across objects */}}
{{- define "stack.lib.metadata.globalAnnotations" -}}
  {{- with .Values.global.annotations }}
    {{- range $k, $v := . }}
      {{- $name := $k }}
      {{- $value := include "stack.lib.common.renderString" (dict "value" $v "rootContext" $) }}
{{ $name }}: {{ quote $value }}
    {{- end }}
  {{- end }}
{{- end -}}
