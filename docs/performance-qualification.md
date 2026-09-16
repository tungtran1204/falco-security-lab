# FALCO-008 - Performance Qualification

## 1. Scope

Đánh giá resource consumption và performance characteristics của Falco
trong Kubernetes research environment.

Environment:

- Kubernetes: 2 nodes
- Falco: DaemonSet, 1 pod/node
- Runtime: containerd
- Driver: modern eBPF
- Metrics source: Kubernetes Metrics API

## 2. P4-01 - CPU and Memory Baseline

### Method

Resource usage được lấy bằng Kubernetes Metrics API.

Sampling:

- 10 samples
- 30-second interval
- approximately 5 minutes
- normal workload
- no intentional detection stress test

Raw evidence:

- `evidence/p4-01/resource-baseline.log`
- `evidence/p4-01/resource-summary.txt`

### Falco Engine Results

| Node | Pod | CPU Min | CPU Avg | CPU Max | Memory Avg |
|---|---|---:|---:|---:|---:|
| node01 | falco-vchmv | 56m | 59.8m | 66m | 80 MiB |
| node02 | falco-ft7dh | 38m | 41.7m | 47m | 87 MiB |

Falco engine resource consumption trong cửa sổ baseline quan sát được
ổn định trên cả hai node.

### Supporting Components

Observed averages:

| Component | CPU Avg | Memory Avg |
|---|---:|---:|
| falco-k8saudit | 71.8m | 21 MiB |
| falcosidekick node01 | 8.1m | 42.4 MiB |
| falcosidekick node02 | 25.1m | 212 MiB |
| falcosidekick UI replica 1 | 8.2m | 10.1 MiB |
| falcosidekick UI replica 2 | 9.2m | 12 MiB |
| Redis | 448.9m | 2613 MiB |

Redis consumption is significantly higher than the Falco engine and
must be treated separately from Falco engine overhead.

## 3. Qualification

P4-01 Status: COMPLETED

The test establishes a bounded normal-workload resource baseline.

It does not yet establish:

- resource usage under detection stress/load
- maximum event throughput
- detection latency
- event/drop rate
- production resource limits or SLO

These are evaluated in subsequent P4 activities.

## 4. Current FALCO-008 Status

FALCO-008: PARTIALLY COMPLETED

P4-01 resource baseline is complete.

P4-02 throughput, latency and drop-rate qualification remains pending.
