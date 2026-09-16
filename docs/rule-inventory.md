# Falco Rule Inventory & Qualification

## 1. Mục đích

Tài liệu này quản lý inventory và trạng thái qualification của các Falco rule
được sử dụng trong môi trường nghiên cứu.

Mỗi rule được đánh giá theo một trong các quyết định:

- KEEP: Giữ rule upstream.
- TUNE: Rule có giá trị nhưng cần hoặc đã được tuning để giảm noise.
- DISABLE: Không đưa rule vào baseline.
- REPLACE: Thay thế bằng rule khác phù hợp hơn.
- CUSTOM: Rule do nhóm tự xây dựng và đã kiểm thử.
- REVIEW: Chưa hoàn tất qualification.

---

## 2. Runtime Baseline

- Falco: 0.44.1
- Helm chart: 9.1.0
- Runtime: containerd
- Driver: modern eBPF
- Runtime event source: syscall
- Upstream syscall rules discovered: 25
- Custom syscall rules discovered: 14
- Kubernetes Audit được xử lý bởi falco-k8saudit riêng.

---

## 3. Custom Syscall Rules

| DET | Rule | Result | Noise / Observation | Decision | Evidence |
|---|---|---|---|---|---|
| DET-004 | Package Manager Executed in Container | PASS | Chưa ghi nhận noise đáng kể trong test | CUSTOM | evidence/det-004/falco-alert.log |
| DET-005 | Script Interpreter Executed in Container | PASS | Chưa ghi nhận noise đáng kể trong test | CUSTOM | evidence/det-005/falco-alert.log |
| DET-006 | Kubernetes Service Account Token Read | PASS | Noise cao từ Longhorn, Flannel, Velero, Calico, CSI và workload hệ thống | TUNE | evidence/det-006/falco-alert.log |
| DET-007 | Mounted Application Secret Read | PASS | Scope giới hạn tại /etc/app-secrets/ | CUSTOM | evidence/det-007/falco-alert.log |
| DET-008 | Setuid or Setgid Executed in Container | PASS | Có thể phát sinh event trong quá trình runtime/container initialization | TUNE | evidence/det-008/falco-alert.log |
| DET-009 | Suspicious Namespace Operation in Container | PASS | Noise đáng kể từ Longhorn với setns/unshare | TUNE | evidence/det-009/falco-alert.log |
| DET-010 | Container Runtime Socket Access | PASS | Tín hiệu có giá trị cao khi runtime socket xuất hiện trong workload | CUSTOM | evidence/det-010/falco-alert.log |
| DET-011 | Host Proc or Sys Access from Container | PASS | Longhorn tạo legitimate event; đã exclude namespace longhorn-system | TUNE | evidence/det-011/falco-alert.log |
| DET-012 | Kubectl Executed in Container | PASS | Cần xem xét allowlist workload quản trị khi production | CUSTOM | evidence/det-012/falco-alert.log |
| DET-014 | Cron Persistence File Created in Container | PASS | Chưa ghi nhận noise đáng kể trong test | CUSTOM | evidence/det-014/falco-alert.log |
| DET-015 | Executable File Created or Modified in Container | PASS | Có thể cần allowlist image thực hiện update hợp lệ | CUSTOM | evidence/det-015/falco-alert.log |
| DET-016 | Discovery Tool Executed in Container | PASS | Có thể phát sinh legitimate activity khi troubleshooting | CUSTOM | evidence/det-016/falco-alert.log |
| DET-017 | Outbound Connection from Container | PASS | Đã exclude falco, kube-system và longhorn-system để giảm noise | TUNE | evidence/det-017/falco-alert.log |
| DET-018 | Reverse Shell Network Connection | PASS | Detection dựa trên proc.cmdline chứa /dev/tcp/; fd.name/fd.rport chưa có giá trị trong test | CUSTOM | evidence/det-018/falco-alert.log |

---

## 4. Kubernetes Audit Detection

| DET | Detection | Source | Result | Decision | Evidence |
|---|---|---|---|---|---|
| DET-013 | Kubernetes Secrets API Access | k8s_audit | PASS | CUSTOM | evidence/det-013/falco-alert.log |

DET-013 được kiểm thử end-to-end thông qua Kubernetes Audit webhook bằng thao tác
tạo và đọc Kubernetes Secret. Falco nhận được audit event tương ứng.

---

## 5. Upstream Falco Rules

Các rule dưới đây được phát hiện trong `/etc/falco/falco_rules.yaml`.

Trạng thái REVIEW không có nghĩa rule không phù hợp. Nó có nghĩa rule chưa được
qualification để đưa ra quyết định KEEP/TUNE/DISABLE/REPLACE.

| Rule | Decision |
|---|---|
| Clear Log Activities | TUNE |
| Contact K8S API Server From Container | TUNE |
| Create Hardlink Over Sensitive Files | KEEP |
| Create Symlink Over Sensitive Files | KEEP |
| Debugfs Launched in Privileged Container | KEEP |
| Detect release_agent File Container Escapes | KEEP |
| Directory traversal monitored file read | KEEP |
| Disallowed SSH Connection Non Standard Port | TUNE |
| Drop and execute new binary in container | TUNE |
| Execution from /dev/shm | KEEP |
| Fileless execution via memfd_create | KEEP |
| Find AWS Credentials | KEEP |
| Linux Kernel Module Injection Detected | TUNE |
| Netcat Remote Code Execution in Container | KEEP |
| PTRACE anti-debug attempt | KEEP |
| PTRACE attached to process | TUNE |
| Packet socket created in container | TUNE |
| Read sensitive file trusted after startup | TUNE |
| Read sensitive file untrusted | TUNE |
| Redirect STDOUT/STDIN to Network Connection in Container | TUNE |
| Remove Bulk Data from Disk | TUNE |
| Run shell untrusted | TUNE |
| Search Private Keys or Passwords | KEEP |
| System user interactive | TUNE |
| Terminal shell in container | KEEP |

---

## 6. Qualification Summary

### Custom detection

- DET-004 -> DET-018: PASS
- Custom syscall rules: 14
- Kubernetes Audit detection: 1
- Custom rules requiring noise/tuning review:
  DET-006, DET-008, DET-009, DET-011, DET-017

### Upstream detection

- Discovered: 25
- Qualified: 25/25
- KEEP: 12
- TUNE: 13
- DISABLE: 0
- REPLACE: 0
- REVIEW: 0

Các rule có decision TUNE được giữ lại trong baseline nghiên cứu nhưng cần
tiếp tục đo noise và xác định allowlist/exclusion phù hợp trong FALCO-005.

---

## 7. FALCO-004 Status

Status: COMPLETED

Đã hoàn thành:

- Inventory 25 upstream syscall rules.
- Inventory 14 custom syscall rules.
- Mapping custom rules với DET-004 -> DET-018.
- Ghi nhận Kubernetes Audit detection riêng cho DET-013.
- Qualification 25/25 upstream rules.
- Xác định decision KEEP/TUNE cho toàn bộ upstream rules.
- Ghi nhận các custom rule có noise/tuning requirement.
- Xác định các rule cần tiếp tục noise/false-positive qualification trong FALCO-005.

Kết quả qualification hiện tại:

- Upstream KEEP: 12
- Upstream TUNE: 13
- Upstream DISABLE: 0
- Upstream REPLACE: 0
- Upstream REVIEW: 0

FALCO-004 hoàn thành ở phạm vi Rule Inventory & Qualification.
Các hoạt động tuning và đo false positive chi tiết tiếp tục được quản lý
trong FALCO-005.
