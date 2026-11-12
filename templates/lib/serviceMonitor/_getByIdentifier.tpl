{{/*
Return a ServiceMonitor Object by its Identifier.
*/}}
{{- define "stack.lib.serviceMonitor.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledServiceMonitors := (include "stack.lib.serviceMonitor.enabledServiceMonitors" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledServiceMonitors $identifier) -}}
    {{- $objectValues := get $enabledServiceMonitors $identifier -}}
    {{- include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledServiceMonitors)) -}}
  {{- end -}}
{{- end -}}
