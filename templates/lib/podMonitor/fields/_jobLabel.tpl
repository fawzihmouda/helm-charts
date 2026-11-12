{{- /*
Returns the value for podMonitor jobLabel
*/ -}}
{{- define "stack.lib.podMonitor.field.jobLabel" -}}
  {{- $ctx := .ctx -}}
  {{- $rootContext := $ctx.rootContext -}}
  {{- $podMonitorObject := $ctx.podMonitorObject -}}

  {{- if $podMonitorObject.jobLabel -}}
    {{- include "stack.lib.common.renderString" (dict "value" $podMonitorObject.jobLabel "rootContext" $rootContext) -}}
  {{- else -}}
    app.kubernetes.io/name
  {{- end -}}
{{- end -}}
