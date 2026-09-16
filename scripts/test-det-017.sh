#!/bin/bash
set -euo pipefail

POD=det-017-test
NS=default
RULE="Contact K8S API Server From Container"

mkdir -p evidence/det-017
: > evidence/det-017/falco-alert.log

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null

kubectl apply -f manifests/test-pods/det-017.yaml
kubectl wait --for=condition=Ready pod/"$POD" -n "$NS" --timeout=120s

NODE=$(kubectl get pod "$POD" -n "$NS" -o jsonpath='{.spec.nodeName}')

FALCO_POD=$(kubectl get pod -n falco \
  -l app.kubernetes.io/instance=falco,app.kubernetes.io/name=falco \
  --field-selector spec.nodeName="$NODE" \
  -o jsonpath='{.items[0].metadata.name}')

API_IP=$(kubectl get svc kubernetes -n default \
  -o jsonpath='{.spec.clusterIP}')

echo "[+] Test pod node: $NODE"
echo "[+] Falco pod: $FALCO_POD"
echo "[+] Trigger DET-017 -> ${API_IP}:443"

# Ghi lại thời điểm ngay trước trigger
START=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

kubectl exec -n "$NS" "$POD" -- \
  bash -c "exec 3<>/dev/tcp/${API_IP}/443; exec 3>&-" || true

sleep 2

echo "[+] Collect evidence"

kubectl logs -n falco "$FALCO_POD" -c falco \
  --since-time="$START" 2>/dev/null \
  | grep '"rule":"Contact K8S API Server From Container"' \
  | grep '"k8s.pod.name":"det-017-test"' \
  > evidence/det-017/falco-alert.log || true

cat evidence/det-017/falco-alert.log

if [ -s evidence/det-017/falco-alert.log ]; then
    echo "[PASS] DET-017"
else
    echo "[FAIL] DET-017"

    echo
    echo "=== DEBUG: events from det-017-test ==="

    kubectl logs -n falco "$FALCO_POD" -c falco \
      --since-time="$START" 2>/dev/null \
      | grep 'det-017-test' \
      | tail -n 10 || true

    exit 1
fi

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null
