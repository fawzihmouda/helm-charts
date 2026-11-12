{{/*
Renders the Namespace object required by the chart.
*/}}
{{- define "stack.render.namespace" -}}
  {{- $rootContext := $ -}}

  {{- if $rootContext.Values.namespace.create -}}
    {{- include "stack.class.namespace" (dict "rootContext" $rootContext "object" $rootContext.Values.namespace) | nindent 0 -}}
  {{- end -}}
{{- end -}}
