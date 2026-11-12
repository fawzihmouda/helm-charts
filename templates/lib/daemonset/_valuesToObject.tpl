{{/*
Convert DaemonSet values to an object
*/}}
{{- define "stack.lib.daemonset.valuesToObject" -}}
  {{- $rootContext := .rootContext -}}
  {{- $objectValues := .values -}}

  {{- /* Return the DaemonSet object */ -}}
  {{- $objectValues | toYaml -}}
{{- end -}}
