# DET-013 - Kubernetes Secret API Access

## Giải thích
Phát hiện truy cập Kubernetes Secrets API thông qua Kubernetes Audit; test bằng cách tạo và đọc một Secret rồi kiểm tra Falco nhận event từ nguồn k8s_audit.


## Scenario
Detect successful access to Kubernetes Secrets through the Kubernetes API.

## Event source
Kubernetes Audit -> Audit Webhook -> Falco k8saudit plugin.

## Components
- Falco 0.44.1
- k8saudit plugin 0.18.0
- json plugin 0.7.0
- k8saudit rules 0.18.0

## Test
Create a test Secret and retrieve it through kubectl.

## Expected result
Falco triggers `K8s Secret Get Successfully`.

## Evidence
`evidence/det-013/falco-alert.log`

## Result
PASS
