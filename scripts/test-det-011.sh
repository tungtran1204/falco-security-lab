#!/usr/bin/env bash
set -euo pipefail

TEST=det-011-test
RULE="Host Proc or Sys Access from Container"

kubectl delete pod "$TEST" --ignore-not-found
kubectl apply -f manifests/test-pods/det-011.yaml
kubectl wait --for=condition=Ready pod/"$TEST" --timeout=120s

kubectl exec "$TEST" -- cat /host/proc/1/status >/dev/null

sleep 2

mkdir -p evidence/det-011

kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco \
  --since=2m --prefix |
  grep "\"rule\":\"$RULE\"" \
  > evidence/det-011/falco-alert.log

cat evidence/det-011/falco-alert.log
