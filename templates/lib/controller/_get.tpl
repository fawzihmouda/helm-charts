{{/*
The workload types a release can set. Each one is a top-level values key.
*/}}
{{- define "stack.lib.controller.types" -}}
  {{- list "deployment" "statefulset" "daemonset" "job" "cronjob" | toYaml -}}
{{- end -}}

{{/*
Return the release's workload object, built from the values under its type key.
Returns nothing when no type key is set or the workload is disabled.
*/}}
{{- define "stack.lib.controller.get" -}}
  {{- $rootContext := .rootContext -}}
  {{- range $type := include "stack.lib.controller.types" . | fromYamlArray -}}
    {{- $values := get $rootContext.Values $type -}}
    {{- if kindIs "map" $values -}}
      {{- $enabled := true -}}
      {{- if hasKey $values "enabled" -}}
        {{- $enabled = $values.enabled -}}
      {{- end -}}
      {{- if $enabled -}}
        {{- $object := deepCopy $values -}}
        {{- $_ := set $object "type" $type -}}
        {{- include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" "main" "values" $object "itemCount" 1) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
