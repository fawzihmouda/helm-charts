{{- define "stack.loader.init" -}}
  {{- /* Merge the local chart values and the common chart defaults */ -}}
  {{- include "stack.values.init" . }}
{{- end -}}
