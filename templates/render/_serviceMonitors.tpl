{{/*
Renders the serviceMonitor object required by the chart.
*/}}
{{- define "stack.render.serviceMonitors" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named serviceMonitors as required */ -}}
  {{- $enabledServiceMonitors := (include "stack.lib.serviceMonitor.enabledServiceMonitors" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledServiceMonitors | sortAlpha -}}
    {{- /* Generate object from the raw serviceMonitor values */ -}}
    {{- $serviceMonitorObject := (include "stack.lib.serviceMonitor.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the ServiceMonitor before rendering */ -}}
    {{- include "stack.lib.serviceMonitor.validate" (dict "rootContext" $rootContext "object" $serviceMonitorObject) -}}

    {{- /* Include the ServiceMonitor class */ -}}
    {{- include "stack.class.serviceMonitor" (dict "rootContext" $rootContext "object" $serviceMonitorObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
