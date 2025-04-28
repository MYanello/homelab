# test-chart

test

This repository contains a Helm chart that deploys the nginx Helm chart, version latest.

## Installation

```bash
helm dependency update .
helm install ${{ parameters.component_id }} . -n myanello-dev