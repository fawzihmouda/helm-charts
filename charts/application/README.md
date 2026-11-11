# application

A generic Helm chart that deploys one application: a Deployment, StatefulSet or DaemonSet, with optional Jobs and CronJobs.

The chart renders core Kubernetes resources and the Gateway API `HTTPRoute`. It needs no cluster add-on. `values.schema.json` rejects a value the chart doesn't know.

## Install a release

Add the chart repository, which GitHub Pages serves from the `gh-pages` branch.

```bash
helm repo add fawzihmouda https://fawzihmouda.github.io/helm-charts
```

The image repository is the only required value.

```bash
helm install my-app fawzihmouda/application \
  --set workload.image.repository=ghcr.io/example/my-app \
  --set workload.image.tag=1.0.0
```

Resources are named `<release name>-application`. A release name that contains `application` is used alone. To pick the name, set `fullnameOverride`. To replace `application` in the name and in the `app.kubernetes.io/name` label, set `nameOverride`.

The default container security context meets the Pod Security "restricted" profile: non-root, read-only root filesystem, no capabilities. An image whose user is a name, not a number, needs `workload.securityContext.runAsUser`. An image that must run as root needs `workload.containerSecurityContext` relaxed.

## Choose the workload

Set `workload.kind` to `Deployment`, `StatefulSet` or `DaemonSet`.

- A StatefulSet gets a headless Service named `<name>-headless`. With `persistence.enabled`, it also gets one PVC per pod.
- To run only Jobs or CronJobs, set `workload.enabled` to `false`.

Each entry of `job.jobs` and `cronJob.jobs` takes the same pod values as `workload`.

## Add the supporting resources

Each resource has its own block in `values.yaml`.

| Resource | Values |
|---|---|
| Service | `service` |
| HTTPRoute | `httpRoute` |
| ServiceAccount, Roles, ClusterRoles | `serviceAccount`, `rbac` |
| ConfigMaps, Secrets | `configMap`, `secret` |
| PersistentVolumeClaim | `persistence` |
| HorizontalPodAutoscaler | `autoscaling` |
| PodDisruptionBudget | `pdb` |
| NetworkPolicy | `networkPolicy` |

A change to a ConfigMap or Secret of the chart restarts the workload pods.

## Add a resource the chart doesn't model

Put the manifest in `extraObjects`. Use it for a second Service, HTTPRoute or PVC, and for any resource from a third-party CRD, such as an ExternalSecret or a ServiceMonitor. Each entry goes through `tpl`. The chart adds no labels to an entry. `values.yaml` has a commented example for each common CRD.

## Move from the earlier chart

Version 1.0.0 is the first release from this repository. It renames the values, resource names and selector labels of the earlier, unpublished chart. A selector can't change on a running workload, so uninstall a release of the earlier chart and install 1.0.0. To keep the data of a PVC, set the `helm.sh/resource-policy: keep` annotation on it before the uninstall.

| Earlier chart | 1.0.0 |
|---|---|
| `applicationName` | `fullnameOverride` |
| `deployment.*` | `workload.*` |
| `deployment.additionalContainers` | `workload.extraContainers` |
| `deployment.image.pullPolicy` | `workload.image.imagePullPolicy` |
| `deployment.reloadOnChange` | Removed. The chart restarts the pods when one of its ConfigMaps or Secrets changes. |
| `enabled` inside a probe | Removed. A probe that is set is rendered. |
| `additionalLabels` inside a resource block | `labels`. The top-level `additionalLabels` keeps its name. |
| `rbac.serviceAccount.enabled` | `serviceAccount.create`, now `true` by default |
| `rbac.enabled` | `rbac.create` |
| `configMap.files.<name>` | `configMap.items.<name>.data` |
| `secret.files.<name>` | `secret.items.<name>` |
| `networkPolicy.enabled` | `networkPolicy.create` |
| `serviceMonitor`, `prometheusRule`, `alertmanagerConfig`, `endpointMonitor`, `grafanaDashboard`, `certificate`, `externalSecret`, `vpa` | `extraObjects` |

## Check a change

Run the checks from the repository root.

```bash
helm lint charts/application
```

```bash
helm unittest --strict -f 'unittests/**/*.yaml' charts/application
```

```bash
for f in charts/application/ci/*.yaml; do helm template test charts/application -f "$f" > /dev/null || echo "FAILED $f"; done
```

`README.md` is generated from `README.md.gotmpl` and `values.yaml`. After a change to either file, generate it again.

```bash
helm-docs --chart-search-root charts/application
```

## Values

### Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalLabels | tpl/object | `{}` | Additional labels for all resources. |
| componentOverride | string | `""` | Override the component label for all resources. |
| extraObjects | list | `[]` | Extra manifests to deploy. Use this for any resource the chart doesn't model: a second Service, HTTPRoute or PVC, an ExternalName Service, or a resource from a third-party CRD. Each entry is an object or a string, rendered through tpl. Because of tpl, a literal `{{ }}` meant for another tool (Prometheus, Alertmanager, Grafana, ESO templates) must be escaped as '{{`{{ $labels.instance }}`}}'. Use the string form when a field takes rendered YAML, such as a label selector. An entry gets no labels from the chart and goes to the release namespace unless it sets its own. |
| fullnameOverride | string | the release name when it contains `nameOverride`, otherwise `<release name>-<nameOverride>` | Full name of every resource. A StatefulSet name must be at most 52 characters. |
| nameOverride | string | `application` | Name used in the `app.kubernetes.io/name` label and in the default resource name. |
| namespaceOverride | string | `""` | Override the namespace for all resources. |
| partOfOverride | string | `""` | Override the partOf label for all resources. |

### Autoscaling Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| autoscaling.annotations | object | `{}` | Annotations for the HPA. |
| autoscaling.behavior | object | `{}` | Scaling behaviour. |
| autoscaling.enabled | bool | `false` | Create a HorizontalPodAutoscaler. Not supported for a DaemonSet. |
| autoscaling.labels | object | `{}` | Additional labels for the HPA. |
| autoscaling.maxReplicas | int | `10` | Maximum number of replicas. |
| autoscaling.metrics | list | `[{"resource":{"name":"cpu","target":{"averageUtilization":80,"type":"Utilization"}},"type":"Resource"}]` | Metrics used for autoscaling. Utilization targets need `workload.resources.requests` for that resource. |
| autoscaling.minReplicas | int | `1` | Minimum number of replicas. |

### ConfigMap Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| configMap.annotations | object | `{}` | Annotations for the ConfigMaps. |
| configMap.enabled | bool | `false` | Deploy the ConfigMaps in `items`. |
| configMap.items | object | `{}` | Map of ConfigMaps. The key is the name suffix. `data` values go through tpl, so escape a literal `{{ }}` meant for another tool as '{{`{{ .Status }}`}}'. `binaryData` values are base64 strings. A change to a ConfigMap or Secret of the chart restarts the workload pods. An `immutable` ConfigMap or Secret can't change: an upgrade that changes its content fails, so add a new key to `items` instead. |
| configMap.labels | object | `{}` | Additional labels for the ConfigMaps. |

### CronJob Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cronJob.enabled | bool | `false` | Deploy CronJob resources. |
| cronJob.jobs | object | `{}` | Map of CronJobs. The key is the name suffix, the value is the CronJob. Each CronJob takes everything a `job.jobs` entry takes, plus the CronJob fields in the example. `schedule` is required. |

### HTTPRoute Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| httpRoute.annotations | object | `{}` | Annotations for the HTTPRoute. |
| httpRoute.enabled | bool | `false` | Create an HTTPRoute (Gateway API). |
| httpRoute.hostnames | tpl/list | `[]` | Hostnames of the route. |
| httpRoute.labels | object | `{}` | Additional labels for the HTTPRoute. |
| httpRoute.parentRefs | tpl/list | `[]` | Gateways the route attaches to. Required unless `useDefaultGateways` is set. |
| httpRoute.rules | tpl/list | `[]` | Rules of the route. When empty, all paths go to the first Service port. Ports must be numbers: a templated port renders as a quoted string, which the API rejects. |
| httpRoute.useDefaultGateways | string | `""` | Attach the route to the default Gateways: `All` or `None`. Needs the experimental channel of Gateway API. |

### Job Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| job.enabled | bool | `false` | Deploy Job resources. |
| job.jobs | object | `{}` | Map of Jobs. The key is the name suffix, the value is the Job. Each Job takes the pod values of `workload` (`image` is required), plus `labels`, `annotations`, `restartPolicy` (default `OnFailure`, or `Never` with a `podFailurePolicy`) and the Job fields in the example. The Job name ends in a hash of its spec. A Job's pod template can't change, so a change creates a new Job that runs again, and Helm deletes the old one. The pod template includes the chart-wide values `additionalLabels`, `partOfOverride`, `componentOverride`, `serviceAccount` and `workload.containerSecurityContext`, so a change to one of them runs every Job again. A Job with `suspend: true` never completes, so `helm install --wait` times out. Use `ttlSecondsAfterFinished` only on Helm hook Jobs: Helm recreates a missing Job, so a Job deleted by its TTL runs again on the next upgrade. Job pods get `app.kubernetes.io/name: <job name>`, so the Service never selects them. |

### NetworkPolicy Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| networkPolicy.annotations | object | `{}` | Annotations for the NetworkPolicy. |
| networkPolicy.create | bool | `false` | Create a NetworkPolicy for the workload, Job and CronJob pods. It selects the pods by release and name, so `podLabels` can't take a pod out of it. Needs `ingress` or `egress` to be set. |
| networkPolicy.egress | list | `nil` | Egress rules. Null leaves egress open. An empty list denies all egress, including DNS. |
| networkPolicy.ingress | list | `nil` | Ingress rules. Null leaves ingress open. An empty list denies all ingress. |
| networkPolicy.labels | object | `{}` | Additional labels for the NetworkPolicy. |

### PodDisruptionBudget Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| pdb.annotations | object | `{}` | Annotations for the PDB. |
| pdb.enabled | bool | `false` | Create a PodDisruptionBudget. Not supported for a DaemonSet. |
| pdb.labels | object | `{}` | Additional labels for the PDB. |
| pdb.maxUnavailable | int or string | `1` | Maximum number of pods that can be unavailable. Unlike `minAvailable: 1`, this doesn't block node drains for a single replica. |
| pdb.minAvailable | int or string | `nil` | Minimum number of pods that must stay available. When set, it replaces `maxUnavailable`. |
| pdb.unhealthyPodEvictionPolicy | string | `""` | `IfHealthyBudget` or `AlwaysAllow`: whether unhealthy pods can be evicted. |

### Persistence Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| persistence.accessMode | string | `"ReadWriteOnce"` | Access mode of the volume. A DaemonSet needs `ReadWriteMany`. |
| persistence.annotations | object | `{}` | Annotations for the PVC. |
| persistence.enabled | bool | `false` | Create a PVC, or one PVC per pod for a StatefulSet. A StatefulSet's PVCs are named `data-<pod name>`, and its claim templates can't change after install. Turning persistence on or off, or changing storageSize, storageClass, accessMode, volumeMode, volumeName, existingClaim, labels or annotations, needs `kubectl delete sts <name> --cascade=orphan` before the upgrade. Resize existing claims by editing the PVCs directly. |
| persistence.existingClaim | string | `""` | Use this existing PVC instead of creating one. |
| persistence.labels | object | `{}` | Additional labels for the PVC. |
| persistence.mountPVC | bool | `false` | Mount the volume in the app container. |
| persistence.mountPath | string | `"/data"` | Where `mountPVC` mounts the volume. |
| persistence.name | string | `{{ include "application.fullname" $ }}-data` | Name of the PVC the chart creates. Not used for a StatefulSet. |
| persistence.storageClass | string | `nil` | Storage class of the volume. If null (the default), use the cluster's default storage class. If set to "-" or "", disable dynamic provisioning. |
| persistence.storageSize | string | `"8Gi"` | Size of the volume. |
| persistence.volumeMode | string | `""` | Volume mode: `Filesystem` or `Block`. |
| persistence.volumeName | string | `""` | Bind the PVC to this PersistentVolume. |

### RBAC Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| rbac.annotations | object | `{}` | Annotations for the roles and bindings. |
| rbac.clusterRoles | list | `[]` | ClusterRoles, each bound to the pods' Service Account with a ClusterRoleBinding. Takes the same entries as `roles`. |
| rbac.create | bool | `true` | Create the roles in `roles` and `clusterRoles`, and their bindings. |
| rbac.labels | object | `{}` | Additional labels for the roles and bindings. |
| rbac.roles | list | `[]` | Namespaced Roles, each bound to the pods' Service Account. Needs `serviceAccount.create` or `serviceAccount.name`, so the roles never go to the `default` account. |
| serviceAccount.annotations | object | `{}` | Annotations for the Service Account. |
| serviceAccount.automountServiceAccountToken | bool | `true` | Let pods that use the Service Account mount its token. `workload.automountServiceAccountToken` overrides it for one pod. |
| serviceAccount.create | bool | `true` | Create a Service Account. All pods and role bindings use it. When false, pods use `name` if set (an existing account) or the namespace's `default` account. |
| serviceAccount.labels | object | `{}` | Additional labels for the Service Account. |
| serviceAccount.name | string | `{{ include "application.fullname" $ }}` when created, otherwise `default` | Service Account name. |

### Secret Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| secret.annotations | object | `{}` | Annotations for the Secrets. |
| secret.enabled | bool | `false` | Deploy the Secrets in `items`. |
| secret.items | object | `{}` | Map of Secrets. The key is the name suffix. There are three ways to give the content: `data` (the chart base64-encodes it), `encodedData` (already base64) and `stringData` (plain text, encoded by Kubernetes). `type` sets the Secret type, for example `kubernetes.io/dockerconfigjson`. |
| secret.labels | object | `{}` | Additional labels for the Secrets. |

### Service Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| service.annotations | tpl/object | `{}` | Annotations for the Service. |
| service.clusterIP | string | `""` | Fixed IP for the Service, or `None` for a headless Service. Can't change after install. |
| service.enabled | bool | `true` | Create a Service for the workload. |
| service.externalIPs | list | `[]` | External IPs routed to the Service. |
| service.externalTrafficPolicy | string | `""` | `Cluster` or `Local`, for NodePort and LoadBalancer Services. |
| service.internalTrafficPolicy | string | `""` | `Cluster` or `Local`, for traffic from inside the cluster. |
| service.ipFamilies | list | `[]` | IP families of the Service, such as `IPv4` and `IPv6`. |
| service.ipFamilyPolicy | string | `""` | `SingleStack`, `PreferDualStack` or `RequireDualStack`. |
| service.labels | object | `{}` | Additional labels for the Service. |
| service.loadBalancerClass | string | `""` | Load balancer class, for LoadBalancer Services. |
| service.loadBalancerIP | string | `""` | Deprecated in Kubernetes. Requested IP, for LoadBalancer Services. |
| service.loadBalancerSourceRanges | list | `[]` | Allowed client CIDRs, for LoadBalancer Services. |
| service.ports | list | `[{"name":"http","port":8080,"protocol":"TCP","targetPort":8080}]` | Ports of the Service. |
| service.publishNotReadyAddresses | bool | `false` | Publish pod addresses before the pods are ready. |
| service.sessionAffinity | string | `""` | `None` or `ClientIP`. |
| service.sessionAffinityConfig | object | `{}` | Session affinity settings. |
| service.type | string | `"ClusterIP"` | Type of Service: `ClusterIP`, `NodePort` or `LoadBalancer`. |

### Workload Parameters

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| workload.affinity | object | `{}` | Affinity rules of the pod. |
| workload.annotations | object | `{}` | Annotations for the workload. |
| workload.args | tpl/list | `[]` | Args for the app container. |
| workload.automountServiceAccountToken | bool | `true` | Mount the Service Account token. |
| workload.command | tpl/list | `[]` | Command for the app container. |
| workload.containerSecurityContext | object | `{"allowPrivilegeEscalation":false,"capabilities":{"drop":["ALL"]},"readOnlyRootFilesystem":true,"runAsNonRoot":true,"seccompProfile":{"type":"RuntimeDefault"}}` | Security context of the containers. The default meets the Pod Security "restricted" profile. Images that must run as root or write outside mounted volumes need this relaxed. A value set here replaces the whole default, it doesn't merge with it. To run as a fixed user, keep the default and set `securityContext.runAsUser`. An image whose user is a name, not a number, needs that. It is also the default for Job and CronJob containers, and for every init container and additional container that sets no `securityContext`. |
| workload.dnsConfig | object | `{}` | DNS config of the pod. |
| workload.dnsPolicy | string | `""` | DNS policy of the pod. |
| workload.enableServiceLinks | bool | `true` | Inject the namespace's Services as environment variables. |
| workload.enabled | bool | `true` | Deploy the long-running workload. |
| workload.env | tpl/list or object | `nil` | Environment variables for the app container. A `$(VAR)` reference only resolves if VAR comes earlier, so use a list when order matters. A map is keyed by variable name and sorted alphabetically. |
| workload.envFrom | tpl/list | `[]` | Kubernetes `envFrom` entries for the app container. |
| workload.extraContainers | tpl/list or object | `nil` | Containers that run beside the app container. A map is keyed by container name. |
| workload.hostAliases | list | `[]` | Entries added to the pod's hosts file. |
| workload.hostNetwork | bool | `false` | Use the node's network namespace. Set `dnsPolicy` to `ClusterFirstWithHostNet` to keep resolving cluster Service names. |
| workload.hostPID | bool | `false` | Use the node's process ID namespace. |
| workload.image.digest | tpl/string | `""` | Image digest, such as `sha256:...`. When set with a tag, the image is pulled by digest. |
| workload.image.imagePullPolicy | string | `"IfNotPresent"` | Image pull policy. |
| workload.image.repository | tpl/string | `""` | Image repository. Required. |
| workload.image.tag | tpl/string | `""` | Image tag. Also sets the `app.kubernetes.io/version` label. |
| workload.imagePullSecrets | tpl/list | `[]` | List of secrets used to pull the images. |
| workload.initContainers | tpl/list or object | `nil` | Init containers. They run in order, so use a list when order matters. A map is keyed by container name and sorted alphabetically. For a native sidecar, add an init container with `restartPolicy: Always`. |
| workload.kind | string | `"Deployment"` | Workload kind: `Deployment`, `StatefulSet` or `DaemonSet`. A StatefulSet gets one PVC per pod when `persistence.enabled` is true, and a headless Service named `<name>-headless` for per-pod DNS. Changing between Deployment and StatefulSet with persistence removes the PVC of the old kind, and the new kind starts with empty volumes. To keep the data, set `persistence.annotations` to `helm.sh/resource-policy: keep` first. |
| workload.labels | object | `{}` | Additional labels for the workload. |
| workload.lifecycle | object | `{}` | Lifecycle hooks of the app container. |
| workload.livenessProbe | object | `{}` | Liveness probe, as a Kubernetes probe. |
| workload.minReadySeconds | int | `nil` | Seconds a new pod must be ready before it counts as available. |
| workload.nodeSelector | object | `{}` | Node labels the pod needs. |
| workload.persistentVolumeClaimRetentionPolicy | object | `{}` | StatefulSet only: what happens to the PVCs when the StatefulSet is deleted or scaled down. |
| workload.podAnnotations | object | `{}` | Additional pod annotations. |
| workload.podLabels | object | `{}` | Additional pod labels. Not used in selectors. |
| workload.podManagementPolicy | string | `""` | StatefulSet only: `OrderedReady` or `Parallel`. Can't change after install. |
| workload.ports | list | `[]` | Ports of the app container. |
| workload.priorityClassName | string | `""` | Priority class of the pod. |
| workload.progressDeadlineSeconds | int | `nil` | Deployment only: seconds before a stalled rollout is reported as failed. |
| workload.readinessProbe | object | `{}` | Readiness probe, as a Kubernetes probe. |
| workload.replicas | int | `nil` | Number of replicas. Ignored for a DaemonSet or when autoscaling is enabled. Enabling autoscaling on a running release drops the field, so Kubernetes briefly scales to 1 until the HPA restores minReplicas. Turning autoscaling off with no `replicas` set keeps the last replica count. |
| workload.resources | object | `{}` | Resource requests and limits of the app container. |
| workload.revisionHistoryLimit | int | `2` | Number of old revisions to keep. |
| workload.runtimeClassName | string | `""` | Runtime class of the pod. |
| workload.securityContext | object | `{}` | Security context of the pod. |
| workload.shareProcessNamespace | bool | `false` | Share one process namespace between the pod's containers. |
| workload.startupProbe | object | `{}` | Startup probe, as a Kubernetes probe. |
| workload.strategy | object | `{}` | Update strategy. Rendered as `strategy` for a Deployment and `updateStrategy` for a StatefulSet or DaemonSet. When `type` is empty, the chart uses RollingUpdate, or Recreate for a Deployment that mounts a ReadWriteOnce(Pod) PVC, because the new pod can't attach the volume while the old pod holds it. A RollingUpdate renders every `rollingUpdate` field, with the Kubernetes default for each field not set here. Helm then owns the fields and can remove them when `type` changes. |
| workload.terminationGracePeriodSeconds | int | `nil` | Seconds a pod gets to stop before it is killed. |
| workload.tolerations | list | `[]` | Taints the pod tolerates. |
| workload.topologySpreadConstraints | list | `[]` | Topology spread constraints of the pod. |
| workload.volumeMounts | tpl/list or object | `nil` | Volume mounts of the app container. A map is keyed by volume name. Use a list to mount one volume more than once. |
| workload.volumes | tpl/list or object | `nil` | Volumes of the pod. A map is keyed by volume name. |
| workload.workingDir | string | `""` | Working directory of the app container. |
| workload.writableTmp | bool | `true` | Mount an emptyDir at /tmp in the app container, since the default root filesystem is read-only. Skipped when `volumeMounts` already mounts something at /tmp. An init container or additional container that sets no `securityContext` gets the same mount, unless it mounts /tmp itself. |
