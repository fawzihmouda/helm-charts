{{/*
Renders RBAC objects required by the chart.
*/}}
{{- define "stack.render.rbac" -}}
  {{- $rootContext := . -}}
  {{- include "stack.render.rbac.roles" (dict "rootContext" $rootContext) -}}
  {{- include "stack.render.rbac.roleBindings" (dict "rootContext" $rootContext) -}}
{{ end }}

{{/*
Renders RBAC Role objects required by the chart.
*/}}
{{- define "stack.render.rbac.roles" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledRoles := (include "stack.lib.rbac.role.enabledRoles" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledRoles | sortAlpha -}}
    {{- /* Generate object from the raw role values */ -}}
    {{- $roleObject := (include "stack.lib.rbac.role.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the role before rendering */ -}}
    {{- include "stack.lib.rbac.role.validate" (dict "rootContext" $rootContext "object" $roleObject) -}}

    {{/* Include the role class */}}
    {{- include "stack.class.rbac.Role" (dict "rootContext" $rootContext "object" $roleObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}

{{/*
Renders RBAC RoleBinding objects required by the chart.
*/}}
{{- define "stack.render.rbac.roleBindings" -}}
  {{- $rootContext := .rootContext -}}
  {{- $enabledRoleBindings := (include "stack.lib.rbac.roleBinding.enabledRoleBindings" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledRoleBindings | sortAlpha -}}
    {{- /* Generate object from the raw role values */ -}}
    {{- $roleBindingObject := (include "stack.lib.rbac.roleBinding.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{/* Include the RoleBinding class */}}
    {{- include "stack.class.rbac.roleBinding" (dict "rootContext" $rootContext "object" $roleBindingObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
