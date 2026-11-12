{{/*
This template serves as a blueprint for all ciliumNetworkPolicy objects that are created
within the common library.
*/}}
{{- define "stack.class.ciliumNetworkPolicy" -}}
  {{- $rootContext := .rootContext -}}
  {{- $ciliumNetworkPolicyObject := .object -}}

  {{- $labels := mergeOverwrite
    (include "stack.lib.metadata.allLabels" $rootContext | fromYaml)
    ($ciliumNetworkPolicyObject.labels | default dict)
  -}}
  {{- $annotations := mergeOverwrite
    (include "stack.lib.metadata.globalAnnotations" $rootContext | fromYaml)
    ($ciliumNetworkPolicyObject.annotations | default dict)
  -}}
  {{- $clusterwide := eq ($ciliumNetworkPolicyObject.type | default "cilium") "ciliumClusterwide" -}}
  {{- $resourceKind := ternary "CiliumClusterwideNetworkPolicy" "CiliumNetworkPolicy" $clusterwide -}}
  {{- $endpointSelector := dict -}}
  {{- if hasKey $ciliumNetworkPolicyObject "nodeSelector" -}}
    {{- /* CiliumClusterwideNetworkPolicy node selectors replace endpoint selectors. */ -}}
  {{- else if (hasKey $ciliumNetworkPolicyObject "endpointSelector") -}}
    {{- $endpointSelector = $ciliumNetworkPolicyObject.endpointSelector -}}
  {{- else -}}
    {{- $controllerObject := include "stack.lib.controller.get" (dict "rootContext" $rootContext) | fromYaml -}}
    {{- $selectorLabels := include "stack.lib.controller.metadata.selectorLabels" (dict "rootContext" $rootContext "controllerObject" $controllerObject) | fromYaml -}}
    {{- $endpointSelector = dict "matchLabels" (mergeOverwrite $selectorLabels ($ciliumNetworkPolicyObject.extraSelectorLabels | default dict)) -}}
  {{- end -}}
---
apiVersion: cilium.io/v2
kind: {{ if $clusterwide }}CiliumClusterwideNetworkPolicy{{ else }}CiliumNetworkPolicy{{ end }}
metadata:
  name: {{ $ciliumNetworkPolicyObject.name }}
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
  {{ if not $clusterwide }}namespace: {{ $rootContext.Release.Namespace }}{{ end }}
spec:
  {{ if hasKey $ciliumNetworkPolicyObject "nodeSelector" }}nodeSelector: {{ include "stack.lib.common.renderString" (dict "value" (toYaml $ciliumNetworkPolicyObject.nodeSelector) "rootContext" $rootContext) | nindent 4 }}
  {{ else }}endpointSelector: {{ toYaml $endpointSelector | nindent 4 }}{{ end }}
  {{- with $ciliumNetworkPolicyObject.description }}
  description: {{ include "stack.lib.common.renderString" (dict "value" . "rootContext" $rootContext) | quote }}
  {{- end }}
  {{- with $ciliumNetworkPolicyObject.ingress }}
  ingress: {{- include "stack.lib.common.renderString" (dict "value" (toYaml .) "rootContext" $rootContext) | nindent 4 -}}
  {{- end }}
  {{- with $ciliumNetworkPolicyObject.ingressDeny }}
  ingressDeny: {{- include "stack.lib.common.renderString" (dict "value" (toYaml .) "rootContext" $rootContext) | nindent 4 -}}
  {{- end }}
  {{- with $ciliumNetworkPolicyObject.egress }}
  egress: {{- include "stack.lib.common.renderString" (dict "value" (toYaml .) "rootContext" $rootContext) | nindent 4 -}}
  {{- end }}
  {{- with $ciliumNetworkPolicyObject.egressDeny }}
  egressDeny: {{- include "stack.lib.common.renderString" (dict "value" (toYaml .) "rootContext" $rootContext) | nindent 4 -}}
  {{- end }}
  {{- with $ciliumNetworkPolicyObject.enableDefaultDeny }}
  enableDefaultDeny: {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- with $ciliumNetworkPolicyObject.log }}
  log:
    value: {{ . | quote }}
  {{- end }}
{{- end -}}
