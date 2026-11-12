{{/*
Return a secret Object by its Identifier.
*/}}
{{- define "stack.lib.secret.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledSecrets := (include "stack.lib.secret.enabledSecrets" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledSecrets $identifier) -}}
    {{- $objectValues := get $enabledSecrets $identifier -}}
    {{- include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledSecrets)) -}}
  {{- end -}}
{{- end -}}
