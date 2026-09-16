# DET-009 - Suspicious Namespace Operation

## Giải thích
Phát hiện các syscall namespace đáng ngờ như setns hoặc unshare; test bằng container có SYS_ADMIN và chạy unshare --user để tạo tín hiệu cho Falco.


## Objective
Detect suspicious Linux namespace manipulation inside a container.

## Test command
kubectl exec det-009-test -- unshare --user /bin/true

## Expected result
- Rule: Suspicious Namespace Operation in Container
- Priority: WARNING
- Process: unshare
- Tag: det-009
- Pod: det-009-test

## Evidence
../../evidence/det-009/falco-alert.log

## Result
PASS

## Note
The broad rule also generates legitimate alerts from Longhorn workloads.
Production tuning/allowlisting is required.

## Cleanup
kubectl delete pod det-009-test
