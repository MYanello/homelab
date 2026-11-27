#!/usr/bin/env bash

sops_yaml_files=(
  ../../ansible/oracle_free/group_vars/oracle_free.sops.yaml
  ../../ansible/vault/group_vars/vault.sops.yaml
  ../../terraform/authentik/sops/authentik.enc.yaml
  ../../terraform/oci/sops/oci.enc.yaml
  ../../terraform/vault/sops/oci.enc.yaml
)

sops_pem_files=(
  ../../terraform/oci/sops/vault-autounseal-private.enc.pem
  ../../terraform/oci/sops/vault-autounseal-public.enc.pem
  ../../terraform/vault/sops/vault-autounseal-private.enc.pem
  ../../terraform/vault/sops/vault-autounseal-public.enc.pem
)

for sops_file in "${sops_yaml_files[@]}"; do
  sops updatekeys "$sops_file"
done

for sops_file in "${sops_pem_files[@]}"; do
  sops updatekeys --input-type binary "$sops_file"
done

