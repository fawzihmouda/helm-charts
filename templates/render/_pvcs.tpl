{{/*
Renders the Persistent Volume Claim objects required by the chart
*/}}
{{- define "stack.render.pvcs" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate pvc as required */ -}}
  {{- $enabledPVCs := (include "stack.lib.pvc.enabledPVCs" (dict "rootContext" $rootContext) | fromYaml ) -}}
  {{- range $identifier := keys $enabledPVCs | sortAlpha -}}
    {{- /* Generate object from the raw persistence values */ -}}
    {{- $pvcObject := (include "stack.lib.pvc.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Include the PVC class */ -}}
    {{- include "stack.class.pvc" (dict "rootContext" $rootContext "object" $pvcObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}
