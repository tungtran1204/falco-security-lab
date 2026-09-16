# FALCO-005 - Severity Mapping and Expected Response

## 1. Purpose

Chuẩn hóa Falco priority thành severity vận hành để phục vụ:

- Alert triage
- Investigation
- Alert routing
- SIEM/SOC integration
- Response SLA trong các phase tiếp theo

---

## 2. Severity Mapping

| Falco Priority | Platform Severity | Expected Response |
|---|---|---|
| Notice | LOW | Ghi nhận, theo dõi và correlation với các event khác |
| Warning | MEDIUM | Triage và xác minh workload/process có hợp lệ hay không |
| Error | HIGH | Ưu tiên investigation, xác minh workload và hành vi ngay |
| Critical / Alert / Emergency | CRITICAL | Điều tra ngay, escalation theo incident process |

Severity mapping là baseline cho research hiện tại.

SLA thời gian cụ thể chưa được định nghĩa tại P3-05 và sẽ được xử lý
trong phase operational/SLA tương ứng.

---

## 3. Current Detection Mapping

| Detection Rule | Falco Priority | Platform Severity |
|---|---|---|
| Contact K8S API Server From Container | Notice | LOW |
| Discovery Tool Executed in Container | Notice | LOW |
| Container Runtime Socket Access | Warning | MEDIUM |
| Cron Persistence File Created in Container | Warning | MEDIUM |
| Executable File Created or Modified in Container | Warning | MEDIUM |
| Host Proc or Sys Access from Container | Warning | MEDIUM |
| Kubectl Executed in Container | Warning | MEDIUM |
| Kubernetes Service Account Token Read | Warning | MEDIUM |
| Mounted Application Secret Read | Warning | MEDIUM |
| Package Manager Executed in Container | Warning | MEDIUM |
| Script Interpreter Executed in Container | Warning | MEDIUM |
| Setuid or Setgid Executed in Container | Warning | MEDIUM |
| Suspicious Namespace Operation in Container | Warning | MEDIUM |
| Reverse Shell Network Connection | Error | HIGH |

---

## 4. Response Expectations

### LOW

Expected handling:

- Collect event.
- Correlate with workload identity and surrounding events.
- Không yêu cầu immediate incident escalation khi đứng độc lập.
- Escalate nếu event bất thường hoặc xuất hiện cùng detection severity cao hơn.

### MEDIUM

Expected handling:

- Triage event.
- Xác minh namespace, pod, container, image và process.
- Kiểm tra hành vi có nằm trong expected workload behavior hay không.
- Nếu legitimate noise, chuyển sang exception/tuning review.
- Nếu không xác minh được, escalation sang investigation.

### HIGH

Expected handling:

- Ưu tiên investigation.
- Xác minh pod/container/process và user/workload context.
- Correlate với các event liên quan trước và sau detection.
- Đánh giá containment nếu xác nhận malicious activity.

### CRITICAL

Expected handling:

- Immediate investigation.
- Escalate theo incident-response process.
- Thu thập evidence trước khi containment khi điều kiện cho phép.
- Thực hiện containment theo runbook đã được phê duyệt.

Hiện detection test evidence chưa ghi nhận rule custom nào sử dụng
Critical/Alert/Emergency priority.

---

## 5. Validation

Mapping được xây dựng từ priority thực tế ghi nhận trong
DET-004 đến DET-018 evidence.

Observed priorities:

- Notice
- Warning
- Error

Không nâng severity của detection chỉ nhằm làm alert nổi bật hơn.
Thay đổi severity phải dựa trên threat context, detection confidence
và operational impact.

---

## 6. P3-05 Status

Status: COMPLETED

Acceptance criteria:

- Falco priority được map sang platform severity.
- LOW/MEDIUM/HIGH/CRITICAL có expected response.
- Các detection rule hiện tại đã được map.
- Mapping có thể sử dụng cho alert routing/SIEM ở phase tiếp theo.

Việc định nghĩa response SLA theo phút và production escalation workflow
không thuộc completion scope của P3-05.
