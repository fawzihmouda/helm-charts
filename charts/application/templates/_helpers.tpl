{{/*
Name of every resource the chart creates: the release name, or fullnameOverride.
*/}}
{{- define "application.fullname" -}}
{{- default .Release.Name .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Version label, taken from the rendered workload image tag.
*/}}
{{- define "application.version" -}}
  {{- $version := include "application.tplvalues.render" (dict "value" .Values.workload.image.tag "context" .) -}}
  {{- $version = regexReplaceAll "[^a-zA-Z0-9_\\.\\-]" $version "-" | trunc 63 -}}
  {{- /* A label value must start and end with a letter or a digit. */}}
  {{- regexReplaceAll "^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$" $version "" -}}
{{- end -}}

{{/*
Renders the templates in a value. A string comes back rendered. A map or a list comes
back as YAML with tpl applied to each string inside it, so rendered text such as
"a: b" or "x #y" stays a string and can't change the YAML structure.
Usage:
{{ include "application.tplvalues.render" (dict "value" .Values.path.to.the.Value "context" $) }}
*/}}
{{- define "application.tplvalues.render" -}}
{{- if kindIs "string" .value -}}
  {{- tpl .value .context -}}
{{- else if .value -}}
  {{- (include "application.tplvalues.walk" . | fromJson).value | toYaml -}}
{{- end -}}
{{- end -}}

{{/*
Applies tpl to every string in a value. Returns the JSON of {"value": <result>},
because a named template can only return text.
*/}}
{{- define "application.tplvalues.walk" -}}
{{- $value := .value -}}
{{- $context := .context -}}
{{- if kindIs "string" $value -}}
  {{- $value = tpl $value $context -}}
{{- else if kindIs "map" $value -}}
  {{- $rendered := dict -}}
  {{- range $key, $item := $value -}}
    {{- $_ := set $rendered $key (include "application.tplvalues.walk" (dict "value" $item "context" $context) | fromJson).value -}}
  {{- end -}}
  {{- $value = $rendered -}}
{{- else if kindIs "slice" $value -}}
  {{- $rendered := list -}}
  {{- range $item := $value -}}
    {{- $rendered = append $rendered (include "application.tplvalues.walk" (dict "value" $item "context" $context) | fromJson).value -}}
  {{- end -}}
  {{- $value = $rendered -}}
{{- end -}}
{{- dict "value" $value | toJson -}}
{{- end -}}

{{/*
Renders the fields of a values map that are set, each as `name: value` at the given indent.
Null, "", {} and [] count as unset; false and 0 are rendered. toYaml keeps large numbers
as written, where printing one directly gives 1.2096e+06.
Usage:
{{- include "application.fields" (dict "from" .Values.service "indent" 2 "names" (list "clusterIP" "externalIPs")) }}
*/}}
{{- define "application.fields" -}}
{{- range $name := .names -}}
  {{- $value := get $.from $name -}}
  {{- if not (has (toJson $value) (list "null" "\"\"" "{}" "[]")) -}}
    {{- dict $name $value | toYaml | nindent (int $.indent) -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Renders a list of named items (env vars, volumes, containers) through tpl.
Accepts a list, which keeps its order, or a map keyed by item name, which
Helm sorts alphabetically. In a map the key is the name. A null entry is skipped.
For containers, pass "securityContext": a container that sets none gets it, and
with it the "volumeMount" (the writable /tmp) unless it mounts that path itself.
Usage:
{{ include "application.namedList" (dict "value" .Values.workload.env "context" $) }}
*/}}
{{- define "application.namedList" -}}
  {{- $items := list -}}
  {{- range $name, $item := .value -}}
    {{- if not (kindIs "invalid" $item) -}}
      {{- if kindIs "map" $.value -}}
        {{- $item = merge (dict "name" $name) $item -}}
      {{- end -}}
      {{- if and $.securityContext (not (hasKey $item "securityContext")) -}}
        {{- $mountPaths := list -}}
        {{- range $item.volumeMounts -}}
          {{- $mountPaths = append $mountPaths .mountPath -}}
        {{- end -}}
        {{- if and $.volumeMount (not (has $.volumeMount.mountPath $mountPaths)) -}}
          {{- $item = merge (dict "volumeMounts" (append (default list $item.volumeMounts) $.volumeMount)) (omit $item "volumeMounts") -}}
        {{- end -}}
        {{- $item = merge (dict "securityContext" $.securityContext) $item -}}
      {{- end -}}
      {{- $items = append $items $item -}}
    {{- end -}}
  {{- end -}}
  {{- include "application.tplvalues.render" (dict "value" $items "context" .context) -}}
{{- end -}}

{{/*
Image reference: repository, then ":tag" and "@digest" when set. The runtime pulls by
digest when both are set.
Usage:
{{ include "application.image" (dict "image" .Values.workload.image "name" "app" "context" $) }}
*/}}
{{- define "application.image" -}}
  {{- $repo := include "application.tplvalues.render" (dict "value" .image.repository "context" .context) -}}
  {{- $image := required (printf "Undefined image repository for container '%s'" .name) $repo -}}
  {{- with include "application.tplvalues.render" (dict "value" .image.tag "context" .context) }}
    {{- $image = print $image ":" . -}}
  {{- end }}
  {{- with include "application.tplvalues.render" (dict "value" .image.digest "context" .context) }}
    {{- $image = print $image "@" . -}}
  {{- end }}
  {{- $image -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "application.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "application.labels" -}}
{{- $chart := dict
  "helm.sh/chart" (include "application.chart" .)
  "app.kubernetes.io/managed-by" .Release.Service
  "app.kubernetes.io/part-of" (default (include "application.fullname" .) .Values.partOfOverride) -}}
{{- with include "application.version" . }}
{{- $_ := set $chart "app.kubernetes.io/version" . }}
{{- end }}
{{- with .Values.componentOverride }}
{{- $_ := set $chart "app.kubernetes.io/component" . }}
{{- end }}
{{- /* additionalLabels override the chart's labels, but never the selector labels. */}}
{{- $additional := include "application.tplvalues.render" (dict "value" .Values.additionalLabels "context" .) | fromYaml }}
{{- merge (include "application.selectorLabels" . | fromYaml) $additional $chart | toYaml }}
{{- end }}

{{/*
Common labels merged with resource-specific label maps, so each key appears once.
Later maps win.
Usage:
{{ include "application.labelsWith" (dict "context" $ "extra" (list .Values.service.additionalLabels)) }}
*/}}
{{- define "application.labelsWith" -}}
{{- $labels := include "application.labels" .context | fromYaml -}}
{{- range .extra -}}
{{- $labels = merge (deepCopy (default dict .)) $labels -}}
{{- end -}}
{{- toYaml $labels -}}
{{- end -}}

{{/*
Selector labels for the main workload. Job and CronJob pods override
app.kubernetes.io/name so the Service and PDB never select them.
*/}}
{{- define "application.selectorLabels" -}}
app.kubernetes.io/name: {{ include "application.fullname" . | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end }}

{{/*
Allow the release namespace to be overridden
*/}}
{{- define "application.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride -}}
{{- end -}}

{{/*
Service account used by every pod and role binding: the chart-created one, an
existing one named in serviceAccount.name, or the namespace default.
*/}}
{{- define "application.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- default (include "application.fullname" .) .Values.serviceAccount.name -}}
{{- else -}}
{{- default "default" .Values.serviceAccount.name -}}
{{- end -}}
{{- end -}}

{{/*
Workload kind: Deployment, StatefulSet or DaemonSet (enforced by values.schema.json).
*/}}
{{- define "application.workloadKind" -}}
{{- default "Deployment" .Values.workload.kind -}}
{{- end -}}

{{/*
Name of the PVC the workload mounts: an existing claim, persistence.name or <fullname>-data.
*/}}
{{- define "application.pvcName" -}}
{{- with .Values.persistence -}}
{{- default (printf "%s-data" (include "application.fullname" $)) (default .name .existingClaim) -}}
{{- end -}}
{{- end -}}

{{/*
PVC spec shared by the standalone PVC and StatefulSet volumeClaimTemplates.
*/}}
{{- define "application.pvcSpec" -}}
{{- with .Values.persistence -}}
accessModes:
  - {{ required "persistence.accessMode is required" .accessMode | quote }}
resources:
  requests:
    storage: {{ required "persistence.storageSize is required" .storageSize | quote }}
{{- if not (kindIs "invalid" .storageClass) }}
storageClassName: {{ eq "-" .storageClass | ternary "" .storageClass | quote }}
{{- end }}
{{- with .volumeMode }}
volumeMode: {{ . | quote }}
{{- end }}
{{- with .volumeName }}
volumeName: {{ . | quote }}
{{- end }}
{{- end -}}
{{- end -}}

{{/*
Full name of a Job or CronJob. Fails when it is too long, because truncating
could give two jobs the same name.
Usage:
{{ include "application.jobName" (dict "name" $name "job" $job "max" 52 "context" $) }}
*/}}
{{- define "application.jobName" -}}
{{- $fullName := printf "%s-%s" (include "application.fullname" .context) .name -}}
{{- $max := int .max -}}
{{- /* An Indexed Job names its pods <job>-<index>, so leave room for the largest index. */}}
{{- if eq (toString .job.completionMode) "Indexed" -}}
  {{- $max = sub $max (add 1 (len (toString (sub (max 1 (int .job.completions)) 1)))) -}}
{{- end -}}
{{- if gt (len $fullName) (int $max) -}}
{{- fail (printf "Job name %q has %d characters, the limit is %d: shorten the job key or fullnameOverride" $fullName (len $fullName) (int $max)) -}}
{{- end -}}
{{- $fullName -}}
{{- end -}}

{{/*
Pod spec shared by the workload, Jobs and CronJobs.
"pod" is the values map (.Values.workload or one job), "name" the app container name.
"volumeMounts", "volumeDevices" and "volumes" are chart-managed entries placed before the user's.
Usage:
{{ include "application.podSpec" (dict "pod" .Values.workload "name" $name "context" $) }}
*/}}
{{- define "application.podSpec" -}}
{{- $ := .context -}}
{{- $pod := .pod -}}
{{- $name := .name -}}
{{- $volumeDevices := .volumeDevices -}}
{{- /* A job with no containerSecurityContext uses the workload's, so every container shares one default. */}}
{{- $securityContext := $pod.containerSecurityContext -}}
{{- if kindIs "invalid" $securityContext -}}
  {{- $securityContext = $.Values.workload.containerSecurityContext -}}
{{- end -}}
{{- $mounts := default list .volumeMounts -}}
{{- $volumes := default list .volumes -}}
{{- /* The default root filesystem is read-only, so mount an emptyDir at /tmp unless the user mounts /tmp. */}}
{{- $writableTmp := kindIs "invalid" $pod.writableTmp | ternary true $pod.writableTmp -}}
{{- range $mount := $pod.volumeMounts -}}
  {{- if eq (toString (default dict $mount).mountPath) "/tmp" -}}
    {{- $writableTmp = false -}}
  {{- end -}}
{{- end -}}
{{- $tmpMount := dict -}}
{{- if $writableTmp -}}
  {{- $tmpMount = dict "name" "writable-tmp" "mountPath" "/tmp" -}}
  {{- $mounts = append $mounts $tmpMount -}}
  {{- $volumes = append $volumes (dict "name" "writable-tmp" "emptyDir" dict) -}}
{{- end -}}
serviceAccountName: {{ include "application.serviceAccountName" $ | quote }}
{{- with default .restartPolicy $pod.restartPolicy }}
restartPolicy: {{ . }}
{{- end }}
{{- include "application.fields" (dict "from" $pod "indent" 0 "names" (list
  "automountServiceAccountToken" "enableServiceLinks" "hostAliases" "hostNetwork" "hostPID"
  "shareProcessNamespace" "dnsPolicy" "dnsConfig" "nodeSelector" "priorityClassName"
  "runtimeClassName" "tolerations" "affinity" "topologySpreadConstraints"
  "securityContext" "terminationGracePeriodSeconds")) }}
{{- with $pod.imagePullSecrets }}
imagePullSecrets:
  {{- include "application.tplvalues.render" (dict "value" . "context" $) | nindent 0 }}
{{- end }}
{{- with $pod.initContainers }}
initContainers:
  {{- include "application.namedList" (dict "value" . "securityContext" $securityContext "volumeMount" $tmpMount "context" $) | nindent 0 }}
{{- end }}
containers:
- name: {{ $name | quote }}
  image: {{ include "application.image" (dict "image" $pod.image "name" $name "context" $) | quote }}
  {{- with $pod.image.pullPolicy }}
  imagePullPolicy: {{ . }}
  {{- end }}
  {{- range $field := list "command" "args" "envFrom" }}
  {{- with get $pod $field }}
  {{ $field }}:
    {{- include "application.tplvalues.render" (dict "value" . "context" $) | nindent 2 }}
  {{- end }}
  {{- end }}
  {{- with $pod.env }}
  env:
    {{- include "application.namedList" (dict "value" . "context" $) | nindent 2 }}
  {{- end }}
  {{- include "application.fields" (dict "from" $pod "indent" 2 "names" (list
    "workingDir" "ports" "startupProbe" "livenessProbe" "readinessProbe" "lifecycle" "resources")) }}
  {{- with $securityContext }}
  securityContext:
    {{- toYaml . | nindent 4 }}
  {{- end }}
  {{- if or $mounts $pod.volumeMounts }}
  volumeMounts:
    {{- with $mounts }}
    {{- toYaml . | nindent 2 }}
    {{- end }}
    {{- with $pod.volumeMounts }}
    {{- include "application.namedList" (dict "value" . "context" $) | nindent 2 }}
    {{- end }}
  {{- end }}
  {{- with $volumeDevices }}
  volumeDevices:
    {{- toYaml . | nindent 2 }}
  {{- end }}
{{- with $pod.additionalContainers }}
  {{- include "application.namedList" (dict "value" . "securityContext" $securityContext "volumeMount" $tmpMount "context" $) | nindent 0 }}
{{- end }}
{{- if or $volumes $pod.volumes }}
volumes:
  {{- with $volumes }}
  {{- toYaml . | nindent 0 }}
  {{- end }}
  {{- with $pod.volumes }}
  {{- include "application.namedList" (dict "value" . "context" $) | nindent 0 }}
  {{- end }}
{{- end }}
{{- end -}}

{{/*
Job spec shared by Job and CronJob. Pods carry neither the chart label nor the workload's
version label, so neither a chart bump nor a workload image bump changes the pod template.
podLabels can't replace the name and instance labels, which the NetworkPolicy selects on.
Usage:
{{ include "application.jobSpec" (dict "name" $fullName "job" $job "context" $) }}
*/}}
{{- define "application.jobSpec" -}}
{{- $ := .context -}}
{{- $job := .job -}}
{{- $labels := include "application.labelsWith" (dict "context" $ "extra" (list $job.podLabels (dict "app.kubernetes.io/name" .name "app.kubernetes.io/instance" $.Release.Name))) | fromYaml -}}
{{- /* Kubernetes accepts a podFailurePolicy only with restartPolicy Never. */}}
{{- $restartPolicy := empty $job.podFailurePolicy | ternary "OnFailure" "Never" -}}
template:
  metadata:
    labels:
      {{- omit $labels "helm.sh/chart" "app.kubernetes.io/version" | toYaml | nindent 6 }}
    {{- with $job.podAnnotations }}
    annotations:
      {{- toYaml . | nindent 6 }}
    {{- end }}
  spec:
    {{- include "application.podSpec" (dict "pod" $job "name" .name "restartPolicy" $restartPolicy "context" $) | nindent 4 }}
{{- include "application.fields" (dict "from" $job "indent" 0 "names" (list
  "activeDeadlineSeconds" "backoffLimit" "completionMode" "completions" "parallelism"
  "podFailurePolicy" "ttlSecondsAfterFinished")) }}
{{- end -}}
