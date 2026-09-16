# DET-016 - Process and Network Discovery

## Scenario
Detect execution of process or network discovery tools inside a container.

## Rule
`rules/det-016-discovery-tools.yaml`

## Test manifest
`manifests/test-pods/det-016.yaml`

## Test script
`scripts/test-det-016.sh`

## Trigger
Execute `ps aux` inside the test workload.

## Expected result
Falco triggers `Discovery Tool Executed in Container`.

## Evidence
`evidence/det-016/falco-alert.log`
