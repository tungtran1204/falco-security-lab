# DET-017 - Outbound Connection

## Giải thích
Phát hiện kết nối TCP outbound từ workload; test bằng cách tạo kết nối từ pod tới Kubernetes API 10.96.0.1:443 và kiểm tra Falco ghi nhận event connect.


## Scenario
Detect an outbound network connection initiated from a container.

## Rule
`rules/det-017-outbound-connection.yaml`

## Test
Connect from the test workload to the Kubernetes API Service on TCP/443.

## Expected result
Falco triggers `Outbound Connection from Container`.

## Evidence
`evidence/det-017/falco-alert.log`
