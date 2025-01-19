This is my attempt to move my homelab from manual deployed using mostly docker compose and manual editing of a handful of config files, to a more modern gitops approach.
The k8s cluster is a picocluster 3 node cluster with raspberry pi 4 4gbs, then there is a consumer desktop running a amd 5900x and quadro rtx 4000 that is used for specific workloads.

Bootstrapping is done by running the ansible playbook to set up k3s, then the terraform to set up argocd and other core components.

## Worklog
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