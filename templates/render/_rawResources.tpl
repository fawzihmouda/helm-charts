{{/*
Renders other arbirtrary objects required by the chart.
*/}}
{{- define "stack.render.rawResources" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate raw resources as required */ -}}
  {{- $enabledRawResources := (include "stack.lib.rawResource.enabledRawResources" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledRawResources | sortAlpha -}}
    {{- /* Generate object from the raw resource values */ -}}
    {{- $rawResourceObject := (include "stack.lib.rawResource.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the raw resource class */ -}}
    {{- include "stack.class.rawResource" (dict "rootContext" $rootContext "object" $rawResourceObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
