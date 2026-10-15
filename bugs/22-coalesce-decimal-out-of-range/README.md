# Unexpected error from COALESCE(int_col, decimal_literal)

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`COALESCE(a, 1.5)` over an INT column holding 1000 fails with `Out of range value for column of Decimal type`, in the select list and in `WHERE`. With the arguments swapped, `COALESCE(1.5, a)`, it works. MySQL returns `1000.0`, `2.0` and `1.5`.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(a INT);
INSERT INTO t0 VALUES (1000), (2), (NULL);

SELECT * FROM t0 WHERE COALESCE(1.5, a) > 1;
-- 1000 / 2 / NULL (any order)

SELECT * FROM t0 WHERE COALESCE(a, 1.5) > 1;
-- Expected: 1000 / 2 / NULL (any order)
-- Actual:   ERROR 1105 (HY000): Out of range value for column of Decimal type

SELECT a, COALESCE(a, 1.5) FROM t0;
-- Expected: 1000, 1000.0 / 2, 2.0 / NULL, 1.5 (any order)
-- Actual:   ERROR 1105 (HY000): Out of range value for column of Decimal type
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
