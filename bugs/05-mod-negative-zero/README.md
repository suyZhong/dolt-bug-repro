# Unexpected results of MOD with a negative dividend that divides evenly

**Affected:** 2.1.0 through 2.4.2, and master.

## What happens

`-5 MOD 5` returns `-0`. That value counts as different from `0` in `COUNT(DISTINCT ...)`, and a join on `t0.c0 MOD 2 = t1.c0 MOD 2` loses the matches for the negative even values: it returns 4 rows where the cross-join count says 12. 2.0.0 and earlier return `0` and the correct counts.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
SELECT -5 MOD 5, 5 MOD 5;
-- Expected: 0, 0
-- Actual:   -0, 0

SELECT COUNT(DISTINCT m) FROM (SELECT -5 MOD 5 AS m UNION ALL SELECT 5 MOD 5) t;
-- Expected: 1
-- Actual:   2

CREATE TABLE t0(c0 INT);
CREATE TABLE t1(c0 INT);
INSERT INTO t0 VALUES (-4), (-2), (5);
INSERT INTO t1 VALUES (3), (4), (6), (7), (8), (9), (10), (11);

SELECT SUM((t0.c0 MOD 2) = (t1.c0 MOD 2)) FROM t0, t1;
-- 12

SELECT COUNT(*) FROM t0 JOIN t1 ON (t0.c0 MOD 2) = (t1.c0 MOD 2);
-- Expected: 12
-- Actual:   4
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
