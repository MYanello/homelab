https://raymii.org/s/tutorials/nameConstraints_on_your_Self_Signed_Root_CA_in_Kubernetes_with_cert_manager.html
https://raymii.org/s/tutorials/Self_signed_Root_CA_in_Kubernetes_with_k3s_cert-manager_and_traefik.html

Test cert is working and signed:
`openssl verify -CAfile <(kubectl -n cert-manager get secret local-root-ca-secret -o jsonpath='{.data.tls\.crt}' | base64 --decode) <(kubectl -n cert-manager get secret local-intermediate-ca1-secret -o jsonpath='{.data.tls\.crt}' | base64 --decode)`

To get the root ca for installing on devices
`kubectl -n cert-manager get secret local-root-ca-secret -o jsonpath='{.data.tls\.crt}' | base64 -d > root-ca.crt`
Can copy that to /usr/local/www on opnsense to download it from opn.yanell.net/root-ca.crt

# To get a cert for ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: echo-ingress
  namespace: cert-manager
  annotations:
    cert-manager.io/cluster-issuer: local-intermediate-ca1-issuer
    cert-manager.io/common-name: "echo.k3s.homelab.mydomain.org"
spec:
  ingressClassName: nginx
  rules:
  - host: echo.k3s.homelab.mydomain.org
    http:
      paths:
        - pathType: Prefix
          path: "/"
          backend:
            service:
              name: echo-service
              port:
                number: 80
  tls:
  - hosts:
    - echo.k3s.homelab.mydomain.org
      secretName: echo-cert-secret
```