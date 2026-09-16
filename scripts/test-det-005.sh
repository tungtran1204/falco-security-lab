#!/usr/bin/env bash
set -euo pipefail

TEST=det-005-test

kubectl delete pod "$TEST" --ignore-not-found
kubectl apply -f manifests/test-pods/det-005.yaml
kubectl wait --for=condition=Ready pod/"$TEST" --timeout=120s

kubectl exec "$TEST" -- python3 --version
kubectl exec "$TEST" -- python3 -c 'print("DET-005 Falco test")'

sleep 2

mkdir -p evidence/det-005
kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco \
  --since=2m --prefix |
  grep '"k8s.pod.name":"det-005-test"' \
  > evidence/det-005/falco-alert.log

cat evidence/det-005/falco-alert.log
