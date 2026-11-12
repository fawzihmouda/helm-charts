{{/*
Validate Route values
*/}}
{{- define "stack.lib.route.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $routeObject := .object -}}

  {{/* Without the chart's Service, every backendRef needs a name */}}
  {{- if not (include "stack.lib.service.get" (dict "rootContext" $rootContext)) -}}
    {{- if empty $routeObject.rules -}}
      {{- fail (printf "An explicit rule is required because automatic Service detection is not possible. (route: %s)" $routeObject.identifier) -}}
    {{- end -}}

    {{- range $routeObject.rules -}}
      {{- $rule := . -}}
      {{- range $rule.backendRefs }}
        {{- $backendRef := . -}}
        {{- if empty (dig "name" nil $backendRef) -}}
          {{- fail (printf "Route '%s': backendRef needs a 'name' because the chart creates no Service. Set 'name' or configure 'service'." $routeObject.identifier) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}

  {{/* Verify parentRefs name/identifier mutual exclusion */}}
  {{- range $index, $parentRef := ($routeObject.parentRefs | default list) }}
    {{- if and $parentRef.name $parentRef.identifier }}
      {{- fail (printf "Route '%s': parentRefs[%d] cannot specify both 'name' and 'identifier'. Use either a literal parent name or a ListenerSet identifier." $routeObject.identifier $index) -}}
    {{- end }}
  {{- end }}

  {{/* Route Types */}}
  {{- $routeKind := $routeObject.kind | default "HTTPRoute"}}
  {{- if and (ne $routeKind "GRPCRoute") (ne $routeKind "HTTPRoute") (ne $routeKind "TCPRoute") (ne $routeKind "TLSRoute") (ne $routeKind "UDPRoute") }}
    {{- fail (printf "Not a valid route kind (%s)" $routeKind) }}
  {{- end }}

  {{/* Route Rules */}}
  {{- range $routeObject.rules }}
  {{- if and (.filters) (.backendRefs) }}
    {{- range .filters }}
      {{- if eq .type "RequestRedirect" }}
        {{- fail (printf "Route '%s': RequestRedirect filter cannot be used together with backendRefs. Remove either the filter or the backendRefs." $routeObject.identifier) -}}
      {{- end }}
    {{- end }}
  {{- end }}
  {{- end }}
{{- end -}}
