{{/*
Convert StatefulSet values to an object
*/}}
{{- define "stack.lib.statefulset.valuesToObject" -}}
  {{- $rootContext := .rootContext -}}
  {{- $objectValues := .values -}}

  {{- $strategy := default "RollingUpdate" $objectValues.strategy -}}
  {{- $_ := set $objectValues "strategy" $strategy -}}

  {{- $objectValues | toYaml -}}
{{- end -}}
