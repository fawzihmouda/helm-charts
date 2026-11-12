{{/*
Validate networkPolicy values
*/}}
{{- define "stack.lib.networkpolicy.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $networkpolicyObject := .object -}}

  {{- /* Without a podSelector the policy selects the workload's pods. */ -}}
  {{- $controllerObject := include "stack.lib.controller.get" (dict "rootContext" $rootContext) | fromYaml -}}
  {{- if and (not $controllerObject) (not (hasKey $networkpolicyObject "podSelector")) -}}
    {{- fail (printf "NetworkPolicy '%s': The workload is disabled, so the policy has no pods to select. Enable the workload or set 'podSelector'." $networkpolicyObject.identifier) -}}
  {{- end -}}
{{- end -}}
