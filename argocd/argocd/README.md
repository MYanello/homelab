## Sops Key
k create secret generic sops-age -n argocd --from-literal=key.txt=${KEY}
