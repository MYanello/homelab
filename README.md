This is my attempt to move my homelab from manual deployed using mostly docker compose and manual editing of a handful of config files, to a more modern gitops approach.
The k8s cluster is a picocluster 3 node cluster with raspberry pi 4 4gbs.

## Worklog
### 01.11.25
- Metallb assigning IP addresses to services
- Metallb set to advertise routes to opnsense
- Opnsense configured to use bgp and advertising the received routes
- Able to reach argocd from the external ip set by metallb

### 01.10.25
- Argocd applicationset to deploy applications in the repo

### 01.09.25
- Ansible configured to set up k3s cluster
- Ansible configured to set up argocd