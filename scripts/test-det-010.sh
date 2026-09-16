#!/usr/bin/env bash
set -euo pipefail

TEST=det-010-test

kubectl delete pod "$TEST" --ignore-not-found
kubectl apply -f manifests/test-pods/det-010.yaml
kubectl wait --for=condition=Ready pod/"$TEST" --timeout=120s

kubectl exec "$TEST" -- sh -c \
  'test -S /run/containerd/containerd.sock && echo "containerd socket found"'

kubectl exec "$TEST" -- sh -c \
  'timeout 1 cat /run/containerd/containerd.sock >/dev/null 2>&1 || true'

sleep 2

mkdir -p evidence/det-010

kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco \
  --since=2m --prefix |
  grep '"rule":"Container Runtime Socket Access"' \
  > evidence/det-010/falco-alert.log

cat evidence/det-010/falco-alert.log
