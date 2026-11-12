{{/*
Return a ListenerSet object by its Identifier.
*/}}
{{- define "stack.lib.listenerSet.getByIdentifier" -}}
  {{- $rootContext := .rootContext -}}
  {{- $identifier := .id -}}

  {{- $enabledListenerSets := (include "stack.lib.listenerSet.enabledListenerSets" (dict "rootContext" $rootContext) | fromYaml ) }}

  {{- if (hasKey $enabledListenerSets $identifier) -}}
    {{- get $enabledListenerSets $identifier | toYaml -}}
  {{- end -}}
{{- end -}}
