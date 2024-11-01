# aionapi

![Version: 1.0.6](https://img.shields.io/badge/Version-1.0.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 874521a](https://img.shields.io/badge/AppVersion-874521a-informational?style=flat-square)

Helm chart for Faros Aion service

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | aionServiceDb(postgresql) | 12.2.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| DDServiceName | string | `"aion-api"` |  |
| affinity | object | `{}` |  |
| aionServiceDb.auth.database | string | `"aiondb"` |  |
| aionServiceDb.auth.enablePostgresUser | bool | `true` |  |
| aionServiceDb.auth.password | string | `"aion"` |  |
| aionServiceDb.auth.postgresPassword | string | `"admin"` |  |
| aionServiceDb.auth.username | string | `"aion"` |  |
| aionServiceDb.enabled | bool | `true` |  |
| aionServiceDb.image.tag | string | `"14.7.0"` |  |
| aionServiceDb.nameOverride | string | `"aion-service-db"` |  |
| aionServiceDb.primary.containerSecurityContext.enabled | bool | `false` |  |
| aionServiceDb.primary.podSecurityContext.enabled | bool | `false` |  |
| aionServiceDb.tls.autoGenerated | bool | `true` |  |
| aionServiceDb.tls.enabled | bool | `true` |  |
| aionServiceDb.volumePermissions.enabled | bool | `true` |  |
| autoscaling.enabled | bool | `false` |  |
| autoscaling.maxReplicas | int | `3` |  |
| autoscaling.minReplicas | int | `1` |  |
| autoscaling.targetCPUUtilizationPercentage | int | `80` |  |
| dbName | string | `"aion-service-db"` |  |
| externalDb.database | string | `nil` |  |
| externalDb.host | string | `nil` |  |
| externalDb.password | string | `nil` |  |
| externalDb.port | int | `5432` |  |
| externalDb.username | string | `nil` |  |
| fullnameOverride | string | `""` |  |
| global.datadog.url | string | `"https://api.datadoghq.com"` |  |
| global.faros.nodeJs.GCLoggingEnabled | bool | `false` |  |
| global.postgresql.service.ports.postgresql | string | `"5432"` |  |
| global.temporal.host | string | `"NOT_DEFINED"` |  |
| global.temporal.port | string | `"7233"` |  |
| global.temporal.tls | string | `"true"` |  |
| image.pullPolicy | string | `"IfNotPresent"` |  |
| image.repository | string | `"farosai/aion-api"` |  |
| image.tag | string | `"874521afef64d5e1e3366d7fdea6e947db0a01fd"` |  |
| imagePullSecrets[0].name | string | `"dockerhub"` |  |
| ingress.annotations | object | `{}` |  |
| ingress.className | string | `""` |  |
| ingress.enabled | bool | `false` |  |
| ingress.hosts[0].host | string | `"aion.local"` |  |
| ingress.hosts[0].paths[0].path | string | `"/"` |  |
| ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| ingress.tls | list | `[]` |  |
| jwt.publicKey | string | `"NOT_DEFINED"` |  |
| nameOverride | string | `""` |  |
| nodeSelector | object | `{}` |  |
| podAnnotations | object | `{}` |  |
| podSecurityContext | object | `{}` |  |
| replicaCount | int | `1` |  |
| resources | object | `{}` |  |
| securityContext.capabilities.drop[0] | string | `"ALL"` |  |
| securityContext.readOnlyRootFilesystem | bool | `false` |  |
| securityContext.runAsNonRoot | bool | `true` |  |
| securityContext.runAsUser | int | `1000` |  |
| service.port | int | `8080` |  |
| service.targetPort | int | `8080` |  |
| service.type | string | `"ClusterIP"` |  |
| serviceAccount.annotations | object | `{}` |  |
| serviceAccount.create | bool | `true` |  |
| serviceAccount.name | string | `""` |  |
| tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
