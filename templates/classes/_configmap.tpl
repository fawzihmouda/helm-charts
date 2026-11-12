{{/*
This template serves as a blueprint for all configMap objects that are created
within the common library.
*/}}
{{- define "stack.class.configMap" -}}
  {{- $rootContext := .rootContext -}}
  {{- $configMapObject := .object -}}

  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($configMapObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($configMapObject.annotations | default dict)
  -}}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $configMapObject.name }}
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
  namespace: {{ $rootContext.Release.Namespace }}
{{- with $configMapObject.data }}
data:
    {{- include "stack.lib.common.renderString" (dict "value" (toYaml .) "rootContext" $rootContext "render" ($configMapObject.renderFileContent | default false)) | nindent 2 }}
{{- end }}
{{- with $configMapObject.binaryData }}
binaryData:
    {{- include "stack.lib.common.renderString" (dict "value" (toYaml .) "rootContext" $rootContext "render" ($configMapObject.renderFileContent | default false)) | nindent 2 }}
{{- end }}
{{- end -}}
