{{/*
Merge the local chart values and the common chart defaults
*/}}
{{/*
Strings are evaluated against the post-merge root context.
Annotation, label and extra selector label keys are evaluated because they are user-defined labels and metadata.
ExternalSecret target template data is intentionally deferred for downstream evaluation.
*/}}
{{- define "stack.values.evaluateTemplate" -}}
  {{- $value := .value -}}
  {{- $rootContext := .rootContext -}}
  {{- $path := .path | default list -}}
  {{- $deferTpl := .deferTpl | default false -}}
  {{- $passes := .passes -}}
  {{- $excludePaths := .excludePaths -}}
  {{- $result := $value -}}
  {{- if kindIs "map" $value -}}
    {{- $result = dict -}}
    {{- $renderMapKeys := and
      (not $deferTpl)
      (gt (len $path) 0)
      (has (last $path) (list "annotations" "labels" "extraSelectorLabels"))
    -}}
    {{- range $key, $item := $value -}}
      {{- $itemPath := append $path (toString $key) -}}
      {{- $itemDeferTpl := $deferTpl -}}
      {{- /* ExternalSecret target.template.data is evaluated later by ESO with fetched keys such as .username and .password, so preserve its expressions. */ -}}
      {{- if and (eq (len $itemPath) 5) (eq (index $itemPath 0) "externalSecrets") (eq (index $itemPath 2) "target") (eq (index $itemPath 3) "template") (eq (index $itemPath 4) "data") -}}
        {{- $itemDeferTpl = true -}}
      {{- end -}}
      {{- $resultKey := toString $key -}}
      {{- if and $renderMapKeys (contains "{{" $resultKey) -}}
        {{- $renderedKey := include "stack.values.evaluateTemplate" (dict "rootContext" $rootContext "value" $resultKey "path" $itemPath "deferTpl" $itemDeferTpl "passes" $passes "excludePaths" $excludePaths) | fromJson -}}
        {{- $resultKey = index $renderedKey "value" -}}
      {{- end -}}
      {{- $itemResult := include "stack.values.evaluateTemplate" (dict "rootContext" $rootContext "value" $item "path" $itemPath "deferTpl" $itemDeferTpl "passes" $passes "excludePaths" $excludePaths) | fromJson -}}
      {{- $_ := set $result $resultKey (index $itemResult "value") -}}
    {{- end -}}
  {{- else if kindIs "slice" $value -}}
    {{- $result = list -}}
    {{- range $index, $item := $value -}}
      {{- $itemPath := append $path (toString $index) -}}
      {{- $itemResult := include "stack.values.evaluateTemplate" (dict "rootContext" $rootContext "value" $item "path" $itemPath "deferTpl" $deferTpl "passes" $passes "excludePaths" $excludePaths) | fromJson -}}
      {{- $result = append $result (index $itemResult "value") -}}
    {{- end -}}
  {{- else if kindIs "string" $value -}}
    {{- if not $deferTpl -}}
      {{- $excluded := false -}}
      {{- range $excludePath := $excludePaths -}}
        {{- if and (le (len $excludePath) (len $path)) (deepEqual $excludePath (slice $path 0 (len $excludePath))) -}}
          {{- $excluded = true -}}
        {{- end -}}
      {{- end -}}
      {{- $stringPasses := ternary 0 $passes $excluded -}}
      {{- range until ($stringPasses | int) -}}
        {{- if not (contains "{{" $result) -}}
          {{- break -}}
        {{- end -}}
        {{- $rendered := tpl $result $rootContext -}}
        {{- if eq $rendered $result -}}
          {{- break -}}
        {{- end -}}
        {{- $result = $rendered -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- toJson (dict "value" $result) -}}
{{- end -}}

{{- /*
Helm has already merged the defaults in values.yaml with the user's values. Helm
passes .Values as its own map type, which sprig's dig rejects, so the values are
copied into a plain map. Only the default Service Account still needs adding here.
*/ -}}
{{- define "stack.values.init" -}}
  {{- $values := dict -}}
  {{- range $key, $value := .Values -}}
    {{- $_ := set $values $key $value -}}
  {{- end -}}
  {{- $values = deepCopy $values -}}
  {{- if and $values.global.createDefaultServiceAccount (empty $values.serviceAccount) -}}
    {{- $_ := set $values "serviceAccount" (dict .Release.Name dict) -}}
  {{- end -}}
  {{- $_ := set . "Values" $values -}}
{{- end -}}
