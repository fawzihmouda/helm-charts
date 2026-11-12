{{/*
Return the enabled podMonitors.
*/}}
{{- define "stack.lib.podMonitor.enabledPodMonitors" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledPodMonitors := dict -}}

  {{- range $identifier, $podMonitor := $rootContext.Values.podMonitor -}}
    {{- if kindIs "map" $podMonitor -}}
      {{- /* Enable podMonitors by default, but allow override */ -}}
      {{- $podMonitorEnabled := true -}}
      {{- if hasKey $podMonitor "enabled" -}}
        {{- $podMonitorEnabled = $podMonitor.enabled -}}
      {{- end -}}

      {{- if $podMonitorEnabled -}}
        {{- $_ := set $enabledPodMonitors $identifier . -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- range $identifier, $objectValues := $enabledPodMonitors -}}
    {{- $object := include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledPodMonitors)) | fromYaml -}}
    {{- $_ := set $enabledPodMonitors $identifier $object -}}
  {{- end -}}

  {{- $enabledPodMonitors | toYaml -}}
{{- end -}}
