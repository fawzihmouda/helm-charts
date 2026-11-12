{{/*
This template serves as a blueprint for HorizontalPodAutoscaler objects that are created
using the common library.
*/}}
{{- define "stack.class.horizontalPodAutoscaler" -}}
  {{- $rootContext := .rootContext -}}
  {{- $hpaObject := .object -}}
  {{- $controllerObject := .controllerObject -}}

  {{- $labels := include "stack.lib.metadata.allLabels" $rootContext | fromYaml -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($hpaObject.annotations | default dict)
  -}}

  {{- $targetKind := "Deployment" -}}
  {{- if eq $controllerObject.type "statefulset" -}}
    {{- $targetKind = "StatefulSet" -}}
  {{- end -}}
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: {{ $hpaObject.name }}
  {{- with $labels }}
  labels:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (include "stack.lib.common.renderString" (dict "value" $value "rootContext" $rootContext) | toYaml) | nindent 4 }}
    {{- end }}
  {{- end }}
  {{- with $annotations }}
  annotations:
    {{- range $key, $value := . }}
      {{- printf "%s: %s" $key (include "stack.lib.common.renderString" (dict "value" $value "rootContext" $rootContext) | toYaml) | nindent 4 }}
    {{- end }}
  {{- end }}
  namespace: {{ $rootContext.Release.Namespace }}
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: {{ $targetKind }}
    name: {{ $hpaObject.name }}
  {{- if and (hasKey $hpaObject "minReplicas") (ne $hpaObject.minReplicas nil) }}
  minReplicas: {{ $hpaObject.minReplicas }}
  {{- end }}
  maxReplicas: {{ $hpaObject.maxReplicas }}
  {{- with $hpaObject.metrics }}
  metrics: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $hpaObject.behavior }}
  behavior: {{- toYaml . | nindent 4 }}
  {{- end }}
{{- end -}}
