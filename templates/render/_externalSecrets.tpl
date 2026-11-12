{{/*
Renders the ExternalSecret objects required by the chart.
*/}}
{{- define "stack.render.externalSecrets" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named ExternalSecrets as required */ -}}
  {{- $enabledExternalSecrets := (include "stack.lib.externalSecret.enabledExternalSecrets" (dict "rootContext" $rootContext) | fromYaml ) -}}

  {{- range $identifier := keys $enabledExternalSecrets | sortAlpha -}}
    {{- /* Generate object from the raw externalSecret values */ -}}
    {{- $externalSecretObject := (include "stack.lib.externalSecret.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the ExternalSecret before rendering */ -}}
    {{- include "stack.lib.externalSecret.validate" (dict "rootContext" $rootContext "object" $externalSecretObject) -}}

    {{- /* Include the ExternalSecret class */ -}}
    {{- include "stack.class.externalSecret" (dict "rootContext" $rootContext "object" $externalSecretObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
