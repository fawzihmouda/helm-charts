{{/*
This template serves as a blueprint for generating Role objects in Kubernetes.
*/}}
{{- define "stack.class.rbac.Role" -}}
  {{- $rootContext := .rootContext -}}
  {{- $roleObject := .object -}}

  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($roleObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($roleObject.annotations | default dict)
  -}}
  {{- $rules := "" -}}
  {{- with $roleObject.rules -}}
    {{- $rules = (toYaml . ) | trim -}}
  {{- end -}}
---
apiVersion: rbac.authorization.k8s.io/v1
{{ with $roleObject.type -}}
kind: {{ . }}
{{ end -}}
metadata:
  name: {{ $roleObject.name }}
  {{- with $labels }}
  labels:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (include "stack.lib.common.renderString" (dict "value" $value "rootContext" $rootContext) | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $annotations }}
  annotations:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (include "stack.lib.common.renderString" (dict "value" $value "rootContext" $rootContext) | toYaml ) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- if eq $roleObject.type "Role" }}
  namespace: {{ $rootContext.Release.Namespace }}
  {{- end }}
{{- with $rules }}
rules: {{- include "stack.lib.common.renderString" (dict "value" . "rootContext" $rootContext) | nindent 2 }}
{{- end }}
{{- end -}}
