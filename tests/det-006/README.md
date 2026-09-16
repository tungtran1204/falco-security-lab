# DET-006 - Kubernetes Service Account Token Read

## Objective
Detect a container reading its Kubernetes service-account token.

## Preconditions
- Falco is running.
- DET-006 custom rule is loaded.
- Test pod has a service-account token mounted.

## Test command
kubectl exec det-006-test -- sh -c \
'cat /var/run/secrets/kubernetes.io/serviceaccount/token >/dev/null'

## Expected result
Falco generates:
- Rule: Kubernetes Service Account Token Read
- Priority: WARNING
- Tag: det-006
- Pod: det-006-test

## Evidence
../../evidence/det-006/falco-alert.log

## Result
PASS
