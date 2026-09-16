#!/usr/bin/env bash
set -euo pipefail

TEST=det-004-test

kubectl delete pod "$TEST" --ignore-not-found
kubectl apply -f manifests/test-pods/det-004.yaml
kubectl wait --for=condition=Ready pod/"$TEST" --timeout=120s

kubectl exec "$TEST" -- apt --version
kubectl exec "$TEST" -- apt-get --version

sleep 2

mkdir -p evidence/det-004
kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco \
  --since=2m --prefix |
  grep '"k8s.pod.name":"det-004-test"' \
  > evidence/det-004/falco-alert.log

cat evidence/det-004/falco-alert.log
