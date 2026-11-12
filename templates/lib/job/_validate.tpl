{{/*
Validate job values
*/}}
{{- define "stack.lib.job.validate" -}}
  {{- $rootContext := .rootContext -}}
  {{- $jobValues := .object -}}

  {{- $allowedRestartPolicy := list "Never" "OnFailure" -}}
  {{- if not (has $jobValues.pod.restartPolicy $allowedRestartPolicy) -}}
    {{- fail (printf "Job: Invalid restartPolicy '%s'. Valid options are 'Never' or 'OnFailure'. Specify a valid restartPolicy under 'job.pod.restartPolicy'." $jobValues.pod.restartPolicy) -}}
  {{- end -}}
{{- end -}}
