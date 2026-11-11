---
name: helm
description: >-
  Writes, reviews and validates Helm charts in this repo, chiefly the generic `charts/application` chart. Use when adding or changing a template, a value, the values schema, a unit test or a CI fixture, when reviewing a chart change, or when checking a chart against Helm's chart best practices. Don't use for installing third-party charts into a cluster or for debugging a running workload that the chart didn't cause.
---

# Helm charts

Read only the reference that matches the task. The references are Helm's chart best practices guide, copied unchanged.

| Task | Reference |
|---|---|
| Chart names, versions, YAML formatting, namespaces | [conventions.md](references/conventions.md) |
| Naming, typing, nesting and documenting values | [values.md](references/values.md) |
| Template files, defined template names, whitespace, comments | [templates.md](references/templates.md) |
| Standard labels, label or annotation | [labels.md](references/labels.md) |
| Images, pull policy, selectors on pod templates | [pods.md](references/pods.md) |
| Shipping CRDs, or resources that use a CRD | [custom_resource_definitions.md](references/custom_resource_definitions.md) |
| ServiceAccount and RBAC values and helpers | [rbac.md](references/rbac.md) |

## Rules that catch most defects

- Prefix every defined template with the chart name: `application.labels`, never `labels`.
- Put the selector labels (`app.kubernetes.io/name` and `app.kubernetes.io/instance`) in every workload selector. Never let user labels override them, because a selector can't change after install.
- Keep anything that changes per release, such as the version label or `helm.sh/chart`, out of selectors and out of immutable fields like StatefulSet `volumeClaimTemplates`.
- Quote strings that Kubernetes requires as strings: label values, annotation values, env values, ConfigMap data. Helm reads every number in a values file as a float, so `toString` turns `10485760` into `1.048576e+07`. Use `toJson` for numbers.
- Test optional numbers and booleans with `kindIs "invalid"`, not `if` or `with`, so `0` and `false` still render.
- Use template comments (`{{- /* */}}`) for notes about template code. A YAML comment that contains `required` still runs it.
- Use a fixed image tag or a digest. Never `latest`.

## Conventions in `charts/application`

The chart renders native Kubernetes objects and the Gateway API `HTTPRoute`. Every resource from another CRD goes in `extraObjects`, and `values.yaml` has a commented example for each. Ingress is not supported.

The chart departs from the guide in three places, on purpose:

- Templates set `metadata.namespace` from the `application.namespace` helper, so `namespaceOverride` works.
- `env`, `initContainers`, `extraContainers`, `volumes` and `volumeMounts` accept a list as well as a map, because order matters for init containers and for `$(VAR)` references.
- Value docs use the helm-docs `# --` form, not a comment that starts with the value name.

Other rules for this chart:

- Value names follow the argo-helm charts: `nameOverride` and `fullnameOverride`, `labels` inside a resource block, `extraContainers`, `image.imagePullPolicy`, `serviceAccount.create` and `networkPolicy.create`. Only the top-level labels value is called `additionalLabels`.
- `ci/` holds `default-values.yaml` and one small `<feature>-values.yaml` per feature. Each file must install on a cluster that has only the Gateway API CRDs, under any release name. A feature that needs a controller or another CRD gets a commented example in `values.yaml` instead of a fixture.
- `unittests/` holds one helm-unittest suite per template, named `<template>_test.yaml`.
- `README.md` is generated. Edit `README.md.gotmpl` or the comments in `values.yaml`, then run `helm-docs --chart-search-root charts/application`.
- `application.podSpec` renders the pod of the workload and of every Job and CronJob. Add a new pod field to its `application.fields` list, and to the pod properties of `workload`, `job` and `cronJob` in the schema.
- `application.serviceAccountName` is the one source of truth for the account name.
- Add every new value to `values.yaml`, with a comment, and to `values.schema.json`. The schema sets `additionalProperties: false`, so a value that is missing from it fails `helm lint`.
- Put a validation rule in the schema when the schema can express it. Use `fail` in a template only for a rule that depends on more than one value.
- `tpl` renders `extraObjects` and ConfigMap values. Escape template syntax meant for another tool as ``{{`{{ $labels.instance }}`}}``.
- Every pull request that changes a file in `charts/application` bumps `version` in `Chart.yaml`: a patch for a fix, a minor for a new feature, a major for a breaking change. `ct lint` fails the pull request otherwise. When it merges, `.github/workflows/release.yml` publishes the new version to GitHub Pages with chart-releaser.
- Treat a change to a selector, a resource name or an immutable field as a breaking change.

## Validate a change

Run the checks from the repo root, in this order:

1. Run the unit tests: `helm unittest --strict -f 'unittests/**/*.yaml' charts/application`.
2. Lint the chart and render every fixture: `helm lint charts/application`, then `helm template test charts/application -f charts/application/ci/<fixture>.yaml` for each file in `charts/application/ci/`.
3. Run what the pull request workflow (`.github/workflows/lint-and-test.yml`) runs: `ct lint --config .github/configs/ct.yaml --lint-conf .github/configs/lintconf.yaml`. It lints the chart with every fixture and runs the unit tests.
4. If a test cluster is available, run a strict server dry-run of each fixture: `helm template <name> charts/application -n <namespace> -f charts/application/ci/<fixture>.yaml | kubectl apply --dry-run=server --validate=strict -n <namespace> -f -`.

For a bug fix, add a test in `charts/application/unittests/` that fails before the fix. For a new feature, add a fixture to `charts/application/ci/`.
