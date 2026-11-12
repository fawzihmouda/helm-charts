{{/*
Validate global chart values
*/}}
{{- define "stack.lib.chart.validate" -}}
  {{- $rootContext := . -}}

  {{- /* A release runs exactly one workload, set under the key named after its type. */ -}}
  {{- $types := include "stack.lib.controller.types" . | fromYamlArray -}}
  {{- if $rootContext.Values.controllers -}}
    {{- fail (printf "controllers is not supported. Set the workload under one of: %s" (join ", " $types)) -}}
  {{- end -}}
  {{- $set := list -}}
  {{- range $type := $types -}}
    {{- if kindIs "map" (get $rootContext.Values $type) -}}
      {{- $set = append $set $type -}}
    {{- end -}}
  {{- end -}}
  {{- if ne (len $set) 1 -}}
    {{- fail (printf "Set exactly one workload type out of: %s. Found: [%s]" (join ", " $types) (join ", " $set)) -}}
  {{- end -}}

  {{- $enabledSecrets := include "stack.lib.secret.enabledSecrets" (dict "rootContext" $rootContext) | fromYaml -}}
  {{- $enabledExternalSecrets := include "stack.lib.externalSecret.enabledExternalSecrets" (dict "rootContext" $rootContext) | fromYaml -}}
  {{- $nativeSecretNames := dict -}}

  {{- range $identifier, $values := $enabledSecrets -}}
    {{- $object := include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" (deepCopy $values) "itemCount" (len $enabledSecrets)) | fromYaml -}}
    {{- $_ := set $nativeSecretNames $object.name $identifier -}}
  {{- end -}}

  {{- range $identifier, $values := $enabledExternalSecrets -}}
    {{- $object := include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $identifier "values" (deepCopy $values) "itemCount" (len $enabledExternalSecrets)) | fromYaml -}}
    {{- $targetName := include "stack.lib.externalSecret.getSecretName" $object -}}
    {{- if hasKey $nativeSecretNames $targetName -}}
      {{- $nativeIdentifier := get $nativeSecretNames $targetName -}}
      {{- fail (printf "Secret '%s': Rendered Secret name '%s' collides with ExternalSecret '%s'. Choose unique Secret names." $nativeIdentifier $targetName $identifier) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
