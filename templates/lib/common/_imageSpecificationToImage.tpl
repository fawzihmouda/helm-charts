
{{/*
Translate an imageSpecification to an image string.
*/}}
{{- define "stack.lib.imageSpecificationToImage" -}}
  {{- $rootContext := .rootContext -}}
  {{- $imageSpec := .imageSpec -}}

  {{- $imageRepo := include "stack.lib.common.renderString" (dict "value" $imageSpec.repository "rootContext" $rootContext) -}}
  {{- $imageTag := include "stack.lib.common.renderString" (dict "value" (default "" $imageSpec.tag) "rootContext" $rootContext) -}}
  {{- $imageDigest := include "stack.lib.common.renderString" (dict "value" (default "" $imageSpec.digest) "rootContext" $rootContext) -}}

  {{- $image := $imageRepo -}}
  {{- if $imageTag -}}
    {{- $image = printf "%s:%s" $image $imageTag -}}
  {{- end -}}
  {{- if $imageDigest -}}
    {{- $image = printf "%s@%s" $image $imageDigest -}}
  {{- end -}}
  {{- $image -}}
{{- end -}}
