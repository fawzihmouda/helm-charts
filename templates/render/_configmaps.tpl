{{/*
Renders the configMap objects required by the chart.
*/}}
{{- define "stack.render.configMaps" -}}
  {{- $rootContext := $ -}}

  {{- /* Generate configMaps as required */ -}}
  {{- $enabledConfigMaps := (include "stack.lib.configMap.enabledConfigmaps" (dict "rootContext" $rootContext) | fromYaml ) -}}

  {{- range $identifier := keys $enabledConfigMaps | sortAlpha -}}
    {{- /* Generate object from the raw configMap values */ -}}
    {{- $configMapObject := (include "stack.lib.configMap.getByIdentifier" (dict "rootContext" $rootContext "id" $identifier) | fromYaml) -}}

    {{- /* Perform validations on the configMap before rendering */ -}}
    {{- include "stack.lib.configMap.validate" (dict "rootContext" $rootContext "object" $configMapObject "id" $identifier) -}}

      {{/* Include the configMap class */}}
      {{- include "stack.class.configMap" (dict "rootContext" $rootContext "object" $configMapObject) | nindent 0 -}}
  {{- end -}}
{{- end -}}

{{/*
Renders configMap objects required by the chart from a folder in the repo's path.
*/}}
{{- define "stack.render.configMaps.fromFolder" -}}
  {{- $rootContext := $ -}}

  {{- $valuesCopy := $rootContext.Values -}}
  {{- $configMapsFromFolder := $rootContext.Values.configMapsFromFolder | default dict -}}
  {{- $configMapsFromFolderEnabled := dig "enabled" false $configMapsFromFolder -}}

  {{- if $configMapsFromFolderEnabled -}}
    {{- /* Perform validations before rendering */ -}}
    {{- include "stack.lib.configMap.fromFolder.validate" (dict "rootContext" $ "basePath" ($configMapsFromFolder.basePath | default "" )) -}}

    {{- /* Collect folder contents */ -}}
    {{- $collected := include "stack.lib.filesFolders.collectFilesfromFolder" (
        dict
        "rootContext" $rootContext
        "basePath" $configMapsFromFolder.basePath
        "fromFolder" $configMapsFromFolder
        "overridesKey" "configMapsOverrides"
      ) | fromYaml
    -}}

    {{- /* Iterate collected folders */ -}}
    {{- range $folder, $entry := $collected -}}
      {{- $configMapValues := dict
        "enabled" true
        "renderFileContent" true
        "forceRename" $entry.forceRename
        "labels" $entry.labels
        "annotations" $entry.annotations
        "data" $entry.text
        "binaryData" $entry.binary
      -}}
      {{- $configMapObject := (include "stack.lib.valuesToObject" (dict "rootContext" $rootContext "id" $folder "values" $configMapValues) | fromYaml) -}}

      {{- $existingConfigMaps := (get $valuesCopy "configMaps" | default dict) -}}
      {{- $mergedConfigMaps := deepCopy $existingConfigMaps | merge (dict $folder $configMapObject) -}}
      {{- $valuesCopy := merge $valuesCopy (dict "configMaps" $mergedConfigMaps) -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
