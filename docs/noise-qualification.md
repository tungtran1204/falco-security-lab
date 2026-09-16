# Falco Noise & False Positive Qualification

## 1. Mục đích

Đánh giá noise và false positive của các Falco detection rule đã được xác định
cần tuning trong quá trình Rule Inventory & Qualification.

Mục tiêu là xác định nguồn legitimate activity, mức độ noise và hướng tuning
trước khi xây dựng production rule baseline.

---

## 2. Custom Rule Qualification

| DET | Rule | Noise Observation | Current Tuning | Status |
|---|---|---|---|---|
| DET-006 | Kubernetes Service Account Token Read | High noise từ Longhorn, Flannel, Velero, Calico, CSI và system workloads | Cần xây dựng allowlist theo namespace/workload | TUNE |
| DET-008 | Setuid or Setgid Executed in Container | Có event legitimate trong runtime/container initialization | Cần phân biệt initialization với runtime privilege change | TUNE |
| DET-009 | Suspicious Namespace Operation in Container | High noise từ Longhorn sử dụng setns/unshare | Cần exclude legitimate Longhorn activity | TUNE |
| DET-011 | Host Proc or Sys Access from Container | Longhorn tạo legitimate host proc/sys access | Đã exclude namespace longhorn-system | TUNED |
| DET-017 | Outbound Connection from Container | Broad outbound connect tạo nhiều legitimate events; runtime sampling vẫn ghi nhận 2496 events | Đã exclude falco, kube-system, longhorn-system; cần workload/destination baseline bổ sung | PARTIALLY TUNED |

---

## 3. Upstream Rule Qualification

13 upstream rules được FALCO-004 đánh dấu TUNE đã được qualification về
noise risk và tuning strategy.

| Rule | Noise Risk | Legitimate Activity / Observation | Tuning Strategy | Status |
|---|---|---|---|---|
| Clear Log Activities | Medium | Log rotation hoặc logging workload có thể truncate file | Profile log paths, trusted logging images và allowed_clear_log_files | QUALIFIED |
| Contact K8S API Server From Container | High | Controller, operator và workload Kubernetes có thể gọi API Server hợp lệ | Allowlist namespace, image, service account hoặc known API clients | QUALIFIED |
| Disallowed SSH Connection Non Standard Port | Medium | Môi trường có thể sử dụng custom SSH ports | Điều chỉnh danh sách/range SSH ports theo network policy thực tế | QUALIFIED |
| Drop and execute new binary in container | High | Debugging, init/update hoặc runtime-generated executable có thể tạo event | Allowlist image, namespace và known_drop_and_execute activities | QUALIFIED |
| Linux Kernel Module Injection Detected | Low | Một số privileged/system workload có thể load kernel module hợp lệ | Allowlist image được phép quản lý kernel module | QUALIFIED |
| PTRACE attached to process | Medium | Debugger, profiler và troubleshooting tool có thể sử dụng ptrace | Allowlist known_ptrace_procs và workload debugging | QUALIFIED |
| Packet socket created in container | Medium | Network diagnostics/monitoring có thể tạo AF_PACKET socket | Allowlist known packet-socket binaries/images | QUALIFIED |
| Read sensitive file trusted after startup | High | Server/application có thể đọc credential/config hợp lệ sau startup | Profile server process, sensitive paths và known read activities | QUALIFIED |
| Read sensitive file untrusted | High | Tooling, agent và system workload có thể đọc Linux sensitive files | Allowlist known processes, containers và sensitive-file readers | QUALIFIED |
| Redirect STDOUT/STDIN to Network Connection in Container | Medium | Một số networking/interactive workload có thể redirect descriptors | Tune theo process lineage, image và known stream-redirection activity | QUALIFIED |
| Remove Bulk Data from Disk | Medium | Cleanup, maintenance và data lifecycle jobs có thể xóa dữ liệu hợp lệ | Allowlist known_remove_data_activities và maintenance workloads | QUALIFIED |
| Run shell untrusted | High | Application, healthcheck hoặc automation có thể spawn shell hợp lệ | Tune protected spawners, process lineage và known shell activities | QUALIFIED |
| System user interactive | Medium | Administrative/troubleshooting session bằng service/system account | Profile system users, login source và TTY; allowlist expected access | QUALIFIED |

### Qualification Summary

- Upstream TUNE rules: 13
- Noise-risk qualification: 13/13
- High noise risk: 5
- Medium noise risk: 7
- Low noise risk: 1
- Runtime tuning chưa được coi là hoàn tất chỉ dựa trên qualification lý thuyết.

## 4. Evidence

Runtime evidence hiện có:

- evidence/det-006/falco-alert.log
- evidence/det-008/falco-alert.log
- evidence/det-009/falco-alert.log
- evidence/det-011/falco-alert.log
- evidence/det-017/falco-alert.log

---

## 5. FALCO-005 Status

Status: COMPLETED

Đã hoàn thành:

- Qualification noise risk cho 13/13 upstream rules có decision TUNE.
- Thu thập runtime noise baseline trong cửa sổ 30 phút.
- Phân tích nguồn phát sinh alert theo namespace, pod và process.
- Xác định các custom rules có background noise đáng kể.
- Xác nhận DET-011 đã được tuning.
- Xác nhận DET-017 hiện PARTIALLY TUNED.
- Xác định tuning strategy cho các rule có noise.

Kết quả runtime sampling:

- Total log lines: 5692
- Outbound Connection from Container: 2496
- Suspicious Namespace Operation in Container: 1540
- Setuid or Setgid Executed in Container: 602
- Discovery Tool Executed in Container: 593
- Kubernetes Service Account Token Read: 447
- Contact K8S API Server From Container: 14

Các tuning action chưa triển khai hoàn toàn được giữ làm follow-up cho
production rule baseline. Việc qualification noise/false-positive của
FALCO-005 hoàn thành ở phạm vi nghiên cứu hiện tại.

## 6. Runtime Noise Baseline

### Sampling Method

Falco runtime logs được thu thập từ tất cả Falco pods trong khoảng thời gian
30 phút khi cluster hoạt động bình thường.

Trong thời gian sampling không chủ động chạy các DET test scenario.

Evidence:

- evidence/noise-baseline/falco-runtime.log

Total log lines collected: 5692

### Observed Rule Events

| Rule | Events | Observation |
|---|---:|---|
| Outbound Connection from Container | 2496 | High background noise |
| Suspicious Namespace Operation in Container | 1540 | High background noise |
| Setuid or Setgid Executed in Container | 602 | High background noise |
| Discovery Tool Executed in Container | 593 | High background noise |
| Kubernetes Service Account Token Read | 447 | High background noise |
| Contact K8S API Server From Container | 14 | Upstream TUNE rule observed during normal operation |

### Upstream TUNE Baseline

Trong 13 upstream rules được đánh dấu TUNE:

- 1/13 rule phát sinh event trong cửa sổ sampling:
  Contact K8S API Server From Container: 14 events.
- 12/13 rule không phát sinh event trong cửa sổ sampling 30 phút.

Không quan sát thấy event trong khoảng sampling không đồng nghĩa rule không thể
phát sinh false positive. Kết quả chỉ phản ánh workload và thời gian quan sát hiện tại.

### Runtime Qualification Result

Các rule cần ưu tiên tuning dựa trên runtime evidence:

1. Outbound Connection from Container
2. Suspicious Namespace Operation in Container
3. Setuid or Setgid Executed in Container
4. Discovery Tool Executed in Container
5. Kubernetes Service Account Token Read
6. Contact K8S API Server From Container

Status: RUNTIME BASELINE COLLECTED

---

## 7. Runtime Noise Analysis

| Rule | Runtime Observation | Assessment | Tuning Action |
|---|---|---|---|
| Discovery Tool Executed in Container | 593 events; canal-kp5fl=329 và canal-t8txf=264, process=ip | Legitimate Kubernetes networking activity | Exclude known Canal/Calico networking workload hoặc kube-system + expected process |
| Kubernetes Service Account Token Read | 447 events; chủ yếu Longhorn, Calico controllers, CSI, Velero và ingress-nginx | ServiceAccount token được legitimate Kubernetes components sử dụng thường xuyên | Allowlist theo namespace/workload/service component thay vì disable rule |
| Outbound Connection from Container | 2496 events; chủ yếu vtdc-migration, Harbor, ingress-nginx, Velero và application workloads | Rule quá rộng cho production baseline nếu alert mọi TCP connect | Xây dựng network-aware allowlist/baseline theo workload và destination |
| Setuid or Setgid Executed in Container | 602 events; phần lớn proc=runc:[2:INIT] tại Longhorn và kube-system | Container initialization tạo false-positive/noise lớn | Exclude runc initialization context; vẫn giữ detection cho runtime privilege changes |
| Suspicious Namespace Operation in Container | 1540 events; toàn bộ Longhorn manager/nsenter | Legitimate Longhorn namespace operations tạo high noise | Exclude known Longhorn namespace operations |
| Contact K8S API Server From Container | 14 events; toàn bộ Python agent trong namespace vtdc-migration | API access đã xác định nguồn nhưng legitimacy cần xác minh với workload design | Chỉ allowlist vtdc-migration agent nếu API access là expected behavior |

### Runtime Findings

Background sampling cho thấy noise tập trung mạnh vào một số workload hệ thống
và application cụ thể, thay vì phân bố ngẫu nhiên.

Các nguồn noise chính đã xác định:

- Canal/Calico networking.
- Longhorn storage components.
- Kubernetes CSI components.
- Velero.
- Harbor.
- ingress-nginx.
- vtdc-migration workloads.
- container runtime initialization (`runc:[2:INIT]`).

Không disable detection chỉ vì có legitimate event. Ưu tiên tuning bằng
namespace, workload, image, process lineage hoặc known-activity macro.

`Contact K8S API Server From Container` từ namespace `vtdc-migration` chưa được
coi là false positive cho tới khi xác minh các migration agent được thiết kế để
truy cập Kubernetes API Server.
