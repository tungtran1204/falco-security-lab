# FALCO-007 Detection Test Suite Qualification

## 1. Purpose

Xác nhận detection test suite có đủ test artefact, runtime evidence và
documentation để phục vụ việc qualification Falco detection trong phạm vi
nghiên cứu hiện tại.

---

## 2. Test Suite Summary

| Detection | Scenario | Result | Evidence |
|---|---|---|---|
| DET-004 | Abnormal Package Manager Execution | PASS | evidence/det-004/falco-alert.log |
| DET-005 | Script Interpreter / Compiler Execution | PASS | evidence/det-005/falco-alert.log |
| DET-006 | Kubernetes Service Account Token Read | PASS | evidence/det-006/falco-alert.log |
| DET-007 | Mounted Application Secret Read | PASS | evidence/det-007/falco-alert.log |
| DET-008 | Setuid / Setgid Execution | PASS | evidence/det-008/falco-alert.log |
| DET-009 | Suspicious Namespace Operation | PASS | evidence/det-009/falco-alert.log |
| DET-010 | Container Runtime Socket Access | PASS | evidence/det-010/falco-alert.log |
| DET-011 | Host Proc / Sys Access | PASS | evidence/det-011/falco-alert.log |
| DET-012 | Kubectl Execution in Workload | PASS | evidence/det-012/falco-alert.log |
| DET-013 | Kubernetes Secret API Access | PASS | evidence/det-013/falco-alert.log |
| DET-014 | Cron Persistence | PASS | evidence/det-014/falco-alert.log |
| DET-015 | Executable Modification | PASS | evidence/det-015/falco-alert.log |
| DET-016 | Discovery Tool Execution | PASS | evidence/det-016/falco-alert.log |
| DET-017 | Outbound Connection | PASS | evidence/det-017/falco-alert.log |
| DET-018 | Reverse Shell Indicator | PASS | evidence/det-018/falco-alert.log |

---

## 3. Artefact Qualification

DET-004 through DET-018 were audited for the following artefacts:

- Test documentation
- Detection rule
- Runtime Falco alert evidence
- Repeatable test script where applicable
- Kubernetes test manifest where applicable
- Expected detection result
- Actual test result / evidence

Audit result:

- Test cases qualified: 15/15
- Documentation: 15/15
- Runtime evidence: 15/15
- Detection rules: 15/15
- Test scripts: available for all applicable syscall scenarios
- Test manifests: available for all applicable syscall scenarios

DET-013 is intentionally handled separately through the Kubernetes Audit
event source and falco-k8saudit. A syscall test pod/script is therefore not
required for this scenario.

---

## 4. Known Qualification Notes

Some individual test documents use different section names such as
`Test procedure`, `Test command`, `Trigger`, `Execute`, `Scenario` and
`Test script`. These differences do not change the test result because the
required execution procedure and evidence are present in the test artefacts.

Noise observed during several detection tests is tracked separately by
FALCO-005 Noise & False Positive Qualification.

DET-018 successfully detects the reverse-shell command-line indicator.
Network metadata such as destination name/port may be incomplete in the
captured event and remains a documented limitation.

---

## 5. Evidence Location

Test documentation:

    docs/test-results/det-004.md ... det-018.md

Runtime evidence:

    evidence/det-004/falco-alert.log ... det-018/falco-alert.log

Rules:

    rules/det-004-*.yaml ... det-018-*.yaml

---

## 6. FALCO-007 Status

Status: COMPLETED

Acceptance result:

- Detection scenarios executed: PASS
- Runtime alert evidence captured: PASS
- Test documentation available: PASS
- Applicable scripts/manifests available: PASS
- Kubernetes Audit scenario validated separately: PASS

FALCO-007 Detection Test Suite is complete for the current research
qualification scope.

This status does not imply Production Ready or CNAE Ready.
