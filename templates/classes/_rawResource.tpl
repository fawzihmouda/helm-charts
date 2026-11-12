{{/*
This template serves as a blueprint for all raw resource objects that are created
within the common library.
*/}}
{{- define "stack.class.rawResource" -}}
  {{- $rootContext := .rootContext -}}
  {{- $manifest := .object.manifest -}}
  {{- $internalData := .object._internal -}}

  {{- $userLabels := dict -}}
  {{- $userAnnotations := dict -}}
  {{- if $manifest.metadata -}}
    {{- $userLabels = $manifest.metadata.labels | default dict -}}
    {{- $userAnnotations = $manifest.metadata.annotations | default dict -}}
  {{- end -}}
  {{- $labels := merge
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    $userLabels
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    $userAnnotations
  -}}
  {{- $manifestWithoutMetadata := omit $manifest "metadata" "apiVersion" "kind" -}}
---
apiVersion: {{ $manifest.apiVersion }}
kind: {{ $manifest.kind }}
metadata:
  name: {{ $internalData.name }}
  {{- if not (empty (dig "metadata" "namespace" nil $manifest)) }}
  namespace: {{ include "stack.lib.common.renderString" (dict "value" $manifest.metadata.namespace "rootContext" $rootContext) | quote }}
  {{- end }}
  {{- with $labels }}
  labels:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $annotations }}
  annotations:
    {{- toYaml . | nindent 4 }}
  {{- end }}
{{- include "stack.lib.common.renderString" (dict "value" (toYaml $manifestWithoutMetadata) "rootContext" $rootContext) | nindent 0 }}
{{- end -}}
