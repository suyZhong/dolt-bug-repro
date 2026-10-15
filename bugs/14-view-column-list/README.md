# Unexpected results when filtering a view that has an explicit column list

**Affected:** 1.84.0 through 2.4.2, and master.

## What happens

The view `v0(c0, c1, c2)` returns `11, 21, 31`. `WHERE c0 = 11` returns nothing and `WHERE c0 = 31` returns the row. `EXPLAIN PLAN` shows the pushed-down filter as `((t0.c2 + 1) = 11)`. 1.78.0 returns the correct results. The closed dolthub/dolt#10741 covers a different view column-list test case involving `UNION ALL`.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 INT, c1 INT, c2 INT);
INSERT INTO t0 VALUES (10, 20, 30);
CREATE VIEW v0(c0, c1, c2) AS SELECT c0 + 1, c1 + 1, c2 + 1 FROM t0;

SELECT * FROM v0;
-- 11, 21, 31

SELECT * FROM v0 WHERE c0 = 11;
-- Expected: 11, 21, 31
-- Actual:   empty set

SELECT * FROM v0 WHERE c0 = 31;
-- Expected: empty set
-- Actual:   11, 21, 31
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
