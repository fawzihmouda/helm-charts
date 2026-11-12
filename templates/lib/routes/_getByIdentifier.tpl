{{/*
Return a Route object by its Identifier.
*/}}
{{- define "stack.lib.route.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}

  {{- $enabledRoutes := (include "stack.lib.route.enabledRoutes" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledRoutes $identifier) -}}
    {{- get $enabledRoutes $identifier | toYaml -}}
  {{- end -}}
{{- end -}}
