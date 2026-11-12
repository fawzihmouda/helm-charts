{{/*
Return a PVC object by its Identifier.
*/}}
{{- define "stack.lib.pvc.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledPVCs := (include "stack.lib.pvc.enabledPVCs" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledPVCs $identifier) -}}
    {{- $objectValues := get $enabledPVCs $identifier -}}
    {{- include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledPVCs)) -}}
  {{- end -}}
{{- end -}}
