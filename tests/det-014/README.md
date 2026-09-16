# DET-014 - Cron Persistence

## Giải thích
Phát hiện hành vi persistence thông qua việc tạo hoặc sửa cron file trong container; test bằng cách ghi file /etc/cron.d/det-014 và kiểm tra Falco sinh alert.


## Scenario
Detect creation or modification of cron persistence files inside a container.

## Rule
`rules/det-014-cron-persistence.yaml`

## Test manifest
`manifests/test-pods/det-014.yaml`

## Test script
`scripts/test-det-014.sh`

## Trigger
Write a cron entry to `/etc/cron.d/det-014`.

## Expected result
Falco triggers `Cron Persistence File Created in Container`.

## Evidence
`evidence/det-014/falco-alert.log`
