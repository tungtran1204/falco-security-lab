#!/usr/bin/env bash
set -euo pipefail

TEST=det-007-test

kubectl delete pod "$TEST" --ignore-not-found
kubectl delete secret det-007-secret --ignore-not-found

kubectl apply -f manifests/test-pods/det-007.yaml
kubectl wait --for=condition=Ready pod/"$TEST" --timeout=120s

kubectl exec "$TEST" -- sh -c \
  'cat /etc/app-secrets/password >/dev/null'

sleep 2

mkdir -p evidence/det-007
kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco \
  --since=2m --prefix |
  grep '"k8s.pod.name":"det-007-test"' \
  > evidence/det-007/falco-alert.log

cat evidence/det-007/falco-alert.log
