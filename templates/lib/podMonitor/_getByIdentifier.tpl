{{/*
Return a PodMonitor Object by its Identifier.
*/}}
{{- define "stack.lib.podMonitor.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledPodMonitors := (include "stack.lib.podMonitor.enabledPodMonitors" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledPodMonitors $identifier) -}}
    {{- $objectValues := get $enabledPodMonitors $identifier -}}
    {{- include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledPodMonitors)) -}}
  {{- end -}}
{{- end -}}
