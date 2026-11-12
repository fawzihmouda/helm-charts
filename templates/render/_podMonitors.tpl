{{/*
Renders the podMonitor objects required by the chart.
*/}}
{{- define "stack.render.podMonitors" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named podMonitors as required */ -}}
  {{- $enabledPodMonitors := (include "stack.lib.podMonitor.enabledPodMonitors" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledPodMonitors | sortAlpha -}}
    {{- /* Generate object from the raw podMonitor values */ -}}
    {{- $podMonitorObject := (include "stack.lib.podMonitor.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the PodMonitor before rendering */ -}}
    {{- include "stack.lib.podMonitor.validate" (dict "rootContext" $rootContext "object" $podMonitorObject) -}}

    {{- /* Include the PodMonitor class */ -}}
    {{- include "stack.class.podMonitor" (dict "rootContext" $rootContext "object" $podMonitorObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
