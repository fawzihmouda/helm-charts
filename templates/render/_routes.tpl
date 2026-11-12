{{/*
Renders the Route objects required by the chart
*/}}
{{- define "stack.render.routes" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named routes as required */ -}}
  {{- $enabledRoutes := (include "stack.lib.route.enabledRoutes" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledRoutes | sortAlpha -}}
    {{- /* Generate object from the raw route values */ -}}
    {{- $routeObject := (include "stack.lib.route.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the Route before rendering */ -}}
    {{- include "stack.lib.route.validate" (dict "rootContext" $rootContext "object" $routeObject) -}}

    {{- /* Include the Route class */ -}}
    {{- include "stack.class.route" (dict "rootContext" $rootContext "object" $routeObject) | nindent 0 -}}

    {{- /* Include the ReferenceGrant class (renders empty when not needed) */ -}}
    {{- include "stack.class.route.referenceGrant" (dict "rootContext" $rootContext "object" $routeObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
