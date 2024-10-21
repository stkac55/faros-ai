# airbyte

![Version: 0.63.3](https://img.shields.io/badge/Version-0.63.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.63.3](https://img.shields.io/badge/AppVersion-0.63.3-informational?style=flat-square)

Faros Airbyte Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://airbytehq.github.io/helm-charts | airbyte(airbyte) | 0.242.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| airbyte.airbyte-api-server.enabled | bool | `true` |  |
| airbyte.airbyte-api-server.image.repository | string | `"airbyte/airbyte-api-server"` |  |
| airbyte.airbyte-bootloader.image.repository | string | `"airbyte/bootloader"` |  |
| airbyte.connector-builder-server.enabled | bool | `false` |  |
| airbyte.connector-builder-server.image.repository | string | `"airbyte/connector-builder-server"` |  |
| airbyte.cron.image.repository | string | `"airbyte/cron"` |  |
| airbyte.fullnameOverride | string | `""` | String to fully override airbyte.fullname template with a string |
| airbyte.keycloak-setup.enabled | bool | `false` |  |
| airbyte.keycloak.enabled | bool | `false` |  |
| airbyte.metrics.enabled | bool | `false` |  |
| airbyte.metrics.image.repository | string | `"airbyte/metrics-reporter"` |  |
| airbyte.minio.enabled | bool | `true` |  |
| airbyte.minio.image.repository | string | `"minio/minio"` | Minio image used by Minio helm chart |
| airbyte.minio.image.tag | string | `"RELEASE.2023-11-20T22-40-07Z"` | Minio tag image |
| airbyte.nameOverride | string | `""` | String to partially override airbyte.fullname template with a string (will prepend the release name) |
| airbyte.pod-sweeper.image.repository | string | `"bitnami/kubectl"` |  |
| airbyte.postgresql.enabled | bool | `true` |  |
| airbyte.server.image.repository | string | `"airbyte/server"` |  |
| airbyte.server.log.level | string | `"DEBUG"` |  |
| airbyte.serviceAccount.annotations | object | `{}` | Annotations for service account. Evaluated as a template. Only used if `create` is `true`. |
| airbyte.serviceAccount.create | bool | `true` | Specifies whether a ServiceAccount should be created |
| airbyte.serviceAccount.name | string | `"airbyte-admin"` | Name of the service account to use. If not set and create is true, a name is generated using the fullname template. |
| airbyte.temporal.enabled | bool | `true` |  |
| airbyte.temporal.env_vars.LOG_LEVEL | string | `"info"` |  |
| airbyte.temporal.extraEnv[0].name | string | `"POSTGRES_TLS_ENABLED"` |  |
| airbyte.temporal.extraEnv[0].value | string | `"true"` |  |
| airbyte.temporal.extraEnv[1].name | string | `"POSTGRES_TLS_DISABLE_HOST_VERIFICATION"` |  |
| airbyte.temporal.extraEnv[1].value | string | `"true"` |  |
| airbyte.temporal.extraEnv[2].name | string | `"SQL_TLS_ENABLED"` |  |
| airbyte.temporal.extraEnv[2].value | string | `"true"` |  |
| airbyte.temporal.extraEnv[3].name | string | `"SQL_TLS_DISABLE_HOST_VERIFICATION"` |  |
| airbyte.temporal.extraEnv[3].value | string | `"true"` |  |
| airbyte.temporal.image.repository | string | `"temporalio/auto-setup"` |  |
| airbyte.webapp.env_vars.CONNECTOR_BUILDER_API_HOST | string | `"localhost"` |  |
| airbyte.webapp.image.repository | string | `"airbyte/webapp"` |  |
| airbyte.webapp.log.level | string | `"DEBUG"` |  |
| airbyte.worker.env_vars.CONTAINER_ORCHESTRATOR_IMAGE | string | `"airbyte/container-orchestrator:0.63.3"` |  |
| airbyte.worker.env_vars.SYNC_JOB_MAX_ATTEMPTS | string | `"2"` |  |
| airbyte.worker.env_vars.SYNC_JOB_MAX_TIMEOUT_DAYS | string | `"1"` |  |
| airbyte.worker.image.repository | string | `"airbyte/worker"` |  |
| airbyte.workload-api-server.enabled | bool | `false` |  |
| airbyte.workload-launcher.enabled | bool | `false` |  |
| global.database | object | `{"type":"internal"}` | Database configuration |
| global.deploymentMode | string | `"oss"` | Deployment mode, whether or not render the default env vars and volumes in deployment spec |
| global.edition | string | `"community"` | Edition; "community" or "pro" |
| global.env_vars | object | `{}` |  |
| global.jobs.kube.annotations | object | `{}` | key/value annotations applied to kube jobs |
| global.jobs.kube.images.busybox | string | `"busybox:1.35"` |  |
| global.jobs.kube.images.curl | string | `"curlimages/curl:7.87.0"` |  |
| global.jobs.kube.images.socat | string | `"alpine/socat:1.7.4.4-r0"` |  |
| global.jobs.kube.labels | object | `{}` | key/value labels applied to kube jobs |
| global.jobs.kube.main_container_image_pull_secret | string | `""` | image pull secret to use for job pod |
| global.jobs.kube.nodeSelector | object | `{}` | Node labels for pod assignment |
| global.jobs.kube.tolerations | list | `[]` | Node tolerations for pod assignment  Any boolean values should be quoted to ensure the value is passed through as a string. |
| global.jobs.resources.limits | object | `{}` | Job resource limits |
| global.jobs.resources.requests | object | `{}` | Job resource requests |
| global.serviceAccountName | string | `"airbyte-admin"` | Service Account name override |
| global.storage.type | string | `"minio"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
