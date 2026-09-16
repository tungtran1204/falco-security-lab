#!/usr/bin/env bash
set -euo pipefail

TEST=det-006-test

kubectl delete pod "$TEST" --ignore-not-found
kubectl apply -f manifests/test-pods/det-006.yaml
kubectl wait --for=condition=Ready pod/"$TEST" --timeout=120s

kubectl exec "$TEST" -- sh -c \
  'cat /var/run/secrets/kubernetes.io/serviceaccount/token >/dev/null'

sleep 2

mkdir -p evidence/det-006
kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco \
  --since=2m --prefix |
  grep '"k8s.pod.name":"det-006-test"' \
  > evidence/det-006/falco-alert.log

cat evidence/det-006/falco-alert.log
