{{/*
Renders the networkPolicy objects required by the chart.
*/}}
{{- define "stack.render.networkpolicies" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate networkPolicy as required */ -}}
  {{- $enabledNetworkPolicies := (include "stack.lib.networkpolicy.enabledNetworkPolicies" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledNetworkPolicies | sortAlpha -}}
    {{- /* Generate object from the raw persistence values */ -}}
    {{- $networkPolicyObject := (include "stack.lib.networkpolicy.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- if or (eq ($networkPolicyObject.type | default "native") "cilium") (eq $networkPolicyObject.type "ciliumClusterwide") -}}
      {{- include "stack.lib.ciliumNetworkPolicy.validate" (dict "rootContext" $ "object" $networkPolicyObject) -}}
      {{- include "stack.class.ciliumNetworkPolicy" (dict "rootContext" $ "object" $networkPolicyObject) | nindent 0 -}}
    {{- else -}}
      {{- include "stack.lib.networkpolicy.validate" (dict "rootContext" $ "object" $networkPolicyObject) -}}
      {{- include "stack.class.networkpolicy" (dict "rootContext" $ "object" $networkPolicyObject) | nindent 0 -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
