{{/*
Return a RoleBinding Object by its Identifier.
*/}}
{{- define "stack.lib.rbac.roleBinding.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledRoleBindings := (include "stack.lib.rbac.roleBinding.enabledRoleBindings" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledRoleBindings $identifier) -}}
    {{- $objectValues := get $enabledRoleBindings $identifier -}}
    {{- include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledRoleBindings)) -}}
  {{- end -}}
{{- end -}}
