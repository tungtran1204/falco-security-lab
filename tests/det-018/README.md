# DET-018 - Reverse Shell Network Connection

## Giải thích
Phát hiện dấu hiệu reverse shell thông qua Bash /dev/tcp/; test bằng cách cho Bash mở TCP socket tới 10.96.0.1:443 và kiểm tra rule kích hoạt. Đây là mô phỏng chỉ dấu reverse shell, không tạo reverse shell tương tác thực tế.


## Objective
Detect bash TCP socket usage that can indicate reverse-shell behavior inside a container.

## Rule
Reverse Shell Network Connection

## Preconditions
- Falco is running on the Kubernetes node.
- Custom DET-018 rule is loaded.
- det-018-test pod can be created.

## Trigger
The controlled test executes bash using:
/dev/tcp/10.96.0.1/443

This scenario generates the expected Falco runtime signal without establishing a persistent interactive reverse shell.

## Execute
Run:
./scripts/test-det-018.sh

## Expected Result
Falco generates:
Reverse Shell Network Connection

Expected metadata includes:
- process=bash
- Kubernetes namespace and pod
- command containing /dev/tcp/

## Evidence
evidence/det-018/falco-alert.log

## Known Limitation
In the validated event, fd.name was empty and fd.rport was unavailable.
Detection therefore relies on the bash command line containing /dev/tcp/.

## Cleanup
The test pod is deleted by the test script.

## Result
PASS
