# FALCO-009 - Failure and Recovery Qualification

## 1. Scope

Đánh giá khả năng tự phục hồi của Falco khi một Falco engine pod bị mất
trong Kubernetes research environment.

Environment:

- Kubernetes: 2 nodes
- Falco: 0.44.1
- Deployment: DaemonSet
- Runtime: containerd
- Driver: modern eBPF

## 2. P4-03 - Falco Pod Recovery

### Pre-test State

Target:

- Node: node02
- Pod: falco-t8p52
- Pod UID: 12dde626-8c36-486c-b779-00d8e6b2df39
- Pod state: 2/2 Running
- Container restart count: 0
- DaemonSet: 2 desired / 2 ready

Evidence:

- `evidence/p4-03/pre-recovery.log`

### Failure Injection

The Falco pod on node02 was intentionally deleted.

Kubernetes DaemonSet reconciliation automatically created a replacement
Falco pod without manual recovery action.

### Recovery Result

Replacement:

- Old pod: falco-t8p52
- New pod: falco-psvqh
- Old UID: 12dde626-8c36-486c-b779-00d8e6b2df39
- New UID: 40efb2e6-512e-47c1-8f8f-462020429249
- Recovery to Ready: 56.752 seconds
- New pod state: 2/2 Running
- DaemonSet after recovery: 2 desired / 2 ready
- Restart count: 0

Post-recovery Falco engine:

- Falco version: 0.44.1
- Capture engine: modern_bpf
- Event source: syscall
- Event processing confirmed
- Capture drops observed: 0

Evidence:

- `evidence/p4-03/pod-recovery.log`

## 3. Post-Recovery Detection Validation

After Falco recovery, DET-004 was triggered using:

`Package Manager Executed in Container`

Test workload:

- Pod: p4-recovery-detection-test
- Node: node02
- Command: apt --version

Result:

- Trigger: 1
- Detection: 1
- Detection result: PASS

This confirms that the replacement Falco engine resumed syscall
detection after recovery.

Evidence:

- `evidence/p4-03/post-recovery-detection.log`

## 4. Qualification

P4-03 Status: COMPLETED

The controlled pod-loss test demonstrated:

- automatic DaemonSet reconciliation
- automatic Falco pod replacement
- recovery to Ready without manual intervention
- modern eBPF capture resumed
- zero observed capture drops after recovery
- successful post-recovery detection

Observed recovery time:

56.752 seconds

This value is an observation from this research environment and is not
defined as a production recovery SLO.

## 5. Limitations

This test validates Falco pod deletion/replacement recovery only.

It does not yet establish recovery behavior for:

- node reboot
- node failure
- new-node scheduling
- OOM caused by resource exhaustion
- Falcosidekick failure
- Redis failure
- UI failure
- prolonged control-plane/network outage

These scenarios are evaluated separately in subsequent P4 activities.

## 6. FALCO-009 Status

FALCO-009: PARTIALLY COMPLETED

P4-03 pod recovery qualification is complete.

Additional infrastructure and downstream failure scenarios remain
covered by subsequent P4 activities.
