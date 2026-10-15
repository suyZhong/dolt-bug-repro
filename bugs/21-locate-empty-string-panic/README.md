# Panic in LOCATE with an empty string and a start position past its end

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`LOCATE('a', '', 2)` fails with `panic recovered: runtime error: slice bounds out of range [1:0]`. MySQL returns 0. Start position 1 works. The closed dolthub/dolt#11393 covers negative start positions.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
SELECT LOCATE('a', 'abc', 2), LOCATE('a', '', 1);
-- 0, 0

SELECT LOCATE('a', '', 2);
-- Expected: 0
-- Actual:   ERROR 1105 (HY000): panic recovered: runtime error: slice bounds out of range [1:0]
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
