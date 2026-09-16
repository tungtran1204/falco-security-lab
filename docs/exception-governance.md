# FALCO-006 Exception Governance

## 1. Purpose

Định nghĩa quy trình quản lý exception và allowlist cho Falco detection rules.

Mục tiêu là giảm false positive/noise nhưng không làm mất detection coverage
do exclusion quá rộng hoặc không được kiểm soát.

---

## 2. Governance Principles

Mỗi exception phải:

- Có rule cụ thể.
- Có legitimate activity được xác minh.
- Có phạm vi nhỏ nhất có thể.
- Có lý do nghiệp vụ/kỹ thuật.
- Có owner.
- Có người phê duyệt.
- Có evidence.
- Có thời hạn hoặc ngày review.
- Được validate sau khi áp dụng.

Không disable toàn bộ rule chỉ để xử lý noise nếu có thể sử dụng exception
có phạm vi nhỏ hơn.

---

## 3. Exception Lifecycle

Exception lifecycle:

    REQUEST
       |
       v
    REVIEW
       |
       v
    APPROVE
       |
       v
    APPLY
       |
       v
    VALIDATE
       |
       v
    ACTIVE
       |
       +----> REVIEW / RENEW
       |
       +----> EXPIRE / REMOVE

### REQUEST

Xác định:

- Falco rule
- nguồn alert
- legitimate activity
- workload/namespace/process liên quan
- evidence

### REVIEW

Đánh giá:

- activity có thực sự hợp lệ hay không
- exception có làm mất detection coverage hay không
- có thể thu hẹp scope hơn không

### APPROVE

Exception phải có owner và approver trước khi đưa vào production baseline.

### APPLY

Ưu tiên exception theo:

1. process/process lineage
2. workload/container/image
3. namespace + workload
4. namespace

Không ưu tiên exclusion toàn namespace nếu có thể giới hạn nhỏ hơn.

### VALIDATE

Sau khi apply:

- legitimate noise phải giảm
- attack/test scenario vẫn phải trigger
- lưu evidence trước/sau tuning

### EXPIRE / REVIEW

Exception phải được review khi:

- workload thay đổi
- image/version thay đổi
- Falco/rule version thay đổi
- exception hết hạn
- detection regression xảy ra

---

## 4. Exception Record

Mỗi exception sử dụng record:

| Field | Description |
|---|---|
| Exception ID | ID duy nhất |
| Falco Rule | Rule được tuning |
| Reason | Lý do exception |
| Namespace | Namespace áp dụng |
| Workload/Image | Workload hoặc image |
| Process | Process/process lineage nếu có |
| Evidence | Runtime evidence |
| Owner | Owner của workload |
| Approver | Người phê duyệt |
| Created | Ngày tạo |
| Expiry/Review | Ngày hết hạn hoặc review |
| Status | REQUESTED/APPROVED/ACTIVE/EXPIRED/REJECTED |

---

## 5. Current Exception Candidates

Các candidate được xác định từ FALCO-005 runtime qualification:

| Rule | Candidate Scope | Reason | Decision |
|---|---|---|---|
| Suspicious Namespace Operation in Container | longhorn-system / Longhorn manager | Legitimate Longhorn namespace operations | REVIEW |
| Setuid or Setgid Executed in Container | runc:[2:INIT] | Container initialization activity | REVIEW |
| Discovery Tool Executed in Container | kube-system / Canal / process=ip | Kubernetes networking activity | REVIEW |
| Kubernetes Service Account Token Read | Longhorn, Calico, CSI, Velero, ingress-nginx | Legitimate service account use | REVIEW |
| Outbound Connection from Container | workload + destination based | Normal application TCP traffic | REVIEW |
| Contact K8S API Server From Container | vtdc-migration agents | Python agents observed contacting API Server | VERIFY BEFORE EXCEPTION |

`Contact K8S API Server From Container` không được allowlist chỉ dựa trên
runtime observation. Cần xác minh API access là expected behavior của
vtdc-migration workload trước khi phê duyệt exception.

---

## 6. Validation Requirements

Mọi exception trước khi ACTIVE phải chứng minh:

1. Legitimate alert giảm hoặc được loại bỏ.
2. Detection test tương ứng vẫn PASS.
3. Không tạo exclusion rộng ngoài intended workload.
4. Before/after evidence được lưu.
5. Exception record có owner và approver.

---

## 7. Audit Requirements

Các thay đổi exception phải được quản lý bằng Git.

Minimum audit evidence:

- Git commit
- Rule diff
- Exception record
- Before tuning evidence
- After tuning evidence
- Regression test result

---

## 8. FALCO-006 Status

Status: COMPLETED

Đã hoàn thành:

- Exception lifecycle.
- Exception record schema.
- Scope/allowlist principles.
- Approval requirements.
- Expiry/review requirements.
- Validation requirements.
- Mapping exception candidates từ FALCO-005.

Các candidate trong Section 5 chưa tự động được coi là APPROVED exception.
Việc triển khai từng exception phải tuân theo governance process ở trên.

FALCO-006 hoàn thành trong phạm vi thiết kế governance của nghiên cứu hiện tại.
