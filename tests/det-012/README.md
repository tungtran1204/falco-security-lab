# DET-012 - Kubectl Executed in Container

## Scenario
Detect execution of kubectl from inside a Kubernetes workload.

## Rule
`rules/det-012-kubectl-in-container.yaml`

## Test manifest
`manifests/test-pods/det-012.yaml`

## Test script
`scripts/test-det-012.sh`

## Expected result
Falco triggers `Kubectl Executed in Container`.

## Evidence
`evidence/det-012/falco-alert.log`
