{{/*
Datadog config helpers
*/}}
{{- define "aionv2.datadog.baseEnvVars" -}}
- name: DD_ENV
  value: {{ .Values.global.faros.environment }}
- name: DD_AGENT_ENABLED
  value: "{{ .Values.global.datadog.enabled }}"
- name: DD_TRACE_ENABLED
  value: "{{ .Values.global.datadog.enabled }}"
- name: DD_RUNTIME_METRICS_ENABLED
  value: "{{ .Values.global.datadog.enabled }}"
{{- if .Values.DDServiceName }}
- name: DD_SERVICE
  value: {{ .Values.DDServiceName | quote }}
{{- end -}}
{{- if .Values.global.datadog.enabled }}
- name: DD_AGENT_HOST
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
- name: DD_TRACE_AGENT_URL
  value: "http://$(DD_AGENT_HOST):{{ .Values.global.datadog.agent.port }}"
- name: DD_DOGSTATSD_PORT
  value: {{ .Values.global.datadog.statsd.port | quote }}
{{- end -}}
{{- end -}}

{{- define "faros-ai.farosNodeOptions" -}}
{{- $traceGC :=  "" -}}
{{- $ddTrace := "" -}}
{{- if .Values.global.faros.nodeJs.GCLoggingEnabled -}}
{{- $traceGC =  "--trace_gc" }}
{{- end -}}
{{- if .Values.global.datadog.enabled -}}
{{- $ddTrace = "--require dd-trace/init" -}}
{{- end -}}
{{- printf "%s %s" $ddTrace $traceGC | trim -}}
{{- end -}}
