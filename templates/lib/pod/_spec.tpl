{{- /*
The pod definition included in the controller.
*/ -}}
{{- define "stack.lib.pod.spec" -}}
  {{- $rootContext := .rootContext -}}
  {{- $controllerObject := .controllerObject -}}
  {{- $ctx := dict "rootContext" $rootContext "controllerObject" $controllerObject -}}

enableServiceLinks: {{ include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "enableServiceLinks" "default" false) }}
serviceAccountName: {{ include "stack.lib.pod.field.serviceAccountName" (dict "ctx" $ctx) | trim }}
automountServiceAccountToken: {{ include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "automountServiceAccountToken" "default" false) }}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "priorityClassName")) }}
priorityClassName: {{ . | trim }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "runtimeClassName")) }}
runtimeClassName: {{ . | trim }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "schedulerName")) }}
schedulerName: {{ . | trim }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "securityContext")) }}
securityContext: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "hostname")) }}
hostname: {{ . | trim }}
  {{- end }}
hostIPC: {{ include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "hostIPC" "default" false) }}
hostNetwork: {{ include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "hostNetwork" "default" false) }}
hostPID: {{ include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "hostPID" "default" false) }}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "hostUsers")) }}
hostUsers: {{ . | trim }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "shareProcessNamespace")) }}
shareProcessNamespace: {{ . | trim }}
  {{- end }}
dnsPolicy: {{ include "stack.lib.pod.field.dnsPolicy" (dict "ctx" $ctx) | trim }}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "dnsConfig")) }}
dnsConfig: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "hostAliases")) }}
hostAliases: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "imagePullSecrets")) }}
imagePullSecrets: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "terminationGracePeriodSeconds")) }}
terminationGracePeriodSeconds: {{ . | trim }}
  {{- end -}}
  {{- if ge ($rootContext.Capabilities.KubeVersion.Minor | int) 32 }}
    {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "resources")) }}
resources: {{ . | nindent 2 }}
    {{- end -}}
    {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "resourceClaims")) }}
resourceClaims: {{ . | nindent 2 }}
    {{- end -}}
    {{- if ge ($rootContext.Capabilities.KubeVersion.Minor | int) 36 }}
      {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "resizePolicy")) }}
resizePolicy: {{ . | nindent 4 }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "restartPolicy")) }}
restartPolicy: {{ . | trim }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "nodeSelector")) }}
nodeSelector: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "affinity")) }}
affinity: {{- include "stack.lib.common.renderString" (dict "value" . "rootContext" $rootContext) | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.field.topologySpreadConstraints" (dict "ctx" $ctx)) }}
topologySpreadConstraints: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "tolerations")) }}
tolerations: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.getOption" (dict "ctx" $ctx "option" "schedulingGates")) }}
schedulingGates: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.field.initContainers" (dict "ctx" $ctx) | trim) }}
initContainers: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.field.containers" (dict "ctx" $ctx) | trim) }}
containers: {{ . | nindent 2 }}
  {{- end -}}
  {{- with (include "stack.lib.pod.field.volumes" (dict "ctx" $ctx) | trim) }}
volumes: {{ . | nindent 2 }}
  {{- end -}}
{{- end -}}
