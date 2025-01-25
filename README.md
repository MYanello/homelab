This is my attempt to move my homelab from manual deployed using mostly docker compose and manual editing of a handful of config files, to a more modern gitops approach.
The k8s cluster is a picocluster 3 node cluster with raspberry pi 4 4gbs, then there is a consumer desktop running a amd 5900x and quadro rtx 4000 that is used for specific workloads.

Bootstrapping is done by running the ansible playbook to set up k3s, then the terraform to set up argocd and other core components.

## Worklog

### 01.24.25
- Got the first app migrated off docker compose to k8s: ytdl. This will likely be the first app to be fully migrated because it is the simplest in terms of configuration and state.
  - No crazy issues, kompose seemed to do a decent job if not perfect.
  - Scaled down to allow the copy from the docker folder to nfs folder to complete

### 01.23.25

- Authentik login is now working after telling ingress-nginx that it should use the forwarded headers from haproxy since it isn't on the edge
- Ran some further tests with the ingress and haproxy on the edge. Found that my private/public map files worked just as well for k8s endpoints. I simply need to point the subdomain such as bitwarden to k8s as the backend instead of to bitwarden as the backend. This is a good solution because it allows me to use the same haproxy config setup for both k8s and non-k8s services and will allow me to slowly migrate away from using the bad haproxy ui in opnsense for configuration of my routes.

### 01.22.25

- Got the nvidia container runtime working in the server. Secret trick was `runtimeClassName: nvidia` in the pod spec
- Also learned that k3s uses the containerd config in /var/lib/rancher/k3s/agent/etc/containerd/config.toml

### 01.20.25

- Worked on authentik secrets and config
  - Found that . separators in yaml isn't valid for helm
  - Found that helm chart dependencies have their own values that can be overridden and have to be investigated independently
  - PSQL wasn't being recreated on deletion. Found it was because it kept reusing the same PV.

### 01.19.25

- Installed the nvidia gpu operator
  - Had to install cuda drivers and container toolkit on the host
  - Had a bug for the containerd config version that required installing the latest version of container toolkit
- Got vault working with a ton of manual steps that aren't gitops'd yet
  - [source](https://developer.hashicorp.com/vault/tutorials/kubernetes/kubernetes-minikube-raft#install-the-vault-helm-chart)
  - To unseal the vault, run
    `export VAULT_UNSEAL_KEY=$(jq -r ".unseal_keys_b64[]" cluster-keys.json); kubectl exec -it vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY`
  - Sops encrypted the cluster secret using my ssh key converted to an age key and stored in ~/.config/age/keys.txt
  - Decided vault may be a bit heavy for my needs. Going to investigate ksops
- Installed ksops in argocd-repo-server
  - main manual thing was just adding the age key as a secret in the argocd namespace and applying the ksops-patch.yaml
    `kubectl patch deployment argocd-repo-server -n argocd --patch-file ksops-patch.yaml --type strategic`
  - needed to split authentik app up because argocd expects if there is a kustomization.yaml that that handles everything so the helm chart wasn't deploying

### 01.18.25

- Moved the argocd core components that needed to be `k apply`d to terraform
- Add server as a worker node but taint it so it doesn't run any workloads unless specified
  - This removes the metallb speaker pod from the node
    - This is desirable because the speaker pod should be on the same nodes as what haproxy passes traffic to for the k8s subdomain
    - If it needed to change we could aadd speaker.nodeSelector.metallbSpeakerEnabled to the metallb helm values and then add the nodelabel to the nodes that should run the speaker

### 01.12.25

- ingress-nginx setup. there is also nginx-ingress but ingress-nginx is preferred
- ingress working at k8s.yanello.net
  - setup haproxy to point anything with the host header ending in k8s.yanello.net to forward to the nginx ingress controller
  - need to update the cert SAN to allow \*.k8s.yanello.net

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
