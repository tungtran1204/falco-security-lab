# DET-005 - Script Interpreter Execution in Container

## Objective

Validate that Falco detects script interpreter execution inside a running container.

## Rule

`rules/det-005-script-interpreter.yaml`

Rule name:

`Script Interpreter Executed in Container`

## Test environment

- Kubernetes v1.36.2
- Falco 0.44.1
- Helm chart 9.1.0
- containerd
- Test image: python:3.12-slim
- Test pod: det-005-test

## Test procedure

Create test pod:

kubectl run det-005-test \
  --image=python:3.12-slim \
  --restart=Never \
  --command -- sleep 3600

Trigger:

kubectl exec det-005-test -- python3 --version

kubectl exec det-005-test -- \
  python3 -c 'print("DET-005 Falco test")'

## Expected result

Falco generates:

`Script Interpreter Executed in Container`

with process, container and Kubernetes metadata.

## Actual result

PASS

Falco detected both:
- python3 --version
- python3 -c ...

Observed metadata included:
- user=root
- parent process
- container_name=det-005-test
- image=docker.io/library/python:3.12-slim
- k8s_ns=default
- k8s_pod=det-005-test
- source=syscall
- priority=Warning
- tag=det-005

Evidence:

`evidence/det-005/falco-alert.log`

## Conclusion

DET-005 successfully validates detection of script interpreter execution inside a running container.
