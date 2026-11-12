{{/*
Values path of a container as the user writes it, for error messages:
<type> for the main container, <type>.initContainers.<name> or
<type>.additionalContainers.<name> otherwise.
*/}}
{{- define "stack.lib.container.valuesPath" -}}
  {{- $controllerObject := .controllerObject -}}
  {{- $id := .containerObject.identifier -}}
  {{- if hasKey ($controllerObject.initContainers | default dict) $id -}}
    {{- printf "%s.initContainers.%s" $controllerObject.type $id -}}
  {{- else if eq $id "main" -}}
    {{- $controllerObject.type -}}
  {{- else -}}
    {{- printf "%s.additionalContainers.%s" $controllerObject.type $id -}}
  {{- end -}}
{{- end -}}
