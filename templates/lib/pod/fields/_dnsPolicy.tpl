{{- /*
Returns the value for dnsPolicy
*/ -}}
{{- define "stack.lib.pod.field.dnsPolicy" -}}
  {{- $ctx := .ctx -}}
  {{- $controllerObject := $ctx.controllerObject -}}

  {{- /* Default to "ClusterFirst" */ -}}
  {{- $dnsPolicy := "ClusterFirst" -}}

  {{- /* Get hostNetwork value "" */ -}}
  {{- $hostNetwork:= include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "hostNetwork") -}}
  {{- if (eq $hostNetwork "true") -}}
    {{- $dnsPolicy = "ClusterFirstWithHostNet" -}}
  {{- end -}}

  {{- /* See if an override is desired */ -}}
  {{- $override := include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "dnsPolicy") -}}

  {{- if not (empty $override) -}}
    {{- $dnsPolicy = $override -}}
  {{- end -}}

  {{- $dnsPolicy -}}
{{- end -}}
