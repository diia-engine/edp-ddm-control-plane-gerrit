{{- define "portal.default.host" }}
{{- $root := .root }}
{{- $portalName := .portalName }}
{{- printf "%s-%s.%s" $portalName $root.Values.stageName $root.Values.dnsWildcard }}
{{- end }}

{{- define "officer-portal.url" -}}
{{ $host := ternary .Values.portals.officer.customDns.host (include "portal.default.host" (dict  "root" . "portalName" "officer-portal")) .Values.portals.officer.customDns.enabled }}
{{- $host }}
{{- end }}

{{- define "citizen-portal.url" -}}
{{ $host := ternary .Values.portals.citizen.customDns.host (include "portal.default.host" (dict  "root" . "portalName" "citizen-portal")) .Values.portals.citizen.customDns.enabled }}
{{- $host }}
{{- end }}

{{- define "notifications.diia.url" -}}
{{- regexReplaceAll "http(s?)://" .Values.global.notifications.diia.url "${2}" | replace "/" "" | default "api2t.diia.gov.ua" }}
{{- end }}

{{- define "externalS3.enabled" -}}
{{- if and (hasKey .Values "global") (hasKey .Values.global "externalS3") (hasKey .Values.global.externalS3 "endpoint") (hasKey .Values.global.externalS3 "buckets") (gt (len .Values.global.externalS3.buckets) 0) .Values.global.externalS3.endpoint -}}
true
{{- else -}}
false
{{- end -}}
{{- end -}}

{{- define "externalS3.endpoint" -}}
{{- if eq (include "externalS3.enabled" .) "true" -}}
{{- $ep := .Values.global.externalS3.endpoint | trim -}}
{{- if not (hasPrefix "https://" $ep) -}}
  {{- fail (printf "global.externalS3.endpoint must start with https://, got: %s" $ep) -}}
{{- end -}}
{{- $ep -}}
{{- end -}}
{{- end -}}

{{- define "externalS3.authority" -}}
{{- if eq (include "externalS3.enabled" .) "true" -}}
{{- $ep := include "externalS3.endpoint" . -}}
{{- if $ep -}}
{{- $trim := trimPrefix "https://" (trimPrefix "http://" $ep) -}}
{{- regexFind "^[^/]+" $trim -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "externalS3.host" -}}
{{- if eq (include "externalS3.enabled" .) "true" -}}
{{- $auth := include "externalS3.authority" . -}}
{{- if $auth -}}
{{- index (splitList ":" $auth) 0 -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "externalS3.port" -}}
{{- if eq (include "externalS3.enabled" .) "true" -}}
{{- $auth := include "externalS3.authority" . -}}
{{- if $auth -}}
{{- $portMatch := regexFind ":\\d+$" $auth -}}
{{- if $portMatch -}}
{{- trimPrefix ":" $portMatch | int -}}
{{- else -}}
443
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "externalS3.caSecretRef" -}}
{{- if and (hasKey .Values "global") (hasKey .Values.global "externalS3") (hasKey .Values.global.externalS3 "caSecretRef") -}}
{{- .Values.global.externalS3.caSecretRef -}}
{{- else -}}
{{- "" -}}
{{- end -}}
{{- end -}}
