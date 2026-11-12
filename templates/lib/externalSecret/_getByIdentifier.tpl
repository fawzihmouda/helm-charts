{{/*
Return an ExternalSecret Object by its Identifier.
*/}}
{{- define "stack.lib.externalSecret.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledExternalSecrets := (include "stack.lib.externalSecret.enabledExternalSecrets" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledExternalSecrets $identifier) -}}
    {{- $objectValues := get $enabledExternalSecrets $identifier -}}
    {{- include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledExternalSecrets)) -}}
  {{- end -}}
{{- end -}}
