#!/bin/bash
set -euo pipefail

POD=det-018-test
NS=default
RULE="Reverse Shell Network Connection"

mkdir -p evidence/det-018
: > evidence/det-018/falco-alert.log

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null
kubectl apply -f manifests/test-pods/det-018.yaml
kubectl wait --for=condition=Ready pod/"$POD" -n "$NS" --timeout=120s

NODE=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.nodeName}')

FALCO_POD=$(kubectl get pod -n falco \
  -l app.kubernetes.io/instance=falco,app.kubernetes.io/name=falco \
  --field-selector spec.nodeName="$NODE" \
  -o jsonpath='{.items[0].metadata.name}')



echo "[+] Test pod node: $NODE"
echo "[+] Falco pod: $FALCO_POD"
echo "[+] Trigger DET-018"

START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

kubectl exec -n "$NS" "$POD" -- \
  bash -c "exec 3<>/dev/tcp/10.96.0.1/443; exec 3>&-" || true

sleep 2

echo "[+] Collect evidence"

kubectl logs -n falco "$FALCO_POD" -c falco \
  --since-time="$START" 2>/dev/null \
  | grep "\"rule\":\"$RULE\"" \
  | grep '"k8s.pod.name":"det-018-test"' \
  > evidence/det-018/falco-alert.log || true

cat evidence/det-018/falco-alert.log

if [ -s evidence/det-018/falco-alert.log ]; then
  echo "[PASS] DET-018"
else
  echo "[FAIL] DET-018"
  kubectl logs -n falco "$FALCO_POD" -c falco \
    --since-time="$START" 2>/dev/null \
    | grep 'det-018-test' | tail -n 10 || true
  exit 1
fi

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null
