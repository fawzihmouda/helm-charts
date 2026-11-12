{{/*
Validate Service values
*/}}
{{- define "stack.lib.service.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $serviceObject := .object -}}

  {{- $controllerObject := include "stack.lib.controller.get" (dict "rootContext" $rootContext) | fromYaml -}}
  {{- $enabledPorts := include "stack.lib.service.enabledPorts" (dict "rootContext" $rootContext "serviceObject" $serviceObject) | fromYaml }}

  {{- /* The Service targets the release's one workload, so that workload must be enabled. */ -}}
  {{- if not $controllerObject -}}
    {{- fail "Service: The workload is disabled, so the Service has nothing to send traffic to. Enable the workload or set 'service.enabled' to false." -}}
  {{- end -}}

  {{- /* Validate Service type */ -}}
  {{- $validServiceTypes := (list "ClusterIP" "LoadBalancer" "NodePort" "ExternalName" "ExternalIP") -}}
  {{- if and $serviceObject.type (not (mustHas $serviceObject.type $validServiceTypes)) -}}
    {{- fail (
      printf "invalid service type \"%s\" for the Service. Allowed values are [%s]"
      $serviceObject.type
      (join ", " $validServiceTypes)
    ) -}}
  {{- end -}}

  {{- if ne $serviceObject.type "ExternalName" -}}
    {{- $enabledPorts := include "stack.lib.service.enabledPorts" (dict "rootContext" $rootContext "serviceObject" $serviceObject) | fromYaml }}
    {{- /* Validate at least one port is enabled */ -}}
    {{- if not $enabledPorts -}}
      {{- $serviceType := $serviceObject.type | default "ClusterIP" -}}
      {{- fail (printf "Service: No ports are enabled. At least one port must be enabled for service type '%s'. Add ports under 'service.ports' in your values." $serviceType) -}}
    {{- end -}}

    {{- /* Validate no duplicate port number+protocol combinations */ -}}
    {{- $seenPorts := dict -}}
    {{- range $name, $port := $enabledPorts -}}
      {{- if $port.port -}}
        {{- $portProtocol := $port.protocol | default "TCP" -}}
        {{- if has $portProtocol (list "HTTP" "HTTPS") -}}
          {{- $portProtocol = "TCP" -}}
        {{- end -}}
        {{- $portKey := printf "%v/%s" $port.port $portProtocol -}}
        {{- if hasKey $seenPorts $portKey -}}
          {{- fail (printf "Duplicate port %v/%s found in the Service. (ports: '%s' and '%s')" $port.port $portProtocol (get $seenPorts $portKey) $name) -}}
        {{- end -}}
        {{- $_ := set $seenPorts $portKey $name -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
