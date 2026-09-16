# DET-007 - Mounted Application Secret Read

## Giải thích
Phát hiện việc đọc secret hoặc credential được mount vào container; test bằng cách mount secret vào /etc/app-secrets/ rồi đọc file secret và kiểm tra Falco sinh alert.


## Objective
Detect a container reading an application secret mounted as a Kubernetes Secret volume.

## Preconditions
- Falco is running.
- DET-007 custom rule is loaded.
- Secret `det-007-secret` is mounted at `/etc/app-secrets/`.
- Test pod `det-007-test` is running.

## Test command
kubectl exec det-007-test -- sh -c \
'cat /etc/app-secrets/password >/dev/null'

## Expected result
Falco generates:
- Rule: Mounted Application Secret Read
- Priority: WARNING
- Tag: det-007
- Pod: det-007-test
- File: /etc/app-secrets/password

## Evidence
../../evidence/det-007/falco-alert.log

## Result
PASS

## Cleanup
kubectl delete pod det-007-test
kubectl delete secret det-007-secret
