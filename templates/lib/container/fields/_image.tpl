{{/*
Image used by the container.
*/}}
{{- define "stack.lib.container.field.image" -}}
  {{- $ctx := .ctx -}}
  {{- $rootContext := $ctx.rootContext -}}
  {{- $containerObject := $ctx.containerObject -}}

  {{- include "stack.lib.imageSpecificationToImage" (dict "rootContext" $rootContext "imageSpec" $containerObject.image) -}}
{{- end -}}
