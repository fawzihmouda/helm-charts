{{/*
Validate ciliumNetworkPolicy values
*/}}
{{- define "stack.lib.ciliumNetworkPolicy.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $ciliumnetworkpolicyObject := .object -}}
  {{- $clusterwide := eq ($ciliumnetworkpolicyObject.type | default "cilium") "ciliumClusterwide" -}}
  {{- $resourceKind := ternary "CiliumClusterwideNetworkPolicy" "CiliumNetworkPolicy" $clusterwide -}}

  {{- /* Without an endpointSelector or nodeSelector the policy selects the workload's pods. */ -}}
  {{- $controllerObject := include "stack.lib.controller.get" (dict "rootContext" $rootContext) | fromYaml -}}
  {{- $hasSelector := or (hasKey $ciliumnetworkpolicyObject "endpointSelector") (hasKey $ciliumnetworkpolicyObject "nodeSelector") -}}
  {{- if and (not $controllerObject) (not $hasSelector) -}}
    {{- fail (printf "%s '%s': The workload is disabled, so the policy has no pods to select. Enable the workload or set 'endpointSelector'." $resourceKind $ciliumnetworkpolicyObject.identifier) -}}
  {{- end -}}
{{- end -}}
