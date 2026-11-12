{{/*
Renders the serviceAccount object required by the chart.
*/}}
{{- define "stack.render.serviceAccount" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate named serviceAccounts as required */ -}}
  {{- $enabledServiceAccounts := (include "stack.lib.serviceAccount.enabledServiceAccounts" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledServiceAccounts | sortAlpha -}}
    {{- /* Generate object from the raw serviceAccount values */ -}}
    {{- $serviceAccountObject := (include "stack.lib.serviceAccount.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the ServiceAccount before rendering */ -}}
    {{- include "stack.lib.serviceAccount.validate" (dict "rootContext" $rootContext "object" $serviceAccountObject) -}}

    {{- /* Create a service account secret */ -}}
    {{- if $serviceAccountObject.staticToken -}}
      {{- $_ := set $rootContext.Values.secrets (printf "%s-sa-token" $serviceAccountObject.identifier) (dict "suffix" (printf "%s-sa-token" $serviceAccountObject.identifier) "annotations" (dict "kubernetes.io/service-account.name" $serviceAccountObject.name) "type" "kubernetes.io/service-account-token") -}}
    {{- end -}}

    {{- /* Include the ServiceAccount class */ -}}
    {{- include "stack.class.serviceAccount" (dict "rootContext" $rootContext "object" $serviceAccountObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
