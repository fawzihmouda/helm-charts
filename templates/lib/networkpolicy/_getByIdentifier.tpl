{{/*
Return a NetworkPolicy object by its Identifier.
*/}}
{{- define "stack.lib.networkpolicy.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledNetworkPolicies := (include "stack.lib.networkpolicy.enabledNetworkPolicies" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledNetworkPolicies $identifier) -}}
    {{- $objectValues := get $enabledNetworkPolicies $identifier -}}
    {{- $itemCount := len $enabledNetworkPolicies -}}
    {{- include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" $itemCount) -}}
  {{- end -}}
{{- end -}}
