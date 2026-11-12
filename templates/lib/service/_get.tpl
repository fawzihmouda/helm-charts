{{/*
Return the release's Service object, built from the service values.
Returns nothing when no Service is configured or it is disabled.
*/}}
{{- define "stack.lib.service.get" -}}
  {{- $rootContext := .rootContext -}}
  {{- $values := $rootContext.Values.service -}}
  {{- if and (kindIs "map" $values) $values -}}
    {{- $enabled := true -}}
    {{- if hasKey $values "enabled" -}}
      {{- $enabled = $values.enabled -}}
    {{- end -}}
    {{- if $enabled -}}
      {{- include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" "main" "values" (deepCopy $values) "itemCount" 1) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
