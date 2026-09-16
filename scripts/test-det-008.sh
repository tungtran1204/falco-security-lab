#!/usr/bin/env bash
set -euo pipefail

TEST=det-008-test

kubectl delete pod "$TEST" --ignore-not-found
kubectl apply -f manifests/test-pods/det-008.yaml
kubectl wait --for=condition=Ready pod/"$TEST" --timeout=120s

kubectl exec "$TEST" -- \
  setpriv --reuid=1000 --regid=1000 --clear-groups id

sleep 2

mkdir -p evidence/det-008
kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco \
  --since=2m --prefix |
  grep '"k8s.pod.name":"det-008-test"' \
  > evidence/det-008/falco-alert.log

cat evidence/det-008/falco-alert.log
