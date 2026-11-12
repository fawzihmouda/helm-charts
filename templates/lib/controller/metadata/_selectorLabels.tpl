{{/*
Return the labels identifying a controller's pods. Regular metadata labels are excluded.
Accepts rootContext and controllerObject.
*/}}
{{- define "stack.lib.controller.metadata.selectorLabels" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerObject := .controllerObject -}}
  {{- $extraSelectorLabels := include "stack.lib.common.renderString" (dict "value" (toYaml ($controllerObject.extraSelectorLabels | default dict)) "rootContext" $rootContext) | fromYaml -}}
  {{- $selectorLabels := mergeOverwrite
    (dict)
    (include "stack.lib.metadata.selectorLabels" $rootContext | fromYaml)
    $extraSelectorLabels
  -}}
  {{- toYaml $selectorLabels -}}
{{- end -}}
