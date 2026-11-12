{{/*
Convert RawResource values to an object
*/}}
{{- define "stack.lib.rawResource.valuesToObject" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}
  {{- $objectValues := .values -}}
  {{- $itemCount := .itemCount -}}

  {{- $objectName := (include "stack.lib.determineResourceNameFromValues" (dict "rootContext" $rootContext "id" $identifier "values" $objectValues "itemCount" $itemCount)) -}}

  {{- $manifest := $objectValues.manifest -}}

  {{- $internalData := dict "identifier" $identifier "name" $objectName -}}

  {{- dict "manifest" $manifest "_internal" $internalData | toYaml -}}
{{- end -}}
