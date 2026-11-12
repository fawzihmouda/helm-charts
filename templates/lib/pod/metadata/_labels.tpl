{{- /*
Returns the value for labels
*/ -}}
{{- define "stack.lib.pod.metadata.labels" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerObject := .controllerObject -}}

  {{- $labels := dict -}}

  {{- /* Include global labels if specified */ -}}
  {{- if $rootContext.Values.global.propagateGlobalMetadataToPods -}}
    {{- $labels = merge
      (include "stack.lib.metadata.globalLabels" $rootContext | fromYaml)
      $labels
    -}}
  {{- end -}}

  {{- /* Fetch the configured labels */ -}}
  {{- $ctx := dict "rootContext" $rootContext "controllerObject" $controllerObject -}}
  {{- $podlabels := (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "labels")) | fromYaml -}}
  {{- if not (empty $podlabels) -}}
    {{- $labels = merge
      $podlabels
      $labels
    -}}
  {{- end -}}

  {{- /* Render metadata before merging so templated keys cannot override selector labels. */ -}}
  {{- $labels = include "stack.lib.common.renderString" (dict "value" (toYaml $labels) "rootContext" $rootContext) | fromYaml -}}
  {{- $selectorLabels := include "stack.lib.controller.metadata.selectorLabels" (dict "rootContext" $rootContext "controllerObject" $controllerObject) | fromYaml -}}
  {{- mergeOverwrite $labels $selectorLabels | toYaml -}}
{{- end -}}
