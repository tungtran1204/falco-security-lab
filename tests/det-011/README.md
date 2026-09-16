# DET-011 - Host Proc or Sys Access

## Objective
Detect unusual access to host /proc or /sys from inside a container.

## Test command
kubectl exec det-011-test -- cat /host/proc/1/status

## Expected result
- Rule: Host Proc or Sys Access from Container
- Priority: WARNING
- File: /host/proc/1/status
- Pod: det-011-test
- Tag: det-011

## Tuning
Longhorn legitimately accesses /host/proc frequently.
Namespace longhorn-system is excluded to reduce false positives.

## Evidence
../../evidence/det-011/falco-alert.log

## Result
PASS

## Cleanup
kubectl delete pod det-011-test
