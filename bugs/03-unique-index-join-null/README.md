# Unexpected results of an equi-join on a UNIQUE-indexed column when both sides are NULL

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

`t1.c0` has a UNIQUE index and both tables hold a NULL. `t0.c0 = t1.c0` is NULL for that pair, yet the join returns it. Without the index, the join returns the expected two rows.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(c0 INT);
CREATE TABLE t1(c0 INT);
CREATE UNIQUE INDEX i1 ON t1(c0);
INSERT INTO t0 VALUES (NULL), (1), (2);
INSERT INTO t1 VALUES (NULL), (1), (2);

SELECT SUM(t0.c0 = t1.c0) FROM t0, t1;
-- 2

SELECT * FROM t0 JOIN t1 ON t0.c0 = t1.c0 ORDER BY t0.c0;
-- Expected: 1, 1 / 2, 2
-- Actual:   NULL, NULL / 1, 1 / 2, 2
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
