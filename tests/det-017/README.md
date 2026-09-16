# DET-017 - Outbound Connection

## Scenario
Detect an outbound network connection initiated from a container.

## Rule
`rules/det-017-outbound-connection.yaml`

## Test
Connect from the test workload to the Kubernetes API Service on TCP/443.

## Expected result
Falco triggers `Outbound Connection from Container`.

## Evidence
`evidence/det-017/falco-alert.log`
