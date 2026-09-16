#!/bin/bash
set -euo pipefail

POD=det-016-test
NS=default
RULE="Discovery Tool Executed in Container"

mkdir -p evidence/det-016

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null
kubectl apply -f manifests/test-pods/det-016.yaml
kubectl wait --for=condition=Ready pod/"$POD" -n "$NS" --timeout=120s

echo "[+] Trigger DET-016"
kubectl exec -n "$NS" "$POD" -- ps aux >/dev/null

sleep 3

echo "[+] Collect evidence"

for p in $(kubectl get pod -n falco \
  -l app.kubernetes.io/name=falco \
  -o jsonpath='{.items[*].metadata.name}'); do
  kubectl logs -n falco "$p" -c falco --since=2m 2>/dev/null || true
done | grep "$RULE" | grep "$POD" \
  > evidence/det-016/falco-alert.log || true

cat evidence/det-016/falco-alert.log

if [ -s evidence/det-016/falco-alert.log ]; then
  echo "[PASS] DET-016"
else
  echo "[FAIL] DET-016 - Falco alert not found"
  exit 1
fi

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null
