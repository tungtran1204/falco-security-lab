# FALCO-008 - Performance Qualification

## 1. Scope

Đánh giá resource consumption và performance characteristics của Falco
trong Kubernetes research environment.

Environment:

- Kubernetes: 2 nodes
- Falco: 0.44.1
- Falco deployment: DaemonSet, 1 Falco engine pod/node
- Runtime: containerd
- Driver: modern eBPF
- Metrics source: Kubernetes Metrics API and Falco Prometheus metrics

This qualification covers:

- P4-01: CPU and memory baseline
- P4-02: event throughput, detection latency proxy and event drops

Results represent bounded observations in the research environment and
must not be interpreted as maximum Falco capacity or production SLO.

---

## 2. P4-01 - CPU and Memory Baseline

### Method

Resource usage was sampled using Kubernetes Metrics API.

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

Falco engine resource consumption remained bounded during the observed
normal-workload sampling window.

### Supporting Components

| Component | CPU Avg | Memory Avg |
|---|---:|---:|
| falco-k8saudit | 71.8m | 21 MiB |
| falcosidekick node01 | 8.1m | 42.4 MiB |
| falcosidekick node02 | 25.1m | 212 MiB |
| falcosidekick UI replica 1 | 8.2m | 10.1 MiB |
| falcosidekick UI replica 2 | 9.2m | 12 MiB |
| Redis | 448.9m | 2613 MiB |

Redis consumption was significantly higher than the Falco engine and
is therefore treated separately from Falco engine overhead.

### P4-01 Result

Status: COMPLETED

A multi-sample normal-workload CPU and memory baseline was established
for both Falco engine instances.

---

## 3. P4-02 - Event Throughput and Drop Qualification

### Method

A controlled syscall workload was executed for approximately 60 seconds
on node02 while Falco modern eBPF metrics were collected before and
after the workload.

Falco metrics used:

- `falcosecurity_scap_n_evts_total`
- `falcosecurity_scap_n_drops_total`
- `falcosecurity_scap_n_store_evts_drops_total`
- `falcosecurity_scap_n_retrieve_evts_drops_total`
- `falcosecurity_falco_outputs_queue_num_drops_total`

Evidence:

- `evidence/p4-02/load-test.log`
- `evidence/p4-02/all-falco-metrics.txt`
- `evidence/p4-02/detection-latency-raw.log`
- `evidence/p4-02/detection-latency-summary.txt`

### Controlled Load Result

| Metric | Result |
|---|---:|
| Test duration | ~60 seconds |
| Observed events | 1,175,842 |
| Observed event rate | 19,597.37 events/sec |
| Capture drop delta | 0 |
| Store drop delta | 0 |
| Retrieve drop delta | 0 |
| Output queue drop delta | 0 |
| Capture drop ratio | 0.000000% |

Falco remained Running with zero restarts after the controlled workload.

Post-load observed Falco resource usage on node02:

- CPU: 230m
- Memory: 90 MiB

The observed event rate is a bounded test result and must not be
interpreted as Falco maximum throughput.

---

## 4. Detection Latency Proxy

DET-004 `Package Manager Executed in Container` was triggered 10 times.

Result:

- triggers: 10
- detections: 10
- detection success: 10/10

Latency:

| Metric | Result |
|---|---:|
| Minimum | 1.146 ms |
| Average | 1.742 ms |
| Median | 1.514 ms |
| Maximum | 2.614 ms |

Latency was calculated from the timestamp recorded immediately before
the test process invocation to Falco `evt.time`.

This measurement represents a syscall event-detection latency proxy.

It does not represent end-to-end delivery latency through Falcosidekick,
Redis, UI or an external SIEM.

---

## 5. Qualification Result

P4-01 Status: COMPLETED

P4-02 Status: COMPLETED

FALCO-008 Status: COMPLETED

The qualification established:

- normal-workload Falco CPU and memory baseline
- controlled event-processing rate
- zero observed event drops during the controlled workload
- successful 10/10 controlled detections
- bounded syscall detection latency proxy
- continued Falco availability after the workload

This qualification does not establish:

- absolute or maximum Falco throughput
- saturation/breaking point
- production resource limits
- production SLO
- end-to-end SIEM delivery latency
- long-duration performance characteristics

Those limitations must be considered separately for production readiness.
