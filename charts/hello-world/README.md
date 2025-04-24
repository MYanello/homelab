# hello-world

A test helm chart

This repository contains a Helm chart that deploys the hello-world Helm chart, version latest.

## Installation

```bash
helm dependency update .
helm install ${{ parameters.component_id }} . -n default