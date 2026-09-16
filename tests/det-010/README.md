# DET-010 - Container Runtime Socket Access

## Objective
Detect access to the host container runtime socket from inside a container.

## Preconditions
- Falco is running.
- DET-010 custom rule is loaded.
- Cluster runtime is containerd.
- `/run/containerd/containerd.sock` is mounted into the test pod.

## Test command
kubectl exec det-010-test -- sh -c \
'timeout 1 cat /run/containerd/containerd.sock >/dev/null 2>&1 || true'

## Expected result
- Rule: Container Runtime Socket Access
- Priority: WARNING
- Process: cat
- File: /run/containerd/containerd.sock
- Pod: det-010-test
- Tag: det-010

## Evidence
../../evidence/det-010/falco-alert.log

## Result
PASS

## Cleanup
kubectl delete pod det-010-test
