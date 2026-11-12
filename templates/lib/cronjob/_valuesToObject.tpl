{{/*
Convert Cronjob values to an object
*/}}
{{- define "stack.lib.cronjob.valuesToObject" -}}
  {{- $rootContext := .rootContext -}}
  {{- $objectValues := .values -}}

  {{- if not (hasKey $objectValues "pod") -}}
    {{- $_ := set $objectValues "pod" dict -}}
  {{- end -}}

  {{- $restartPolicy := default "Never" $objectValues.pod.restartPolicy -}}
  {{- $_ := set $objectValues.pod "restartPolicy" $restartPolicy -}}

  {{- $objectValues | toYaml -}}
{{- end -}}
