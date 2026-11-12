{{/*
Return the enabled containers of the workload, keyed by name.

The main container's fields sit directly under the workload's type key, and it
is keyed "main" so dependsOn and persistence advancedMounts can refer to it.
Its name defaults to the release name. Other containers come from
additionalContainers.
*/}}
{{- define "stack.lib.controller.enabledContainers" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerObject := .controllerObject -}}

  {{- $containerKeys := list "args" "command" "dependsOn" "env" "envFrom" "image" "lifecycle" "nameOverride" "ports" "probes" "resources" "resizePolicy" "restartPolicy" "securityContext" "stdin" "terminationMessagePath" "terminationMessagePolicy" "tty" "workingDir" -}}
  {{- $main := dict "nameOverride" $rootContext.Release.Name -}}
  {{- range $key := $containerKeys -}}
    {{- if hasKey $controllerObject $key -}}
      {{- $_ := set $main $key (get $controllerObject $key) -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledContainers := dict "main" $main -}}
  {{- range $name, $container := $controllerObject.additionalContainers -}}
    {{- if kindIs "map" $container -}}
      {{- /* Enable container by default, but allow override */ -}}
      {{- $containerEnabled := true -}}
      {{- if hasKey $container "enabled" -}}
        {{- $containerEnabled = $container.enabled -}}
      {{- end -}}

      {{- if $containerEnabled -}}
        {{- $_ := set $enabledContainers $name $container -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{- $enabledContainers | toYaml -}}
{{- end -}}
