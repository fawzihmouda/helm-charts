{{/*
Renders the workload and its PodDisruptionBudget and HorizontalPodAutoscaler.
*/}}
{{- define "stack.render.controllers" -}}
  {{- $rootContext := $ -}}
  {{- $controllerObject := include "stack.lib.controller.get" (dict "rootContext" $rootContext) | fromYaml -}}

  {{- if $controllerObject -}}
    {{- include "stack.lib.controller.validate" (dict "rootContext" $rootContext "object" $controllerObject) -}}

    {{- /* The HPA owns the replica count, so replicas becomes the HPA's default minReplicas. */ -}}
    {{- if $controllerObject.horizontalPodAutoscaler -}}
      {{- if and (hasKey $controllerObject "replicas") (ne $controllerObject.replicas nil) -}}
        {{- if not (hasKey $controllerObject.horizontalPodAutoscaler "minReplicas") -}}
          {{- $_ := set $controllerObject.horizontalPodAutoscaler "minReplicas" $controllerObject.replicas -}}
        {{- end -}}
      {{- end -}}
      {{- $_ := set $controllerObject "replicas" nil -}}
    {{- end -}}

    {{- $type := $controllerObject.type -}}
    {{- $object := include (printf "stack.lib.%s.valuesToObject" $type) (dict "rootContext" $rootContext "values" $controllerObject) | fromYaml -}}
    {{- include (printf "stack.lib.%s.validate" $type) (dict "rootContext" $rootContext "object" $object) -}}
    {{- include (printf "stack.class.%s" $type) (dict "rootContext" $rootContext "object" $object) | nindent 0 -}}

    {{- if $controllerObject.podDisruptionBudget -}}
      {{- $podDisruptionBudgetObject := include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $controllerObject.identifier "values" (merge (dict "forceRename" $controllerObject.name) $controllerObject.podDisruptionBudget)) | fromYaml -}}
      {{- include "stack.class.podDisruptionBudget" (dict "rootContext" $rootContext "object" $podDisruptionBudgetObject "controllerObject" $controllerObject) | nindent 0 -}}
    {{- end -}}

    {{- if $controllerObject.horizontalPodAutoscaler -}}
      {{- $hpaObject := include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $controllerObject.identifier "values" (merge (dict "forceRename" $controllerObject.name) $controllerObject.horizontalPodAutoscaler)) | fromYaml -}}
      {{- include "stack.lib.horizontalPodAutoscaler.validate" (dict "rootContext" $rootContext "object" $hpaObject "controllerObject" $controllerObject) -}}
      {{- include "stack.class.horizontalPodAutoscaler" (dict "rootContext" $rootContext "object" $hpaObject "controllerObject" $controllerObject) | nindent 0 -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
