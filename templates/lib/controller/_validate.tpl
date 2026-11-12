{{/*
Validate controller values
*/}}
{{- define "stack.lib.controller.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerValues := .object -}}

  {{- if hasKey ($controllerValues.additionalContainers | default dict) "main" -}}
    {{- fail "additionalContainers can't use the name main: it is reserved for the main container" -}}
  {{- end -}}

  {{- $enabledServiceAccounts := (include "stack.lib.serviceAccount.enabledServiceAccounts" (dict "rootContext" $rootContext) | fromYaml ) }}
  {{- if not (has "serviceAccount" (keys $controllerValues)) -}}
    {{- if (gt (len $enabledServiceAccounts) 1) -}}
      {{- $availableSAs := list -}}
      {{- range $sa := $enabledServiceAccounts -}}
        {{- $availableSAs = append $availableSAs $sa.identifier -}}
      {{- end -}}
      {{- fail (printf "Workload '%s': serviceAccount field is required because automatic Service Account detection is not possible (found %d service accounts: %s). Specify which service account to use under '%s.serviceAccount'." $controllerValues.type (len $enabledServiceAccounts) (join ", " $availableSAs) $controllerValues.type) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
