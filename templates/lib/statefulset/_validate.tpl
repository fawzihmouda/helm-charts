{{/*
Validate StatefulSet values
*/}}
{{- define "stack.lib.statefulset.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $statefulsetValues := .object -}}

  {{- range $index, $volumeClaimTemplate := $statefulsetValues.volumeClaimTemplates -}}
    {{- if empty (get . "size") -}}
      {{- fail (printf "StatefulSet: VolumeClaimTemplate '%s' requires a 'size' field. Define the size under 'statefulset.volumeClaimTemplates[].size'." $volumeClaimTemplate.name) -}}
    {{- end -}}

    {{- if empty (get . "accessMode") -}}
      {{- fail (printf "StatefulSet: VolumeClaimTemplate '%s' requires an 'accessMode' field. Define the accessMode under 'statefulset.volumeClaimTemplates[].accessMode'." $volumeClaimTemplate.name) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
