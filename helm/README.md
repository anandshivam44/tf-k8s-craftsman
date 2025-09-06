# Helm Chart for node-app

This document describes how to install, upgrade, and uninstall the `node-app` Helm chart.

## Prerequisites

- Kubernetes cluster
- Helm 3 installed

## Installing the Chart

To install the chart with the release name `my-release`:

```bash
helm install my-release .
```

To install the chart in a specific namespace, for example `my-namespace`:

```bash
helm install my-release . --namespace my-namespace --create-namespace
```

## Upgrading the Chart

To upgrade the release `my-release`:

```bash
helm upgrade my-release .
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```bash
helm uninstall my-release
```

## Other Useful Commands

### Linting the Chart

To lint the chart and check for possible issues:

```bash
helm lint .
```

### Dry Run Installation

To perform a dry run of the installation and see the generated Kubernetes manifests:

```bash
helm install my-release . --dry-run --debug
```

### Templating the Chart

To render the templates locally and see the output:

```bash
helm template my-release .
```

### Checking Release Status

To check the status of a deployed release:

```bash
helm status my-release
```

### Viewing Release History

To view the history of a release:

```bash
helm history my-release
```

### Rolling Back a Release

To roll back a release to a previous version (e.g., revision 1):

```bash
helm rollback my-release 1
```

### Getting Release Values

To get the values for a deployed release:

```bash
helm get values my-release
```
