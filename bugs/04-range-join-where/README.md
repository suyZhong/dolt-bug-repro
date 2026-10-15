# Unexpected results when a WHERE filter is combined with a BETWEEN join on an indexed column

**Affected:** Every tested release (1.78.0 through 2.4.2) and master.

## What happens

The join on `t0.a BETWEEN t1.lo AND t1.hi` ignores `WHERE t0.w = 1` and also returns the row with `w = 0`. With a one-sided join condition, the filter is applied.

`EXPLAIN PLAN` shows a `RangeHeapJoin` over `IndexedTableAccess(t0)` with range `[NULL, ∞)`, and no filter on `t0.w` anywhere in the plan. The same happens through `LeftOuterRangeHeapJoin` when the filter is on the preserved side of a LEFT JOIN onto a derived table.

## Test case

Run in a fresh database ([repro.sql](repro.sql)):

```sql
CREATE TABLE t0(a INT PRIMARY KEY, w INT);
INSERT INTO t0 VALUES (1, 0), (2, 1);
CREATE TABLE t1(lo INT, hi INT);
INSERT INTO t1 VALUES (0, 10);

SELECT t0.a, t0.w FROM t0 JOIN t1 ON t0.a BETWEEN t1.lo AND t1.hi WHERE t0.w = 1;
-- Expected: 2, 1
-- Actual:   1, 0 / 2, 1

SELECT t0.a, t0.w FROM t0 JOIN t1 ON t0.a >= t1.lo WHERE t0.w = 1;
-- 2, 1
```

Verified through the MySQL protocol on Dolt 2.4.2 and master `ce68e18` (2026-10-14). MySQL 8.4.6 returns the expected results.
