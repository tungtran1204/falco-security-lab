#!/usr/bin/env bash
set -euo pipefail

TEST=det-012-test
RULE="Kubectl Executed in Container"

kubectl delete pod "$TEST" --ignore-not-found
kubectl apply -f manifests/test-pods/det-012.yaml
kubectl wait --for=condition=Ready pod/"$TEST" --timeout=120s

kubectl exec "$TEST" -- kubectl version --client

sleep 2

mkdir -p evidence/det-012

kubectl logs -n falco -l app.kubernetes.io/name=falco -c falco \
  --since=2m --prefix |
  grep "\"rule\":\"$RULE\"" |
  grep '"k8s.pod.name":"det-012-test"' \
  > evidence/det-012/falco-alert.log

cat evidence/det-012/falco-alert.log
