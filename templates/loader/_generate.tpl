{{/*
Secondary entrypoint and primary loader for the common chart
*/}}
{{- define "stack.loader.generate" -}}
  {{- $rootContext := $ -}}

  {{- /* Evaluate templates against the post-merge root context. */ -}}
  {{- $passes := dig "global" "templateEvaluation" "passes" 1 $rootContext.Values -}}
  {{- $excludePaths := dig "global" "templateEvaluation" "excludePaths" list $rootContext.Values -}}
  {{- $evaluatedValues := include "stack.values.evaluateTemplate" (dict "rootContext" $rootContext "value" (deepCopy $rootContext.Values) "passes" $passes "excludePaths" $excludePaths) | fromJson -}}
  {{- $renderContext := merge (dict) $rootContext -}}
  {{- $_ := set $renderContext "Values" (index $evaluatedValues "value") -}}
  {{- $_ := set $renderContext "TemplateRendering" (dict "valuesRendered" true) -}}

  {{- /* Run global chart validations */ -}}
  {{- include "stack.lib.chart.validate" $renderContext -}}

  {{- /* Build the templates */ -}}
  {{- include "stack.render.namespace" $renderContext | nindent 0 -}}
  {{- include "stack.render.pvcs" $renderContext | nindent 0 -}}
  {{- include "stack.render.serviceAccount" $renderContext | nindent 0 -}}
  {{- include "stack.render.configMaps.fromFolder" $renderContext | nindent 0 -}}
  {{- include "stack.render.configMaps" $renderContext | nindent 0 -}}
  {{- include "stack.render.secrets.fromFolder" $renderContext | nindent 0 -}}
  {{- include "stack.render.controllers" $renderContext | nindent 0 -}}
  {{- include "stack.render.services" $renderContext | nindent 0 -}}
  {{- include "stack.render.serviceMonitors" $renderContext | nindent 0 -}}
  {{- include "stack.render.podMonitors" $renderContext | nindent 0 -}}
  {{- include "stack.render.listenerSets" $renderContext | nindent 0 -}}
  {{- include "stack.render.routes" $renderContext | nindent 0 -}}
  {{- include "stack.render.secrets" $renderContext | nindent 0 -}}
  {{- include "stack.render.externalSecrets" $renderContext | nindent 0 -}}
  {{- include "stack.render.networkpolicies" $renderContext | nindent 0 -}}
  {{- include "stack.render.rawResources" $renderContext | nindent 0 -}}
  {{- include "stack.render.rbac" $renderContext | nindent 0 -}}
{{- end -}}
