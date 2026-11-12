{{/*
Renders the release's Service.
*/}}
{{- define "stack.render.services" -}}
  {{- $rootContext := $ -}}
  {{- $serviceObject := include "stack.lib.service.get" (dict "rootContext" $rootContext) | fromYaml -}}
  {{- if $serviceObject -}}
    {{- include "stack.lib.service.validate" (dict "rootContext" $rootContext "object" $serviceObject) -}}
    {{- include "stack.class.service" (dict "rootContext" $rootContext "object" $serviceObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
