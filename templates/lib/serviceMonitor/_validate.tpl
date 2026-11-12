{{/*
Validate serviceMonitor values
*/}}
{{- define "stack.lib.serviceMonitor.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $serviceMonitorObject := .object -}}

  {{/* Without the chart's Service, the ServiceMonitor needs another target */}}
  {{- if not (include "stack.lib.service.get" (dict "rootContext" $rootContext)) -}}
    {{- if and
        (empty (dig "selector" nil $serviceMonitorObject))
        (empty (dig "serviceName" nil $serviceMonitorObject))
        (empty (dig "service" "name" nil $serviceMonitorObject))
    -}}
      {{- fail (printf "ServiceMonitor '%s': Set 'service.name', 'serviceName' or 'selector' because the chart creates no Service." $serviceMonitorObject.identifier) -}}
    {{- end -}}
  {{- end -}}

  {{- if not $serviceMonitorObject.endpoints -}}
    {{- fail (printf "ServiceMonitor '%s': Endpoints are required. Define at least one endpoint under 'serviceMonitor.%s.endpoints'." $serviceMonitorObject.identifier $serviceMonitorObject.identifier) -}}
  {{- end -}}
{{- end -}}
