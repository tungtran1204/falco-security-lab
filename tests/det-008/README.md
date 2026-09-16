# DET-008 - Setuid / Privilege Change

## Objective
Detect UID/GID identity changes inside a running container.

## Preconditions
- Falco is running.
- DET-008 custom rule is loaded.
- Test pod `det-008-test` is running.

## Test command
kubectl exec det-008-test -- \
  setpriv --reuid=1000 --regid=1000 --clear-groups id

## Expected result
Falco generates:
- Rule: Setuid or Setgid Executed in Container
- Priority: WARNING
- Tag: det-008
- Process: setpriv
- Pod: det-008-test

## Evidence
../../evidence/det-008/falco-alert.log

## Result
PASS

## Cleanup
kubectl delete pod det-008-test
