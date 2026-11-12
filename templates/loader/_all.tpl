{{/*
Main entrypoint for the common library chart. It will render all underlying templates based on the provided values.
*/}}
{{- define "stack.loader.all" -}}
  {{- /* Generate chart and dependency values */ -}}
  {{- include "stack.loader.init" . -}}

  {{- /* Generate remaining objects */ -}}
  {{- include "stack.loader.generate" . -}}
{{- end -}}
