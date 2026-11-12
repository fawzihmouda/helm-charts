{{/*
Validate podMonitor values
*/}}
{{- define "stack.lib.podMonitor.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $podMonitorObject := .object -}}

  {{- $controllerObject := include "stack.lib.controller.get" (dict "rootContext" $rootContext) | fromYaml -}}

  {{- /* Without a selector the PodMonitor selects the workload's pods. */ -}}
  {{- if and (not $controllerObject) (not (hasKey $podMonitorObject "selector")) -}}
    {{- fail (printf "PodMonitor '%s': The workload is disabled, so the PodMonitor has no pods to select. Enable the workload or set 'selector'." $podMonitorObject.identifier) -}}
  {{- end -}}

  {{- if not $podMonitorObject.podMetricsEndpoints -}}
    {{- fail (printf "PodMonitor '%s': podMetricsEndpoints are required. Define at least one endpoint under 'podMonitor.%s.podMetricsEndpoints'." $podMonitorObject.identifier $podMonitorObject.identifier) -}}
  {{- end -}}
{{- end -}}
