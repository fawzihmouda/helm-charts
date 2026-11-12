{{/*
Renders the ListenerSet objects required by the chart
*/}}
{{- define "stack.render.listenerSets" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named ListenerSets as required */ -}}
  {{- $enabledListenerSets := (include "stack.lib.listenerSet.enabledListenerSets" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledListenerSets | sortAlpha -}}
    {{- /* Generate object from the raw ListenerSet values */ -}}
    {{- $listenerSetObject := (include "stack.lib.listenerSet.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the ListenerSet before rendering */ -}}
    {{- include "stack.lib.listenerSet.validate" (dict "rootContext" $rootContext "object" $listenerSetObject) -}}

    {{- /* Include the ListenerSet class */ -}}
    {{- include "stack.class.listenerSet" (dict "rootContext" $rootContext "object" $listenerSetObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
