{{/*
Validate CronJob values
*/}}
{{- define "stack.lib.cronjob.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $cronjobValues := .object -}}

  {{- if and (ne $cronjobValues.pod.restartPolicy "Never") (ne $cronjobValues.pod.restartPolicy "OnFailure") -}}
    {{- fail (printf "CronJob: Invalid restartPolicy '%s'. Valid options are 'Never' or 'OnFailure'. Specify a valid restartPolicy under 'cronjob.pod.restartPolicy'." $cronjobValues.pod.restartPolicy) }}
  {{- end -}}
{{- end -}}
