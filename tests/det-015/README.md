# DET-015 - Executable File Created or Modified in Container

## Giải thích
Phát hiện việc tạo hoặc sửa executable trong thư mục binary của container; test bằng cách tạo /usr/local/bin/det-015, cấp quyền executable và kiểm tra Falco sinh alert.


## Objective
Detect creation or modification of executable files in system binary directories inside a container.

## Rule
Executable File Created or Modified in Container

## Preconditions
- Falco is running on the Kubernetes node.
- Custom DET-015 rule is loaded.
- det-015-test pod can be created.

## Trigger
The test creates an executable file:
/usr/local/bin/det-015

## Execute
Run:
./scripts/test-det-015.sh

## Expected Result
Falco generates:
Executable File Created or Modified in Container

The alert contains Kubernetes workload and process metadata.

## Evidence
evidence/det-015/falco-alert.log

## Cleanup
The test pod is deleted by the test script.

## Result
PASS
