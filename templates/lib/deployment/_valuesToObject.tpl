{{/*
Convert Deployment values to an object
*/}}
{{- define "stack.lib.deployment.valuesToObject" -}}
  {{- $rootContext := .rootContext -}}
  {{- $objectValues := .values -}}

  {{- $strategy := default "Recreate" $objectValues.strategy -}}
  {{- $_ := set $objectValues "strategy" $strategy -}}

  {{- /* Return the Deployment object */ -}}
  {{- $objectValues | toYaml -}}
{{- end -}}
