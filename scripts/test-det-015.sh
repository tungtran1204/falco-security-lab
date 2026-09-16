#!/bin/bash
set -euo pipefail

POD=det-015-test
NS=default
RULE="Executable File Created or Modified in Container"

mkdir -p evidence/det-015

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null
kubectl apply -f manifests/test-pods/det-015.yaml
kubectl wait --for=condition=Ready pod/"$POD" -n "$NS" --timeout=120s

echo "[+] Trigger DET-015"
kubectl exec -n "$NS" "$POD" -- \
  sh -c 'printf "#!/bin/sh\necho det-015\n" > /usr/local/bin/det-015 && chmod +x /usr/local/bin/det-015'

sleep 3

echo "[+] Collect evidence"

for p in $(kubectl get pod -n falco \
  -l app.kubernetes.io/name=falco \
  -o jsonpath='{.items[*].metadata.name}'); do
  kubectl logs -n falco "$p" -c falco --since=2m 2>/dev/null || true
done | grep "$RULE" | grep "$POD" \
  > evidence/det-015/falco-alert.log || true

cat evidence/det-015/falco-alert.log

if [ -s evidence/det-015/falco-alert.log ]; then
  echo "[PASS] DET-015"
else
  echo "[FAIL] DET-015 - Falco alert not found"
  exit 1
fi

kubectl delete pod "$POD" -n "$NS" --ignore-not-found=true >/dev/null
