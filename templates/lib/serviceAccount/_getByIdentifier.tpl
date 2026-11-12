{{/*
Return a ServiceAccount Object by its Identifier.
*/}}
{{- define "stack.lib.serviceAccount.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledServiceAccounts := (include "stack.lib.serviceAccount.enabledServiceAccounts" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledServiceAccounts $identifier) -}}
    {{- get $enabledServiceAccounts $identifier | toYaml -}}
  {{- end -}}
{{- end -}}
