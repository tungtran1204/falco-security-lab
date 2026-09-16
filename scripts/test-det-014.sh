#!/bin/bash
set -euo pipefail

POD=det-014-test
NS=default
RULE="Cron Persistence File Created in Container"

mkdir -p evidence/det-014

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null
kubectl apply -f manifests/test-pods/det-014.yaml
kubectl wait --for=condition=Ready pod/"$POD" -n "$NS" --timeout=120s

echo "[+] Trigger DET-014"
kubectl exec -n "$NS" "$POD" -- \
  sh -c 'mkdir -p /etc/cron.d && echo "* * * * * root /bin/true" > /etc/cron.d/det-014'

sleep 3

echo "[+] Collect evidence"

for p in $(kubectl get pod -n falco \
  -l app.kubernetes.io/name=falco \
  -o jsonpath='{.items[*].metadata.name}'); do

  kubectl logs -n falco "$p" -c falco --since=2m 2>/dev/null || true

done | grep "$RULE" | grep "$POD" \
  > evidence/det-014/falco-alert.log || true

cat evidence/det-014/falco-alert.log

if [ -s evidence/det-014/falco-alert.log ]; then
    echo "[PASS] DET-014"
else
    echo "[FAIL] DET-014 - Falco alert not found"
    exit 1
fi

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null
