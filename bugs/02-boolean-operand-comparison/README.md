# Unexpected results when filtering on a comparison with a boolean operand

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`(1 > 0) < c0` is 1 for `c0 = 2` and `c0 = 5`, but `WHERE (1 > 0) < c0` returns no rows. `WHERE NOT ((1 > 0) < c0)` also returns no rows from 2.3.5 on; earlier releases return all four rows for it. `(c0 >= 1) > false` behaves the same way.

Adding `ORDER BY c0` or using `COUNT(*)` gives the expected result. `EXPLAIN PLAN` shows a plain `Filter (true < t0.c0)` over the table.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 INT);
INSERT INTO t0 VALUES (0), (1), (2), (5);

SELECT c0, (1 > 0) < c0 AS p FROM t0;
-- 0, 0 / 1, 0 / 2, 1 / 5, 1 (any order)

SELECT c0 FROM t0 WHERE (1 > 0) < c0;
-- Expected: 2 / 5 (any order)
-- Actual:   empty set

SELECT c0 FROM t0 WHERE NOT ((1 > 0) < c0);
-- Expected: 0 / 1 (any order)
-- Actual:   empty set

SELECT c0 FROM t0 WHERE (1 > 0) < c0 ORDER BY c0;
-- 2 / 5

SELECT c0 FROM t0 WHERE (c0 >= 1) > false;
-- Expected: 1 / 2 / 5 (any order)
-- Actual:   empty set
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
