This is my attempt to move my homelab from manual deployed using mostly docker compose and manual editing of a handful of config files, to a more modern gitops approach.
The k8s cluster is a picocluster 3 node cluster with raspberry pi 4 4gbs.

## Worklog
### 01.12.25
- ingress-nginx setup. there is also nginx-ingress but ingress-nginx is preferred
- ingress working at k8s.yanello.net
    - setup haproxy to point anything with the host header ending in k8s.yanello.net to forward to the nginx ingress controller
    - need to update the cert SAN to allow *.k8s.yanello.net

### 01.11.25
- Metallb assigning IP addresses to services
- Metallb set to advertise routes to opnsense
- Opnsense configured to use bgp and advertising the received routes
- Able to reach argocd from the external ip set by metallb

With opnsense running a virtual ip and haproxy load balancer there, the metallb load balancer isn't exactly necessary. However, it is good practice and exposure to setting up BGP.

### 01.10.25
- Argocd applicationset to deploy applications in the repo

### 01.09.25
- Ansible configured to set up k3s cluster
- Ansible configured to set up argocd