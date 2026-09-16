# DET-004 - Package Manager Execution in Container

## Giải thích
Phát hiện việc chạy trình quản lý package trong container; test bằng cách chạy apt/apt-get trong pod test và kiểm tra Falco sinh alert.


## Objective

Validate that Falco detects execution of package management tools inside a running container.

## Rule

`rules/det-004-package-manager.yaml`

Rule name:

`Package Manager Executed in Container`

## Test environment

- Kubernetes
- Falco 0.44.1
- Helm chart 9.1.0
- containerd
- Test image: ubuntu:22.04
- Test pod: det-004-test

## Test procedure

Create test pod:

kubectl run det-004-test \
  --image=ubuntu:22.04 \
  --restart=Never \
  --command -- sleep 3600

Trigger package manager execution:

kubectl exec det-004-test -- apt --version
kubectl exec det-004-test -- apt-get --version

## Expected result

Falco generates the rule:

`Package Manager Executed in Container`

with Kubernetes and container metadata.

## Actual result

PASS

Falco detected both:

- `apt --version`
- `apt-get --version`

Observed metadata included:

- user=root
- container_name=det-004-test
- image=docker.io/library/ubuntu:22.04
- k8s_ns=default
- k8s_pod=det-004-test
- source=syscall
- priority=Warning
- tag=det-004

Evidence:

`evidence/det-004/falco-alert.log`

## Conclusion

DET-004 successfully validates detection of package manager execution inside a running container.
