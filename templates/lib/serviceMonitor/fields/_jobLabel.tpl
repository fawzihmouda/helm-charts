{{- /*
Returns the value for serviceMonitor jobLabel
*/ -}}
{{- define "stack.lib.serviceMonitor.field.jobLabel" -}}
  {{- $ctx := .ctx -}}
  {{- $rootContext := $ctx.rootContext -}}
  {{- $serviceMonitorObject := $ctx.serviceMonitorObject -}}

  {{- if $serviceMonitorObject.jobLabel -}}
    {{- include "stack.lib.common.renderString" (dict "value" $serviceMonitorObject.jobLabel "rootContext" $rootContext) -}}
  {{- else -}}
    app.kubernetes.io/name
  {{- end -}}
{{- end -}}
