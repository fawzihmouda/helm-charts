{{- /*
Returns topologySpreadConstraints, defaulting selectors to the controller.
*/ -}}
{{- define "stack.lib.pod.field.topologySpreadConstraints" -}}
  {{- $ctx := .ctx -}}
  {{- $rootContext := $ctx.rootContext -}}
  {{- $controllerObject := $ctx.controllerObject -}}

  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "topologySpreadConstraints")) -}}
    {{- $constraints := include "stack.lib.common.renderString" (dict "value" . "rootContext" $rootContext) | fromYamlArray -}}
    {{- range $constraint := $constraints -}}
      {{- if not (hasKey $constraint "labelSelector") -}}
        {{- $matchLabels := include "stack.lib.controller.metadata.selectorLabels" (dict "rootContext" $rootContext "controllerObject" $controllerObject) | fromYaml -}}
        {{- $_ := set $constraint "labelSelector" (dict "matchLabels" $matchLabels) -}}
      {{- end -}}
    {{- end -}}
    {{- $constraints | toYaml -}}
  {{- end -}}
{{- end -}}
