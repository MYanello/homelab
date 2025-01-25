Test cert is working and signed:
`openssl verify -CAfile <(kubectl -n cert-manager get secret local-root-ca-secret -o jsonpath='{.data.tls\.crt}' | base64 --decode) <(kubectl -n cert-manager get secret local-intermediate-ca1-secret -o jsonpath='{.data.tls\.crt}' | base64 --decode)`


# To get a cert for ingress
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