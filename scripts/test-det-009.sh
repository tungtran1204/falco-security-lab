#!/usr/bin/env bash
set -euo pipefail

TEST=det-009-test

kubectl delete pod "$TEST" --ignore-not-found
kubectl apply -f manifests/test-pods/det-009.yaml
kubectl wait --for=condition=Ready pod/"$TEST" --timeout=120s

kubectl exec "$TEST" -- unshare --user /bin/true

sleep 2

mkdir -p evidence/det-009
kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco \
  --since=2m --prefix |
  grep '"k8s.pod.name":"det-009-test"' \
  > evidence/det-009/falco-alert.log

cat evidence/det-009/falco-alert.log
