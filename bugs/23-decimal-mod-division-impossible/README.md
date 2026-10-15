# Unexpected error "division impossible" from MOD

**Affected:** Both forms raise `division impossible` from 2.1.0 through 2.4.2 and on master. In 2.0.0 and earlier, the second form also returns a wrong result.

## What happens

`100000000 MOD 0.0001` and `1e30 MOD 7` raise `division impossible`. MySQL returns `0.0000` and `5`. A control, `476098643 MOD 0.5962`, returns the expected result. Releases through 2.0.0 return `0.0000` for the first query but the wrong value `1` for the second.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
SELECT 476098643 MOD 0.5962;
-- 0.5652

SELECT 100000000 MOD 0.0001;
-- Expected: 0.0000
-- Actual:   ERROR 1105 (HY000): division impossible

SELECT 1e30 MOD 7;
-- Expected: 5
-- Actual:   ERROR 1105 (HY000): division impossible
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
