{{/*
Validate container values
*/}}
{{- define "stack.lib.container.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerObject := .controllerObject -}}
  {{- $containerObject := .containerObject -}}

  {{- if or (empty $containerObject.image) (not (kindIs "map" $containerObject.image)) -}}
    {{- fail (printf "Container '%s': Image must be a dictionary with repository and tag fields. Define the image properly under '%s.image'." (default $containerObject.identifier $containerObject.nameOverride) (include "stack.lib.container.valuesPath" (dict "controllerObject" $controllerObject "containerObject" $containerObject))) }}
  {{- end -}}

  {{- if empty (dig "image" "repository" nil $containerObject) -}}
    {{- fail (printf "Container '%s': Image repository is required. Specify the repository under '%s.image.repository'." (default $containerObject.identifier $containerObject.nameOverride) (include "stack.lib.container.valuesPath" (dict "controllerObject" $controllerObject "containerObject" $containerObject))) }}
  {{- end -}}

  {{- if and (empty (dig "image" "tag" nil $containerObject)) (empty (dig "image" "digest" nil $containerObject)) -}}
    {{- fail (printf "Container '%s': Either image tag or digest is required. Specify a tag or digest under '%s.image'." (default $containerObject.identifier $containerObject.nameOverride) (include "stack.lib.container.valuesPath" (dict "controllerObject" $controllerObject "containerObject" $containerObject))) }}
  {{- end -}}
{{- end -}}
