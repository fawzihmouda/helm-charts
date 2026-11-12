{{/*
Give a Route without rules one rule that sends traffic to the chart's Service.
*/}}
{{- define "stack.lib.route.autoDetectService" -}}
  {{- $rootContext := .rootContext -}}
  {{- $routeObject := .object -}}

  {{- if and (empty $routeObject.rules) (include "stack.lib.service.get" (dict "rootContext" $rootContext)) -}}
    {{- $_ := set $routeObject "rules" (list (dict "backendRefs" (list dict))) -}}
  {{- end -}}

  {{- $routeObject | toYaml -}}
{{- end -}}
