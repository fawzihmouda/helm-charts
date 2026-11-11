# application

A generic Helm chart that deploys one application: a Deployment, StatefulSet or DaemonSet, with optional Jobs and CronJobs.

The chart renders core Kubernetes resources and the Gateway API `HTTPRoute`. It needs no cluster add-on. `values.yaml` documents every value, and `values.schema.json` rejects a value the chart doesn't know.

## Install a release

The image repository is the only required value. Resources take the release name unless `fullnameOverride` is set.

```bash
helm install my-app charts/application \
  --set workload.image.repository=ghcr.io/example/my-app \
  --set workload.image.tag=1.0.0
```

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

Put the manifest in `extraObjects`. Use it for a second Service, HTTPRoute or PVC, and for any resource from a third-party CRD, such as an ExternalSecret or a ServiceMonitor. Each entry goes through `tpl` and gets the chart's labels. `values.yaml` has an example for each common CRD.

## Check a change

Run the three checks from the repository root.

```bash
helm lint charts/application
```

```bash
helm unittest charts/application
```

```bash
for f in charts/application/ci/*.yaml; do helm template test charts/application -f "$f" > /dev/null || echo "FAILED $f"; done
```
