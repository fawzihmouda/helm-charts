{{/*
Return a RawResource Object by its Identifier.
*/}}
{{- define "stack.lib.rawResource.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $enabledRawResources := (include "stack.lib.rawResource.enabledRawResources" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledRawResources $identifier) -}}
    {{- $objectValues := get $enabledRawResources $identifier -}}
    {{- include "stack.lib.rawResource.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" (len $enabledRawResources)) -}}
  {{- end -}}
{{- end -}}
